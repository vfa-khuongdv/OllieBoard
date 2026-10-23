// Procedurally draws the chibi characters with Core Graphics and writes one
// sprite sheet per character (<id>.png), the emote icons (effects.png) and the shared layout (layout.json).
// Every row is one animation; characters always face right (the app flips them).
//
// Usage: swift run SpriteGen [outputDir]

import AppKit

let frameSize: CGFloat = 128   // points per frame
let pixelScale: CGFloat = 2    // rendered at 2x for Retina

// MARK: - Animations

struct Animation {
    let name: String
    let fps: Double
    let loop: Bool
    let frames: [Pose]
}

func cycle(_ i: Int, _ n: Int) -> CGFloat { CGFloat(i) / CGFloat(n) * 2 * .pi }

let animations: [Animation] = [
    Animation(name: "idle", fps: 4, loop: true, frames: (0..<4).map { i in
        var p = Pose()
        p.bob = [0, -0.6, -1, -0.6][i]
        p.hairSwing = [0, 0.02, 0.03, 0.02][i]
        if i == 3 { p.eyes = .closed }
        return p
    }),
    Animation(name: "walk", fps: 12, loop: true, frames: (0..<8).map { i in
        let a = cycle(i, 8)
        var p = Pose()
        p.legFront = sin(a) * 0.55; p.legBack = -sin(a) * 0.55
        p.armFront = -sin(a) * 0.5; p.armBack = sin(a) * 0.5
        p.bob = -abs(cos(a)) * 2
        p.hairSwing = -0.04 - sin(a) * 0.03
        return p
    }),
    Animation(name: "run", fps: 16, loop: true, frames: (0..<6).map { i in
        let a = cycle(i, 6)
        var p = Pose()
        p.legFront = sin(a) * 0.9; p.legBack = -sin(a) * 0.9
        p.armFront = -sin(a) * 0.9 + 0.3; p.armBack = sin(a) * 0.9 + 0.3
        p.bob = -abs(cos(a)) * 4
        p.lean = 0.12
        p.hairSwing = -0.15 - sin(a) * 0.05
        p.mouth = .open; p.eyes = .open(look: 2)
        return p
    }),
    Animation(name: "kick", fps: 12, loop: false, frames: (0..<7).map { i in
        var p = Pose()
        p.legFront = [-0.3, -0.7, -0.9, 0.6, 1.5, 1.3, 0.4][i]
        p.armFront = [0.2, 0.5, 0.7, -0.6, -0.9, -0.8, -0.2][i]
        p.armBack = [-0.2, -0.4, -0.5, 0.8, 1.1, 1.0, 0.3][i]
        p.lean = [0, -0.06, -0.1, 0.05, 0.1, 0.08, 0][i]
        p.eyes = i < 3 ? .angry : (i < 6 ? .happy : .open(look: 1))
        p.brows = i < 3 ? .angry : .none
        p.mouth = i < 3 ? .pout : .grin
        return p
    }),
    Animation(name: "carry", fps: 10, loop: true, frames: (0..<8).map { i in
        let a = cycle(i, 8)
        var p = Pose()
        p.legFront = sin(a) * 0.45; p.legBack = -sin(a) * 0.45
        p.armFront = .pi * 0.92; p.armBack = .pi * 0.92
        p.bob = -abs(cos(a)) * 1.5
        p.eyes = .closed; p.mouth = .wavy; p.sweat = i % 4 < 2
        return p
    }),
    Animation(name: "happy", fps: 10, loop: true, frames: (0..<6).map { i in
        var p = Pose()
        p.bob = [0, -6, -12, -14, -10, -3][i]
        p.legFront = [0, 0.3, 0.5, 0.5, 0.3, 0][i]; p.legBack = -p.legFront
        p.armFront = .pi * 0.8; p.armBack = .pi * 0.8
        p.eyes = .happy; p.mouth = .grin; p.blush = 1
        p.hairSwing = [0, 0.05, 0.1, 0.1, 0.05, 0][i]
        return p
    }),
    Animation(name: "bored", fps: 2, loop: true, frames: (0..<4).map { i in
        var p = Pose()
        p.sitting = true
        p.tilt = [-0.12, -0.14, -0.14, -0.12][i]
        p.eyes = .half; p.mouth = i == 2 ? .o : .flat; p.brows = .sad
        p.armFront = 0.4; p.armBack = 0.5
        p.blush = 0.2
        return p
    }),
    Animation(name: "yawn", fps: 5, loop: false, frames: (0..<8).map { i in
        var p = Pose()
        let amount: CGFloat = [0, 0.3, 0.7, 1, 1, 0.8, 0.3, 0][i]
        p.mouth = amount > 0 ? .yawn(amount) : .flat
        p.eyes = amount > 0.5 ? .closed : .half
        p.armFront = .pi * 0.25 + .pi * 0.7 * amount; p.armBack = p.armFront
        p.tilt = -0.08 * amount
        p.bob = -amount * 1.5
        p.blush = 0.2
        return p
    }),
    Animation(name: "sleep", fps: 2, loop: true, frames: (0..<4).map { i in
        var p = Pose()
        p.sitting = true
        p.tilt = [0.22, 0.25, 0.27, 0.25][i]
        p.bob = [0, 0.5, 1, 0.5][i]
        p.eyes = .sleepy; p.mouth = i < 2 ? .o : .smile
        p.armFront = 0.3; p.armBack = 0.3
        return p
    }),
    Animation(name: "grumpy", fps: 8, loop: true, frames: (0..<4).map { i in
        var p = Pose()
        p.legFront = [0, -0.35, 0, 0][i]; p.legBack = [0, 0, 0, 0.35][i]
        p.bob = [0, -2, 0, -2][i]
        p.armFront = -0.35; p.armBack = 0.35
        p.eyes = .angry; p.brows = .angry; p.mouth = .pout; p.puffCheek = true; p.blush = 1
        p.tilt = 0.06
        return p
    }),
    Animation(name: "dragged", fps: 8, loop: true, frames: (0..<4).map { i in
        let a = cycle(i, 4)
        var p = Pose()
        p.legFront = sin(a) * 0.35; p.legBack = -sin(a) * 0.35
        p.armFront = .pi * 0.85; p.armBack = .pi * 0.85
        p.eyes = .wide; p.mouth = .o; p.brows = .raised; p.sweat = true
        p.dragged = true
        p.hairSwing = sin(a) * 0.08
        return p
    }),
    Animation(name: "surprised", fps: 6, loop: true, frames: (0..<2).map { i in
        var p = Pose()
        p.bob = i == 0 ? -3 : 0
        p.armFront = 1.0; p.armBack = 1.2
        p.eyes = .wide; p.mouth = .o; p.brows = .raised
        return p
    }),
    Animation(name: "work", fps: 6, loop: true, frames: (0..<4).map { i in
        var p = Pose()
        p.sitting = true
        p.laptop = true
        p.armFront = [0.55, 0.7, 0.6, 0.72][i]; p.armBack = [0.7, 0.55, 0.72, 0.6][i]
        p.bob = [0, -0.4, 0, -0.4][i]
        p.tilt = 0.06
        p.eyes = i == 3 ? .closed : .open(look: 0.5); p.mouth = .flat; p.blush = 0.3
        return p
    }),
    Animation(name: "sad", fps: 3, loop: true, frames: (0..<4).map { i in
        var p = Pose()
        p.eyes = .teary; p.brows = .sad; p.mouth = .frown
        p.tilt = 0.1; p.bob = [0, 0.5, 1, 0.5][i]
        p.armFront = 0.1; p.armBack = -0.1
        return p
    }),
    skillAnimation(1),
    skillAnimation(2),
]

