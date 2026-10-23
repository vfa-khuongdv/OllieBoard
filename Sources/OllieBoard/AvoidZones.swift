import AppKit

/// Areas the pets stay out of: the middle of every screen, and a rectangle the user places over whatever
/// is being recorded. Pets never walk into a zone and walk out of it when they end up inside.
final class AvoidZones {
    static let minSize = CGSize(width: 160, height: 120)
    private let centerKey = "avoidCenter", customKey = "avoidCustom", frameKey = "avoidCustomFrame"

    private(set) var centerEnabled: Bool
    private(set) var customEnabled: Bool
    private(set) var editing = false
    private(set) var customFrame: CGRect

    private lazy var view: AvoidZoneView = {
        let view = AvoidZoneView(frame: CGRect(origin: .zero, size: customFrame.size))
        view.zones = self
        view.autoresizingMask = [.width, .height]
        return view
    }()

    private lazy var window: NSPanel = {
        let window = NSPanel(contentRect: customFrame, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.hidesOnDeactivate = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.contentView = view
        return window
    }()

    init() {
        let defaults = UserDefaults.standard
        centerEnabled = defaults.bool(forKey: centerKey)
        customEnabled = defaults.bool(forKey: customKey)
        let saved = defaults.string(forKey: frameKey).map(NSRectFromString)
        if let saved, NSScreen.screens.contains(where: { $0.visibleFrame.intersects(saved) }) {
            customFrame = saved
        } else {
            let f = NSScreen.main?.visibleFrame ?? NSScreen.screens[0].visibleFrame
            customFrame = CGRect(x: f.midX - 240, y: f.midY - 160, width: 480, height: 320)
        }
    }

    // MARK: Geometry

    /// Every area currently off limits.
    var rects: [CGRect] {
        var result: [CGRect] = []
        if centerEnabled {
            for screen in NSScreen.screens {
                let f = screen.visibleFrame
                let w = f.width * 0.42, h = f.height * 0.5
                result.append(CGRect(x: f.midX - w / 2, y: f.midY - h / 2, width: w, height: h))
            }
        }
        if customEnabled { result.append(customFrame) }
        return result
    }

    func blocks(_ body: CGRect) -> Bool { rects.contains { $0.intersects(body) } }

    /// The body of a pet standing at `feet`, including its speech bubble room.
    static func body(at feet: CGPoint) -> CGRect { CGRect(x: feet.x - 28, y: feet.y, width: 56, height: 110) }

    /// The closest spot just outside the zones for a pet standing at `feet` inside one (nil if it is not inside).
    func exitPoint(from feet: CGPoint, screen f: CGRect) -> CGPoint? {
        let body = AvoidZones.body(at: feet)
        let all = rects
        guard let zone = all.first(where: { $0.intersects(body) }) else { return nil }
        let candidates = [
            CGPoint(x: zone.minX - 34, y: feet.y), CGPoint(x: zone.maxX + 34, y: feet.y),
            CGPoint(x: feet.x, y: zone.minY - 112), CGPoint(x: feet.x, y: zone.maxY + 2),
        ].filter { p in
            p.x >= f.minX + 40 && p.x <= f.maxX - 40 && p.y >= f.minY && p.y <= f.maxY - 130
                && !all.contains { $0.intersects(AvoidZones.body(at: p)) }
        }
        return candidates.min { hypot($0.x - feet.x, $0.y - feet.y) < hypot($1.x - feet.x, $1.y - feet.y) }
    }

    // MARK: Changes from the menu

    func setCenter(_ on: Bool) {
        centerEnabled = on
        UserDefaults.standard.set(on, forKey: centerKey)
    }

    func setCustom(_ on: Bool) {
        customEnabled = on
        UserDefaults.standard.set(on, forKey: customKey)
        if !on { setEditing(false) }
    }

    func setEditing(_ on: Bool) {
        if on && !customEnabled { setCustom(true) }
        editing = on
        if on {
            window.setFrame(customFrame, display: true)
            window.orderFrontRegardless()
            view.needsDisplay = true
        } else {
            window.orderOut(nil)
        }
    }

    func setFrame(_ newFrame: CGRect) {
        customFrame = newFrame
        window.setFrame(newFrame, display: true)
    }

    func saveFrame() { UserDefaults.standard.set(NSStringFromRect(customFrame), forKey: frameKey) }
}

/// The rectangle shown while the user places the custom zone: drag to move, drag the corner to resize.
final class AvoidZoneView: NSView {
    weak var zones: AvoidZones?
    private var gripRect: CGRect { CGRect(x: bounds.maxX - 30, y: 0, width: 30, height: 30) }
    private var doneRect: CGRect { CGRect(x: bounds.maxX - 74, y: bounds.maxY - 36, width: 62, height: 24) }
    private var resizing = false
    private var startMouse: CGPoint = .zero
    private var startFrame: CGRect = .zero

