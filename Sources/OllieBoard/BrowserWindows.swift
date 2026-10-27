import AppKit
import ApplicationServices

/// A browser window on screen. `frame` is in global Cocoa coordinates (origin bottom-left of the primary screen).
struct BrowserWindow {
    let pid: pid_t
    let id: CGWindowID
    let bundleID: String?
    var frame: CGRect
}

/// Finds the browser window the user is looking at and the elements on its page.
/// Finding the window needs no permission (window bounds are public); reading the page needs Accessibility.
final class BrowserWindows {
    private static let bundleIDs: Set<String> = [
        "com.apple.Safari", "com.google.Chrome", "com.google.Chrome.canary", "company.thebrowser.Browser",
        "org.mozilla.firefox", "com.microsoft.edgemac", "com.brave.Browser", "com.vivaldi.Vivaldi",
        "com.operasoftware.Opera", "app.zen-browser.zen",
    ]
    private static let enabledKey = "browserInteraction"

    private let queue = DispatchQueue(label: "ollieboard.browser")

    var enabled: Bool {
        get { UserDefaults.standard.bool(forKey: Self.enabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.enabledKey) }
    }

    var isTrusted: Bool { AXIsProcessTrusted() }

    func requestAccess() {
        _ = AXIsProcessTrustedWithOptions(["AXTrustedCheckOptionPrompt": true] as CFDictionary)
    }

    // MARK: Finding

    private static var primaryHeight: CGFloat { NSScreen.screens.first?.frame.height ?? 0 }

    private static func cocoaFrame(_ bounds: CGRect) -> CGRect {
        CGRect(x: bounds.minX, y: primaryHeight - bounds.maxY, width: bounds.width, height: bounds.height)
    }