// MARK: - Render

let columns = animations.map(\.frames.count).max()!
let outDir = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "Sources/OllieBoard/Resources/Sprites")
try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

/// Renders a grid of frames (y grows downward, matching how poses are authored) into `<name>.png`.
func renderSheet(_ name: String, columns: Int, rows: Int, draw: (CGContext, _ col: Int, _ row: Int) -> Void) throws {
    let pxW = Int(CGFloat(columns) * frameSize * pixelScale), pxH = Int(CGFloat(rows) * frameSize * pixelScale)
    guard let ctx = CGContext(data: nil, width: pxW, height: pxH, bitsPerComponent: 8, bytesPerRow: 0,
                              space: CGColorSpace(name: CGColorSpace.sRGB)!,
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { fatalError("no context") }
    ctx.translateBy(x: 0, y: CGFloat(pxH))
    ctx.scaleBy(x: pixelScale, y: -pixelScale)
    for row in 0..<rows {
        for col in 0..<columns {
            ctx.saveGState()
            ctx.translateBy(x: CGFloat(col) * frameSize, y: CGFloat(row) * frameSize)
            ctx.clip(to: CGRect(x: 0, y: 0, width: frameSize, height: frameSize))
            draw(ctx, col, row)
            ctx.restoreGState()
        }
    }
    let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
    try rep.representation(using: .png, properties: [:])!.write(to: outDir.appendingPathComponent("\(name).png"))
}

for look in looks {
    try renderSheet(look.id, columns: columns, rows: animations.count) { ctx, col, row in
        let frames = animations[row].frames
        if col < frames.count { drawCharacter(ctx, frames[col], look) }
    }
}
try renderSheet("effects", columns: effectNames.count, rows: 1) { ctx, col, _ in drawEffect(ctx, col) }

var layout: [String: Any] = [:]
for (row, anim) in animations.enumerated() {
    layout[anim.name] = ["row": row, "frames": anim.frames.count, "fps": anim.fps, "loop": anim.loop]
}
let json: [String: Any] = [
    "frameSize": frameSize,
    "pixelScale": pixelScale,
    "anchor": ["x": feet.x, "y": feet.y],
    "animations": layout,
    "effects": effectNames,
]
try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
    .write(to: outDir.appendingPathComponent("layout.json"))
print("Wrote \(looks.count) sheets (\(columns)x\(animations.count) frames) + effects.png to \(outDir.path)")