    override func draw(_ dirtyRect: NSRect) {
        let red = NSColor(srgbRed: 1, green: 0.27, blue: 0.27, alpha: 1)
        let box = NSBezierPath(roundedRect: bounds.insetBy(dx: 2, dy: 2), xRadius: 10, yRadius: 10)
        red.withAlphaComponent(0.16).setFill()
        box.fill()
        box.setLineDash([8, 5], count: 2, phase: 0)
        box.lineWidth = 2.5
        red.setStroke()
        box.stroke()

        let grip = NSBezierPath()
        for i in 0..<3 {
            let d = CGFloat(8 + i * 6)
            grip.move(to: CGPoint(x: bounds.maxX - 8 - d, y: 8))
            grip.line(to: CGPoint(x: bounds.maxX - 8, y: 8 + d))
        }
        grip.lineWidth = 2.5
        grip.lineCapStyle = .round
        grip.stroke()

        red.setFill()
        NSBezierPath(roundedRect: doneRect, xRadius: 7, yRadius: 7).fill()
        let done = NSAttributedString(string: ui(.done), attributes: [
            .font: NSFont.systemFont(ofSize: 12, weight: .semibold), .foregroundColor: NSColor.white,
        ])
        done.draw(at: CGPoint(x: doneRect.midX - done.size().width / 2, y: doneRect.midY - done.size().height / 2))

        let hint = NSAttributedString(string: ui(.avoidHint), attributes: [
            .font: NSFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: NSColor.white,
        ])
        let size = hint.size()
        let pill = CGRect(x: 14, y: bounds.maxY - 34, width: size.width + 16, height: size.height + 6)
        if pill.maxX < doneRect.minX - 6 {
            NSColor(white: 0.1, alpha: 0.75).setFill()
            NSBezierPath(roundedRect: pill, xRadius: pill.height / 2, yRadius: pill.height / 2).fill()
            hint.draw(at: CGPoint(x: pill.minX + 8, y: pill.minY + 3))
        }
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func mouseDown(with event: NSEvent) {
        guard let zones else { return }
        let p = convert(event.locationInWindow, from: nil)
        if doneRect.contains(p) { return zones.setEditing(false) }
        resizing = gripRect.contains(p)
        startMouse = NSEvent.mouseLocation
        startFrame = zones.customFrame
    }

    override func mouseDragged(with event: NSEvent) {
        guard let zones, zones.editing else { return }
        let m = NSEvent.mouseLocation
        let dx = m.x - startMouse.x, dy = m.y - startMouse.y
        var f = startFrame
        if resizing {
            f.size.width = max(AvoidZones.minSize.width, startFrame.width + dx)
            f.size.height = max(AvoidZones.minSize.height, startFrame.height - dy)
            f.origin.y = startFrame.maxY - f.height
        } else {
            f.origin.x += dx
            f.origin.y += dy
        }
        zones.setFrame(f.integral)
    }

    override func mouseUp(with event: NSEvent) { zones?.saveFrame() }
}