    /// The frontmost ordinary browser window that isn't minimized or full screen.
    func frontWindow() -> BrowserWindow? {
        let pids = Set(NSWorkspace.shared.runningApplications
            .filter { $0.bundleIdentifier.map(Self.bundleIDs.contains) ?? false }.map(\.processIdentifier))
        guard !pids.isEmpty,
              let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]]
        else { return nil }
        for info in list {   // front to back
            guard let pid = info[kCGWindowOwnerPID as String] as? pid_t, pids.contains(pid),
                  info[kCGWindowLayer as String] as? Int == 0,
                  let id = info[kCGWindowNumber as String] as? CGWindowID,
                  let dict = info[kCGWindowBounds as String] as? NSDictionary,
                  let bounds = CGRect(dictionaryRepresentation: dict),
                  bounds.width > 300, bounds.height > 200
            else { continue }
            let frame = Self.cocoaFrame(bounds)
            if NSScreen.screens.contains(where: { frame.width >= $0.frame.width - 2 && frame.height >= $0.frame.height - 2 }) {
                continue   // full screen
            }
            return BrowserWindow(pid: pid, id: id, bundleID: NSRunningApplication(processIdentifier: pid)?.bundleIdentifier, frame: frame)
        }
        return nil
    }

    /// Current frame of a window, nil once it is gone.
    static func frame(of id: CGWindowID) -> CGRect? {
        guard let list = CGWindowListCopyWindowInfo([.optionIncludingWindow], id) as? [[String: Any]],
              let dict = list.first?[kCGWindowBounds as String] as? NSDictionary,
              let bounds = CGRect(dictionaryRepresentation: dict) else { return nil }
        return Self.cocoaFrame(bounds)
    }

    // MARK: Page elements

    enum SpotKind { case button, link, text, heading, image }

    /// Something on the page the pets can mess with; `frame` is in Cocoa coordinates.
    struct Spot {
        let kind: SpotKind
        let frame: CGRect
    }

    /// Elements seen in the front window by the last scan; only valid while that window is still `spotsWindow`
    /// and hasn't moved from `spotsFrame`.
    private(set) var spots: [Spot] = []
    private(set) var spotsWindow: CGWindowID = 0
    private(set) var spotsFrame = CGRect.zero
    /// The page area in AX coordinates (origin top-left of the primary screen), used to map spots into the page.
    private(set) var spotsWebArea: CGRect?
    private var scanning = false
    private let scanQueue = DispatchQueue(label: "ollieboard.browser.scan")

    private static let spotRoles: [String: SpotKind] = [
        kAXButtonRole: .button, kAXPopUpButtonRole: .button, "AXLink": .link,
        kAXStaticTextRole: .text, "AXHeading": .heading, kAXImageRole: .image,
    ]

    /// Walks the window's accessibility tree for buttons, links, text, headings and images. Runs in the background
    /// and replaces `spots` when done; Chromium browsers only fill in page content after the first scan
    /// switched accessibility on.
    func scanSpots() {
        guard isTrusted, !scanning, let window = frontWindow() else { return }
        scanning = true
        scanQueue.async { [weak self] in
            let app = AXUIElementCreateApplication(window.pid)
            AXUIElementSetAttributeValue(app, "AXManualAccessibility" as CFString, kCFBooleanTrue)
            AXUIElementSetMessagingTimeout(app, 0.2)
            var found: [Spot] = []
            var webArea: CGRect?
            var visited = 0
            func walk(_ element: AXUIElement, depth: Int) {
                guard depth < 40, visited < 5000 else { return }
                visited += 1
                let role = Self.attribute(element, kAXRoleAttribute) as? String ?? ""
                if role == "AXWebArea", let ax = Self.axFrame(of: element),
                   ax.width * ax.height > (webArea.map { $0.width * $0.height } ?? 0) {
                    webArea = ax
                }
                if let kind = Self.spotRoles[role], let ax = Self.axFrame(of: element),
                   (16...900).contains(ax.width), (12...260).contains(ax.height) {
                    let frame = CGRect(x: ax.minX, y: Self.primaryHeight - ax.maxY, width: ax.width, height: ax.height)
                    if window.frame.contains(frame) { found.append(Spot(kind: kind, frame: frame)) }
                }
                if role == kAXStaticTextRole || role == kAXButtonRole { return }   // nothing useful inside
                for child in Self.attribute(element, kAXChildrenAttribute) as? [AXUIElement] ?? [] {
                    walk(child, depth: depth + 1)
                }
            }
            if let element = self?.element(for: window) { walk(element, depth: 0) }
            DispatchQueue.main.async {
                self?.scanning = false
                self?.spots = found
                self?.spotsWindow = window.id
                self?.spotsFrame = window.frame
                self?.spotsWebArea = webArea
            }
        }
    }

    /// Spots that are still where the scan saw them (the user hasn't moved or switched the window since).
    func currentSpots(in window: BrowserWindow) -> [Spot] {
        guard spotsWindow == window.id, abs(spotsFrame.minX - window.frame.minX) < 2, abs(spotsFrame.minY - window.frame.minY) < 2,
              abs(spotsFrame.width - window.frame.width) < 2 else { return [] }
        return spots
    }

    private static func attribute(_ element: AXUIElement, _ name: String) -> AnyObject? {
        var value: CFTypeRef?
        return AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success ? value : nil
    }

    /// Frame in AX coordinates (origin top-left of the primary screen).
    private static func axFrame(of element: AXUIElement) -> CGRect? {
        var p = CGPoint.zero, s = CGSize.zero
        guard let pv = attribute(element, kAXPositionAttribute), let sv = attribute(element, kAXSizeAttribute),
              AXValueGetValue(pv as! AXValue, .cgPoint, &p), AXValueGetValue(sv as! AXValue, .cgSize, &s) else { return nil }
        return CGRect(origin: p, size: s)
    }

    // MARK: Page DOM

    private static let domBundleIDs: Set<String> = [
        "com.apple.Safari", "com.google.Chrome", "com.google.Chrome.canary", "com.brave.Browser",
        "com.microsoft.edgemac", "com.vivaldi.Vivaldi", "company.thebrowser.Browser",
    ]
    private static let domKey = "browserDOM"

    /// Edit the real page through the browser's "Allow JavaScript from Apple Events" instead of drawing over it.
    var domEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Self.domKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.domKey) }
    }
    /// Why the last page edit failed (JavaScript from Apple Events off, Automation refused…), nil after a success.
    private(set) var domError: String?
    private var askedAutomation: Set<String> = []
    private let domQueue = DispatchQueue(label: "ollieboard.browser.dom")

    func canEditPage(_ window: BrowserWindow) -> Bool {
        domEnabled && spotsWebArea != nil && window.bundleID.map(Self.domBundleIDs.contains) ?? false
    }

    /// Applies a style change to the element under `spot`; it stays until the page is reloaded. Never clicks or
    /// touches form fields; `completion(false)` means nothing changed (caller falls back to the overlay).
    func editPage(_ window: BrowserWindow, spot: Spot, style: ElementPrank.Style, color: NSColor, sticker: String,
                  duration: TimeInterval, completion: @escaping (Bool) -> Void) {
        guard let bundleID = window.bundleID, let web = spotsWebArea else { return completion(false) }
        let rgb = color.usingColorSpace(.sRGB) ?? .systemPink
        let params: [String: Any] = [
            "sx": spot.frame.midX, "sy": Self.primaryHeight - spot.frame.midY, "wx": web.minX, "wy": web.minY, "ww": web.width,
            "kind": "\(spot.kind)", "style": style.rawValue, "sticker": sticker,
            "color": "rgb(\(Int(rgb.redComponent * 255)),\(Int(rgb.greenComponent * 255)),\(Int(rgb.blueComponent * 255)))",
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: params),
              let json = String(data: data, encoding: .utf8) else { return completion(false) }
        let js = "(" + Self.pageScript + ")(" + json + ")"
        let command = bundleID == "com.apple.Safari"
            ? "do JavaScript (item 1 of argv) in current tab of front window"
            : "execute front window's active tab javascript (item 1 of argv)"
        let script = "on run argv\ntell application id \"\(bundleID)\" to \(command)\nend run"
        domQueue.async { [weak self] in
            let permission = Self.automationPermission(bundleID, ask: false)
            if permission == OSStatus(errAEEventWouldRequireUserConsent) {
                // Ask once without blocking the pranks; the answer applies to the next one.
                DispatchQueue.main.async {
                    guard self?.askedAutomation.insert(bundleID).inserted == true else { return }
                    DispatchQueue.global().async { _ = Self.automationPermission(bundleID, ask: true) }
                }
                return DispatchQueue.main.async { completion(false) }
            }
            var error: String?
            var ok = false
            if permission != noErr {
                error = "Automation (\(permission))"
            } else {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
                process.arguments = ["-e", script, js]
                let out = Pipe(), err = Pipe()
                process.standardOutput = out
                process.standardError = err
                let timeout = DispatchWorkItem { if process.isRunning { process.terminate() } }
                do {
                    try process.run()
                    DispatchQueue.global().asyncAfter(deadline: .now() + 6, execute: timeout)
                    let output = String(decoding: out.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
                    let message = String(decoding: err.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
                    process.waitUntilExit()
                    timeout.cancel()
                    if process.terminationStatus != 0 {
                        error = message.trimmingCharacters(in: .whitespacesAndNewlines)
                    } else {
                        ok = output.trimmingCharacters(in: .whitespacesAndNewlines) == "ok"
                    }
                } catch {
                    // Failing to launch osascript is not the browser's fault; just fall back.
                }
            }
            DispatchQueue.main.async {
                // "skip" (nothing suitable under the spot) is not an error.
                if ok || error == nil { self?.domError = nil } else { self?.domError = error }
                completion(ok)
            }
        }
    }

    private static func automationPermission(_ bundleID: String, ask: Bool) -> OSStatus {
        var target = AEAddressDesc()
        _ = bundleID.withCString { AECreateDesc(typeApplicationBundleID, $0, strlen($0), &target) }
        defer { AEDisposeDesc(&target) }
        return AEDeterminePermissionToAutomateTarget(&target, typeWildCard, typeWildCard, ask)
    }

    /// Runs in the page. The screen point of the spot is mapped into the page through the web area's frame
    /// (its width over `innerWidth` is the page zoom). The change stays until the user reloads the page.
    private static let pageScript = """
    function (p) {
      try {
        if (document.querySelector('input[type=password]')) return 'skip';
        var z = p.ww / window.innerWidth;
        var el = document.elementFromPoint((p.sx - p.wx) / z, (p.sy - p.wy) / z);
        if (!el) return 'skip';
        var pick = { button: 'button,[role=button],a,summary', link: 'a', heading: 'h1,h2,h3,h4,h5,h6',
                     text: 'p,li,td,span,a,h1,h2,h3,h4,h5,h6', image: 'img,svg,picture,canvas,video' }[p.kind];
        var t = el.closest(pick) || el;
        if (t === document.body || t === document.documentElement) return 'skip';
        if (t.closest('input,textarea,select,[contenteditable=""],[contenteditable="true"]')) return 'skip';
        var extra = null, s = t.style;
        s.transition = 'all .4s ease';
        if (p.style === 'swell') {
          s.display = getComputedStyle(t).display === 'inline' ? 'inline-block' : s.display;
          s.transform = 'scale(1.5) rotate(-4deg)'; s.background = p.color; s.color = '#fff'; s.position = 'relative'; s.zIndex = 9999;
        } else if (p.style === 'highlight') {
          s.background = p.color; s.boxShadow = '0 0 0 3px ' + p.color; s.color = '#000';
        } else if (p.style === 'censor') {
          s.background = '#000'; s.color = '#000'; s.borderRadius = '3px'; s.userSelect = 'none';
        } else if (p.style === 'scribble') {
          s.textDecoration = 'underline wavy ' + p.color; s.textDecorationThickness = '3px'; s.textUnderlineOffset = '4px'; s.color = p.color;
        } else {
          if (p.kind === 'image') {
            s.transform = 'rotate(10deg) scale(1.15)'; s.filter = 'hue-rotate(150deg) saturate(1.8)';
          } else {
            extra = document.createElement('span'); extra.textContent = ' ' + p.sticker;
            extra.style.cssText = 'display:inline-block;font-size:1.3em;transition:transform .4s';
            t.appendChild(extra); setTimeout(function () { extra.style.transform = 'rotate(20deg) scale(1.4)'; }, 50);
          }
        }
        return 'ok';
      } catch (e) { return 'err ' + e; }
    }
    """

    /// The accessibility element whose frame matches the window, since CGWindowIDs aren't exposed by AX.
    private func element(for window: BrowserWindow) -> AXUIElement? {
        let app = AXUIElementCreateApplication(window.pid)
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &value) == .success,
              let elements = value as? [AXUIElement] else { return nil }
        let top = Self.primaryHeight - window.frame.maxY
        return elements.first { element in
            var p = CGPoint.zero, s = CGSize.zero
            var v: CFTypeRef?
            guard AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &v) == .success,
                  AXValueGetValue(v as! AXValue, .cgPoint, &p),
                  AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &v) == .success,
                  AXValueGetValue(v as! AXValue, .cgSize, &s) else { return false }
            return abs(p.x - window.frame.minX) < 4 && abs(p.y - top) < 4 && abs(s.width - window.frame.width) < 4
        }
    }
}

