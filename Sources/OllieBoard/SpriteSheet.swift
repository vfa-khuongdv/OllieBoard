import AppKit

enum Anim: String, CaseIterable {
    case idle, walk, run, kick, carry, happy, bored, yawn, sleep, grumpy, dragged, surprised, work, sad
    /// Each character's two special moves (see Skill).
    case skill1, skill2
}

enum Effect: String, CaseIterable {
    case heart, note, anger, zzz, dots, sweat, exclaim, sparkle, code, check
    // Props and particles for the special moves.
    case chest, flower1, flower2, flower3, flame, glow, puff
}

/// Layout shared by every character sheet (written by SpriteGen).
struct SheetLayout: Decodable {
    struct AnimInfo: Decodable { let row: Int; let frames: Int; let fps: Double; let loop: Bool }
    struct Anchor: Decodable { let x: CGFloat; let y: CGFloat }

    let frameSize: CGFloat
    let pixelScale: CGFloat
    let anchor: Anchor        // feet position inside a frame, y measured from the top
    let animations: [String: AnimInfo]
    let effects: [String]     // emote icons, in order, in effects.png
}

final class SpriteSheet {
    static let directory: URL = {
        // Inside the .app the sprites live in Contents/Resources; with `swift run` they come from the SPM bundle.
        if let url = Bundle.main.resourceURL?.appendingPathComponent("Sprites"),
           FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        return Bundle.module.resourceURL!.appendingPathComponent("Sprites")
    }()

    static let layout: SheetLayout = {
        let data = try! Data(contentsOf: directory.appendingPathComponent("layout.json"))
        return try! JSONDecoder().decode(SheetLayout.self, from: data)
    }()

    private static var cache: [String: SpriteSheet] = [:]

    /// Shared so each sheet is decoded only once.
    static func named(_ id: String) -> SpriteSheet {
        if let sheet = cache[id] { return sheet }
        let sheet = SpriteSheet(characterID: id)
        cache[id] = sheet
        return sheet
    }

    /// Emote icons shared by every character.
    private static let effects: [Effect: CGImage] = {
        let names = layout.effects
        let images = cells(of: "effects", names.indices.map { ($0, 0) })
        return Dictionary(uniqueKeysWithValues: zip(names, images).compactMap { name, image in
            Effect(rawValue: name).map { ($0, image) }
        })
    }()

    static func effect(_ effect: Effect) -> CGImage? { effects[effect] }

    private var frames: [Anim: [CGImage]] = [:]

    private init(characterID: String) {
        let layout = Self.layout
        for anim in Anim.allCases {
            guard let info = layout.animations[anim.rawValue] else { continue }
            frames[anim] = Self.cells(of: characterID, (0..<info.frames).map { ($0, info.row) })
        }
    }

    /// Cuts the given (column, row) cells out of `<name>.png`.
    private static func cells(of name: String, _ positions: [(Int, Int)]) -> [CGImage] {
        let url = directory.appendingPathComponent("\(name).png")
        guard let png = NSImage(contentsOf: url)?.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            fatalError("Missing sprite sheet \(url.path)")
        }
        let px = Int(layout.frameSize * layout.pixelScale)
        // Store frames in the display's color space so drawing them doesn't color-convert every frame.
        let space = NSScreen.main?.colorSpace?.cgColorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
        func bitmap(_ width: Int, _ height: Int) -> CGContext {
            CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                      space: space, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)!
        }
        // Decode the PNG once (crops of a lazily-decoded PNG re-inflate the whole sheet on every draw),
        // then copy each used cell into its own small bitmap so the full sheet can be released.
        let decoded = bitmap(png.width, png.height)
        decoded.draw(png, in: CGRect(x: 0, y: 0, width: png.width, height: png.height))
        let sheet = decoded.makeImage()!
        func cell(_ col: Int, _ row: Int) -> CGImage {
            let copy = bitmap(px, px)
            copy.draw(sheet.cropping(to: CGRect(x: col * px, y: row * px, width: px, height: px))!,
                      in: CGRect(x: 0, y: 0, width: px, height: px))
            return copy.makeImage()!
        }
        return positions.map { cell($0.0, $0.1) }
    }

    /// Frame of `anim` after it has been playing for `elapsed` seconds.
    func frame(_ anim: Anim, elapsed: TimeInterval) -> CGImage? {
        guard let list = frames[anim], let info = Self.layout.animations[anim.rawValue] else { return nil }
        let i = Int(elapsed * info.fps)
        return list[info.loop ? i % list.count : min(i, list.count - 1)]
    }

    func duration(_ anim: Anim) -> TimeInterval {
        guard let info = Self.layout.animations[anim.rawValue] else { return 0 }
        return Double(info.frames) / info.fps
    }

}