/// A visual prank laid over an element of the page: a fake swelling button, a marker swipe over text,
/// a censor bar, a scribble or a sticker. Purely visual: the page is untouched and clicks go straight through.
final class ElementPrank: NSPanel {
    enum Style: String { case swell, highlight, censor, scribble, sticker }

    private static let grow: CGFloat = 1.8
    private let prankView = PrankView()
    private var target: CGWindowID = 0
    private var windowOrigin = CGPoint.zero
    private var element = CGRect.zero
    private var start: TimeInterval = 0
    private var duration: TimeInterval = 0

    init() {
        super.init(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = true
        hidesOnDeactivate = false
        collectionBehavior = [.stationary, .ignoresCycle, .fullScreenAuxiliary]
        contentView = prankView
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect { frameRect }

    func start(_ style: Style, on element: CGRect, in window: CGWindowID, color: NSColor, sticker: String, duration: TimeInterval) {
        guard let frame = BrowserWindows.frame(of: window) else { return }
        target = window
        windowOrigin = frame.origin
        self.element = element
        start = CACurrentMediaTime()
        self.duration = duration
        prankView.style = style
        prankView.color = color
        prankView.sticker = sticker
        follow()
    }

    func tick() {
        guard target != 0 else { return }
        let age = CACurrentMediaTime() - start
        if age >= duration { return stop() }
        prankView.age = CGFloat(age)
        // Fades in at once and out over the last second.
        prankView.alpha = CGFloat(min(1, age / 0.15, max(0, duration - age)))
        prankView.needsDisplay = true
        follow()
    }

    private func follow() {
        guard let window = BrowserWindows.frame(of: target) else { return stop() }
        let moved = CGPoint(x: window.minX - windowOrigin.x, y: window.minY - windowOrigin.y)
        let c = CGPoint(x: element.midX + moved.x, y: element.midY + moved.y)
        let w = element.width * Self.grow + 8, h = element.height * Self.grow + 8
        let frame = CGRect(x: c.x - w / 2, y: c.y - h / 2, width: w, height: h)
        if self.frame != frame { setFrame(frame, display: false) }
        prankView.base = element.size
        order(.above, relativeTo: Int(target))
    }

    private func stop() {
        target = 0
        orderOut(nil)
    }
}

private final class PrankView: NSView {
    var style = ElementPrank.Style.swell
    var color = NSColor.systemPink
    var sticker = "😎"
    var age: CGFloat = 0
    var alpha: CGFloat = 1
    var base = CGSize.zero

    override func draw(_ dirtyRect: NSRect) {
        let rect = CGRect(x: bounds.midX - base.width / 2, y: bounds.midY - base.height / 2, width: base.width, height: base.height)
        switch style {
        case .swell: drawSwell(rect)
        case .highlight:
            // A marker sweeps across the text.
            let w = rect.width * min(1, age / 0.7)
            color.withAlphaComponent(0.55 * alpha).setFill()
            NSBezierPath(roundedRect: CGRect(x: rect.minX, y: rect.minY - 2, width: w, height: rect.height + 4), xRadius: 3, yRadius: 3).fill()
        case .censor:
            let w = rect.width * min(1, age / 0.5)
            NSColor.black.withAlphaComponent(0.92 * alpha).setFill()
            NSBezierPath(roundedRect: CGRect(x: rect.minX - 2, y: rect.minY, width: w + 4, height: rect.height), xRadius: 2, yRadius: 2).fill()
        case .scribble:
            // A wavy line drawn under the text from left to right.
            let path = NSBezierPath()
            let end = rect.width * min(1, age / 0.9)
            var x: CGFloat = 0
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            while x < end {
                x += 3
                path.line(to: CGPoint(x: rect.minX + x, y: rect.minY + 3 * sin(x / 4)))
            }
            color.withAlphaComponent(0.95 * alpha).setStroke()
            path.lineWidth = 3
            path.lineCapStyle = .round
            path.stroke()
        case .sticker:
            let size = min(max(rect.height * 1.2, 30), 80) * (1 + 0.2 * sin(age * 7) * min(1, age / 0.4))
            let text = NSAttributedString(string: sticker, attributes: [.font: NSFont.systemFont(ofSize: size)])
            let box = text.size()
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current?.cgContext.setAlpha(alpha)
            text.draw(at: CGPoint(x: bounds.midX - box.width / 2, y: bounds.midY - box.height / 2))
            NSGraphicsContext.restoreGraphicsState()
        }
    }

    private func drawSwell(_ base: CGRect) {
        // Swells quickly, then keeps pulsing.
        let ease = min(1, Double(age) / 0.4)
        let scale = 1 + 0.8 * CGFloat(ease) * CGFloat(0.55 + 0.45 * sin(Double(age) * 6))
        let w = base.width * scale, h = base.height * scale
        let rect = CGRect(x: bounds.midX - w / 2, y: bounds.midY - h / 2, width: w, height: h)
        let shape = NSBezierPath(roundedRect: rect, xRadius: min(h / 2, 10), yRadius: min(h / 2, 10))
        color.withAlphaComponent(alpha).setFill()
        shape.fill()
        NSColor.white.withAlphaComponent(0.8 * alpha).setStroke()
        shape.lineWidth = 2
        shape.stroke()
    }
}
