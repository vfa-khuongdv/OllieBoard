import AppKit

// MARK: - Colors

func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}

let white = rgb(0xFFFFFF)
let outline = rgb(0x4A2D3A)
let mouthRed = rgb(0xC2384E)

// MARK: - Pose model

enum Eyes { case open(look: CGFloat), closed, happy, half, angry, wide, sleepy, teary, sparkle }
enum Mouth { case smile, open, flat, pout, o, yawn(CGFloat), grin, frown, wavy, smirk }
enum Brows { case none, angry, sad, raised }

struct Pose {
    var bob: CGFloat = 0            // vertical body offset (negative = up)
    var legBack: CGFloat = 0        // leg angles in radians, positive = forward
    var legFront: CGFloat = 0
    var armBack: CGFloat = 0.15     // arm angles, 0 = down, positive = forward, π = up
    var armFront: CGFloat = -0.15
    var eyes: Eyes = .open(look: 1)
    var mouth: Mouth = .smile
    var brows: Brows = .none
    var blush: CGFloat = 0.6
    var tilt: CGFloat = 0           // head tilt in radians
    var lean: CGFloat = 0           // whole body lean
    var hairSwing: CGFloat = 0
    var sitting = false
    var puffCheek = false
    var sweat = false
    /// Lets a character override the shared picked-up expression without changing everyone else.
    var dragged = false
    var laptop = false
    var skill: (which: Int, frame: Int)? = nil   // a frame of a special-move row, drawn by drawSkill
}

// MARK: - CGContext helpers

extension CGContext {
    func fillEllipse(_ c: CGPoint, _ rx: CGFloat, _ ry: CGFloat, _ color: CGColor) {
        setFillColor(color)
        fillEllipse(in: CGRect(x: c.x - rx, y: c.y - ry, width: rx * 2, height: ry * 2))
    }

    func stroke(_ build: (CGMutablePath) -> Void, _ color: CGColor, _ width: CGFloat) {
        let p = CGMutablePath(); build(p)
        addPath(p); setStrokeColor(color); setLineWidth(width)
        setLineCap(.round); setLineJoin(.round); strokePath()
    }

    func fill(_ build: (CGMutablePath) -> Void, _ color: CGColor, outlineWidth: CGFloat = 1.6) {
        let p = CGMutablePath(); build(p)
        addPath(p); setFillColor(color); fillPath()
        if outlineWidth > 0 {
            addPath(p); setStrokeColor(outline); setLineWidth(outlineWidth)
            setLineJoin(.round); strokePath()
        }
    }

    /// Fills a path with a vertical gradient between two y values, then outlines it.
    func fillGradient(_ build: (CGMutablePath) -> Void, _ colors: [CGColor], from y0: CGFloat, to y1: CGFloat,
                      outlineWidth: CGFloat = 1.6) {
        let p = CGMutablePath(); build(p)
        saveGState()
        addPath(p); clip()
        let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
        drawLinearGradient(g, start: CGPoint(x: 0, y: y0), end: CGPoint(x: 0, y: y1),
                           options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        restoreGState()
        if outlineWidth > 0 {
            addPath(p); setStrokeColor(outline); setLineWidth(outlineWidth); setLineJoin(.round); strokePath()
        }
    }
}

func limb(_ ctx: CGContext, from: CGPoint, angle: CGFloat, length: CGFloat, width: CGFloat,
          color: CGColor, end: (CGPoint) -> Void) {
    let to = CGPoint(x: from.x + sin(angle) * length, y: from.y + cos(angle) * length)
    ctx.stroke({ $0.move(to: from); $0.addLine(to: to) }, outline, width + 2.4)
    ctx.stroke({ $0.move(to: from); $0.addLine(to: to) }, color, width)
    end(to)
}

func drawDrop(_ ctx: CGContext, at p: CGPoint, size s: CGFloat) {
    ctx.fill({ path in
        path.move(to: CGPoint(x: p.x, y: p.y - 5 * s))
        path.addQuadCurve(to: CGPoint(x: p.x, y: p.y + 4 * s), control: CGPoint(x: p.x + 6 * s, y: p.y + 3 * s))
        path.addQuadCurve(to: CGPoint(x: p.x, y: p.y - 5 * s), control: CGPoint(x: p.x - 6 * s, y: p.y + 3 * s))
    }, rgb(0x9AD8FF), outlineWidth: 1.2)
}

/// Four-pointed sparkle star.
func fillStar(_ ctx: CGContext, _ c: CGPoint, _ r: CGFloat, _ color: CGColor) {
    ctx.setFillColor(color)
    ctx.move(to: CGPoint(x: c.x, y: c.y - r))
    ctx.addQuadCurve(to: CGPoint(x: c.x + r, y: c.y), control: c)
    ctx.addQuadCurve(to: CGPoint(x: c.x, y: c.y + r), control: c)
    ctx.addQuadCurve(to: CGPoint(x: c.x - r, y: c.y), control: c)
    ctx.addQuadCurve(to: CGPoint(x: c.x, y: c.y - r), control: c)
    ctx.fillPath()
}

func drawText(_ ctx: CGContext, _ s: String, size: CGFloat, at p: CGPoint, color: CGColor) {
    let font = CTFontCreateWithName("AvenirNext-Heavy" as CFString, size, nil)
    let attr = NSAttributedString(string: s, attributes: [.font: font, .foregroundColor: NSColor(cgColor: color)!])
    let line = CTLineCreateWithAttributedString(attr)
    ctx.saveGState()
    ctx.textMatrix = CGAffineTransform(scaleX: 1, y: -1)  // context is flipped
    ctx.textPosition = p
    CTLineDraw(line, ctx)
    ctx.restoreGState()
}

// MARK: - Face

/// Eye centers relative to the head center; shifted slightly toward the facing side (+x).
let eyeOffsets: [CGPoint] = [CGPoint(x: -8, y: 3), CGPoint(x: 12, y: 3)]

func drawFace(_ ctx: CGContext, head c: CGPoint, pose: Pose, look: Look) {
    for o in eyeOffsets {
        let e = CGPoint(x: c.x + o.x, y: c.y + o.y)
        // Smaller, less anime eyes for the real-life caricatures.
        ctx.saveGState()
        ctx.translateBy(x: e.x, y: e.y); ctx.scaleBy(x: look.eyeScale, y: look.eyeScale); ctx.translateBy(x: -e.x, y: -e.y)
        defer { ctx.restoreGState() }
        switch pose.eyes {
        case .open(let lookX):
            drawOpenEye(ctx, e, look: lookX, lid: look.restingLid, look)
        case .teary:
            drawOpenEye(ctx, e, look: 0, lid: look.restingLid, look)
            ctx.fillEllipse(CGPoint(x: e.x, y: e.y + 7), 4.2, 1.8, rgb(0x9AD8FF, 0.9))
        case .half:
            drawOpenEye(ctx, e, look: 1.5, lid: max(0.5, look.restingLid), look)
        case .angry:
            drawOpenEye(ctx, e, look: 0.5, lid: max(0.35, look.restingLid), look)
        case .wide:
            ctx.fill({ $0.addEllipse(in: CGRect(x: e.x - 5.5, y: e.y - 7, width: 11, height: 14)) }, white, outlineWidth: 1.4)
            ctx.fillEllipse(e, 2, 2.4, look.irisDark)
        case .closed, .sleepy:
            ctx.stroke({ p in
                p.move(to: CGPoint(x: e.x - 5, y: e.y + 1))
                p.addQuadCurve(to: CGPoint(x: e.x + 5, y: e.y + 1), control: CGPoint(x: e.x, y: e.y + 5))
            }, outline, 2)
        case .happy:
            ctx.stroke({ p in
                p.move(to: CGPoint(x: e.x - 5, y: e.y + 3))
                p.addQuadCurve(to: CGPoint(x: e.x + 5, y: e.y + 3), control: CGPoint(x: e.x, y: e.y - 6))
            }, outline, 2.4)
        case .sparkle:
            drawOpenEye(ctx, e, look: 0.5, lid: 0, look)
            fillStar(ctx, CGPoint(x: e.x - 0.5, y: e.y - 1), 3.8, white)
        }
    }

    // Brows.
    for (i, o) in eyeOffsets.enumerated() {
        let inner: CGFloat = i == 0 ? 1 : -1   // direction toward the nose
        let x = c.x + o.x, y = c.y + o.y - 3 - 8 * look.eyeScale
        switch pose.brows {
        case .none:
            if look.face.contains(.thickBrows) {
                ctx.stroke({ p in
                    p.move(to: CGPoint(x: x - inner * 5, y: y + 1))
                    p.addQuadCurve(to: CGPoint(x: x + inner * 4.5, y: y + 0.5), control: CGPoint(x: x, y: y - 1.5))
                }, look.hairDark, 2.8)
            }
        case .angry:
            ctx.stroke({ p in
                p.move(to: CGPoint(x: x - inner * 5, y: y - 2)); p.addLine(to: CGPoint(x: x + inner * 4, y: y + 3))
            }, look.hairDark, 2.4)
        case .sad:
            ctx.stroke({ p in
                p.move(to: CGPoint(x: x - inner * 5, y: y + 2)); p.addLine(to: CGPoint(x: x + inner * 4, y: y - 2))
            }, look.hairDark, 2.2)
        case .raised:
            ctx.stroke({ p in
                p.move(to: CGPoint(x: x - 4, y: y - 2))
                p.addQuadCurve(to: CGPoint(x: x + 4, y: y - 2), control: CGPoint(x: x, y: y - 6))
            }, look.hairDark, 2)
        }
    }

    // Blush.
    let blush = max(pose.blush, look.extraBlush)
    if blush > 0 {
        let color = rgb(0xFF8FA3, (0.3 + 0.4 * blush) * look.blushScale)
        let y = c.y + eyeOffsets[0].y + 9
        ctx.fillEllipse(CGPoint(x: c.x + eyeOffsets[0].x - 3, y: y), 5, 2.6, color)
        ctx.fillEllipse(CGPoint(x: c.x + eyeOffsets[1].x + 3, y: y), 5, 2.6, color)
        if look.extraBlush > 0.5 {   // little blush hatching
            for dx: CGFloat in [-2, 1, 4] {
                ctx.stroke({ p in
                    p.move(to: CGPoint(x: c.x + eyeOffsets[1].x + dx, y: y - 1.5)); p.addLine(to: CGPoint(x: c.x + eyeOffsets[1].x + dx - 1.5, y: y + 1.5))
                }, rgb(0xE86A86), 0.8)
            }
        }
    }
    if pose.puffCheek {
        ctx.fill({ $0.addEllipse(in: CGRect(x: c.x + 18, y: c.y + 9, width: 10, height: 10)) }, look.skin, outlineWidth: 1.2)
        ctx.fillEllipse(CGPoint(x: c.x + 23, y: c.y + 14), 3.5, 2.2, rgb(0xFF8FA3, 0.6))
    }

    drawFaceDetails(ctx, head: c, look: look)
    if look.muzzle { return }   // Nezuko's bamboo covers the mouth.
    drawMouth(ctx, CGPoint(x: c.x + 3, y: c.y + 15), pose.mouth)
}

/// Likeness details for the real-life caricatures: a nose, eye bags, cheekbones, a fuller jaw.
func drawFaceDetails(_ ctx: CGContext, head c: CGPoint, look: Look) {
    let line = rgb(0x4A2D3A, 0.45)
    if look.face.contains(.nose) {
        ctx.stroke({ p in
            p.move(to: CGPoint(x: c.x + 3.5, y: c.y + 6))
            p.addQuadCurve(to: CGPoint(x: c.x + 2, y: c.y + 11), control: CGPoint(x: c.x + 6, y: c.y + 10))
        }, line, 1.3)
    }
    if look.face.contains(.eyeBags) {
        for o in eyeOffsets {
            let e = CGPoint(x: c.x + o.x, y: c.y + o.y + 8 * look.eyeScale)
            ctx.stroke({ p in
                p.move(to: CGPoint(x: e.x - 3.5, y: e.y)); p.addQuadCurve(to: CGPoint(x: e.x + 3.5, y: e.y), control: CGPoint(x: e.x, y: e.y + 2.2))
            }, line, 0.9)
        }
    }
    if look.face.contains(.cheekbones) {
        for (o, side) in zip(eyeOffsets, [CGFloat(-1), 1]) {
            let x = c.x + o.x + side * 7
            ctx.stroke({ p in
                p.move(to: CGPoint(x: x, y: c.y + 8)); p.addQuadCurve(to: CGPoint(x: x - side * 2, y: c.y + 15), control: CGPoint(x: x + side, y: c.y + 12))
            }, line, 0.9)
        }
    }
    if look.face.contains(.jowls) {
        // Smile lines and a soft double chin.
        for side: CGFloat in [-1, 1] {
            let x = c.x + 3 + side * 7
            ctx.stroke({ p in
                p.move(to: CGPoint(x: x, y: c.y + 9)); p.addQuadCurve(to: CGPoint(x: x + side * 1.5, y: c.y + 17), control: CGPoint(x: x + side * 2.5, y: c.y + 12))
            }, line, 0.9)
        }
        ctx.stroke({ p in
            p.move(to: CGPoint(x: c.x - 3, y: c.y + 21.5)); p.addQuadCurve(to: CGPoint(x: c.x + 9, y: c.y + 21.5), control: CGPoint(x: c.x + 3, y: c.y + 23.5))
        }, line, 1)
    }
}

func drawMouth(_ ctx: CGContext, _ m: CGPoint, _ mouth: Mouth) {
    switch mouth {
    case .smile:
        ctx.stroke({ p in
            p.move(to: CGPoint(x: m.x - 3.5, y: m.y)); p.addQuadCurve(to: CGPoint(x: m.x + 3.5, y: m.y), control: CGPoint(x: m.x, y: m.y + 3.5))
        }, outline, 1.6)
    case .grin, .open:
        ctx.fill({ p in
            p.move(to: CGPoint(x: m.x - 5, y: m.y - 1))
            p.addLine(to: CGPoint(x: m.x + 5, y: m.y - 1))
            p.addQuadCurve(to: CGPoint(x: m.x - 5, y: m.y - 1), control: CGPoint(x: m.x, y: m.y + 9))
        }, mouthRed, outlineWidth: 1.4)
        ctx.fillEllipse(CGPoint(x: m.x, y: m.y + 3.5), 2.4, 1.4, rgb(0xFF9AAE))
    case .flat:
        ctx.stroke({ p in p.move(to: CGPoint(x: m.x - 3.5, y: m.y + 1)); p.addLine(to: CGPoint(x: m.x + 3.5, y: m.y + 1)) }, outline, 1.6)
    case .frown:
        ctx.stroke({ p in
            p.move(to: CGPoint(x: m.x - 4, y: m.y + 2)); p.addQuadCurve(to: CGPoint(x: m.x + 4, y: m.y + 2), control: CGPoint(x: m.x, y: m.y - 2))
        }, outline, 1.6)
    case .pout:
        ctx.stroke({ p in
            p.move(to: CGPoint(x: m.x - 3, y: m.y + 2)); p.addQuadCurve(to: CGPoint(x: m.x + 3, y: m.y + 2), control: CGPoint(x: m.x, y: m.y - 1.5))
        }, outline, 1.8)
    case .wavy:
        ctx.stroke({ p in
            p.move(to: CGPoint(x: m.x - 5, y: m.y + 1))
            p.addCurve(to: CGPoint(x: m.x + 5, y: m.y + 1),
                       control1: CGPoint(x: m.x - 2, y: m.y - 3), control2: CGPoint(x: m.x + 2, y: m.y + 5))
        }, outline, 1.6)
    case .o:
        ctx.fill({ $0.addEllipse(in: CGRect(x: m.x - 2.6, y: m.y - 1, width: 5.2, height: 6)) }, mouthRed, outlineWidth: 1.3)
    case .smirk:
        ctx.stroke({ p in
            p.move(to: CGPoint(x: m.x - 4, y: m.y + 1))
            p.addQuadCurve(to: CGPoint(x: m.x + 4.5, y: m.y - 1.5), control: CGPoint(x: m.x + 1, y: m.y + 3.5))
        }, outline, 1.7)
    case .yawn(let amount):
        let h = 3 + 9 * amount
        ctx.fill({ $0.addEllipse(in: CGRect(x: m.x - 3 - 2 * amount, y: m.y - 2, width: 6 + 4 * amount, height: h)) },
                 mouthRed, outlineWidth: 1.4)
    }
}

func drawOpenEye(_ ctx: CGContext, _ e: CGPoint, look lookX: CGFloat, lid: CGFloat, _ look: Look) {
    let rect = CGRect(x: e.x - 5.5, y: e.y - 7.5, width: 11, height: 15)
    ctx.saveGState()
    ctx.addEllipse(in: rect); ctx.clip()
    ctx.fillEllipse(e, 5.5, 7.5, white)
    let ic = CGPoint(x: e.x + lookX * 1.4, y: e.y + 0.8)
    ctx.saveGState()
    ctx.addEllipse(in: CGRect(x: ic.x - 4.6, y: ic.y - 6.4, width: 9.2, height: 12.8)); ctx.clip()
    let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                          colors: [look.irisDark, look.iris, look.irisLight] as CFArray, locations: [0, 0.6, 1])!
    ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: ic.y - 6.4), end: CGPoint(x: 0, y: ic.y + 6.4), options: [])
    ctx.restoreGState()
    ctx.fillEllipse(CGPoint(x: ic.x, y: ic.y + 0.5), 2.2, 3, look.irisDark)
    ctx.fillEllipse(CGPoint(x: ic.x - 1.6, y: ic.y - 2.6), 1.8, 1.8, white)
    ctx.fillEllipse(CGPoint(x: ic.x + 1.8, y: ic.y + 2.8), 0.9, 0.9, white)
    if lid > 0 {
        ctx.setFillColor(look.skin)
        ctx.fill(CGRect(x: rect.minX - 1, y: rect.minY - 1, width: rect.width + 2, height: rect.height * lid + 1))
    }
    ctx.restoreGState()
    let lashY = rect.minY + rect.height * lid
    ctx.stroke({ p in
        if lid > 0 {
            p.move(to: CGPoint(x: rect.minX - 0.5, y: lashY)); p.addLine(to: CGPoint(x: rect.maxX + 0.5, y: lashY))
        } else {
            p.addArc(center: e, radius: 6.5, startAngle: .pi * 1.12, endAngle: .pi * 1.88, clockwise: false)
        }
    }, outline, 2.2)
}

// MARK: - Effects (emote icons), each drawn centered in its frame

let effectNames = ["heart", "note", "anger", "zzz", "dots", "sweat", "exclaim", "sparkle", "code", "check",
                   // Not emotes: props and particles for the special moves.
                   "chest", "flower1", "flower2", "flower3", "flame", "glow", "puff",
                   "wall", "coin", "boom", "tank", "truck", "dog", "rabbit"]

func drawEffect(_ ctx: CGContext, _ index: Int) {
    let c = CGPoint(x: 64, y: 64)
    switch index {
    case 0: // heart
        ctx.fill({ p in
            p.move(to: CGPoint(x: c.x, y: c.y + 14))
            p.addCurve(to: CGPoint(x: c.x, y: c.y - 6), control1: CGPoint(x: c.x - 24, y: c.y - 2), control2: CGPoint(x: c.x - 12, y: c.y - 22))
            p.addCurve(to: CGPoint(x: c.x, y: c.y + 14), control1: CGPoint(x: c.x + 12, y: c.y - 22), control2: CGPoint(x: c.x + 24, y: c.y - 2))
        }, rgb(0xFF5C8A), outlineWidth: 2)
    case 1: // music note
        ctx.fill({ $0.addEllipse(in: CGRect(x: c.x - 12, y: c.y + 4, width: 12, height: 9)) }, rgb(0x5B8DEF), outlineWidth: 1.6)
        ctx.stroke({ p in p.move(to: CGPoint(x: c.x - 1, y: c.y + 8)); p.addLine(to: CGPoint(x: c.x - 1, y: c.y - 16)) }, outline, 2.4)
        ctx.stroke({ p in p.move(to: CGPoint(x: c.x - 1, y: c.y - 16)); p.addQuadCurve(to: CGPoint(x: c.x + 11, y: c.y - 4), control: CGPoint(x: c.x + 12, y: c.y - 14)) }, outline, 2.4)
    case 2: // anger vein
        for (dx, dy, rot) in [(-1.0, -1.0, 0.0), (1.0, -1.0, 0.5), (-1.0, 1.0, 1.5), (1.0, 1.0, 1.0)] {
            ctx.saveGState()
            ctx.translateBy(x: c.x + CGFloat(dx) * 7, y: c.y + CGFloat(dy) * 7)
            ctx.rotate(by: CGFloat(rot) * .pi)
            ctx.stroke({ p in
                p.move(to: CGPoint(x: -6, y: -1)); p.addQuadCurve(to: CGPoint(x: -1, y: -6), control: CGPoint(x: -1, y: -1))
            }, rgb(0xE5484D), 4)
            ctx.restoreGState()
        }
    case 3: // Zzz
        drawText(ctx, "Z", size: 22, at: CGPoint(x: c.x - 12, y: c.y + 10), color: rgb(0x6E7FD6))
        drawText(ctx, "z", size: 16, at: CGPoint(x: c.x + 4, y: c.y - 2), color: rgb(0x6E7FD6))
        drawText(ctx, "z", size: 12, at: CGPoint(x: c.x + 14, y: c.y - 12), color: rgb(0x6E7FD6))
    case 4: // dots
        for i in 0..<3 { ctx.fillEllipse(CGPoint(x: c.x - 10 + CGFloat(i) * 10, y: c.y), 3, 3, outline) }
    case 5: // sweat drop
        drawDrop(ctx, at: c, size: 2)
    case 6: // exclamation
        ctx.stroke({ p in p.move(to: CGPoint(x: c.x, y: c.y - 16)); p.addLine(to: CGPoint(x: c.x, y: c.y + 4)) }, rgb(0xFF9F1C), 6)
        ctx.fillEllipse(CGPoint(x: c.x, y: c.y + 13), 3.4, 3.4, rgb(0xFF9F1C))
    case 7: // sparkle
        ctx.fill({ p in
            p.move(to: CGPoint(x: c.x, y: c.y - 16))
            p.addQuadCurve(to: CGPoint(x: c.x + 16, y: c.y), control: c)
            p.addQuadCurve(to: CGPoint(x: c.x, y: c.y + 16), control: c)
            p.addQuadCurve(to: CGPoint(x: c.x - 16, y: c.y), control: c)
            p.addQuadCurve(to: CGPoint(x: c.x, y: c.y - 16), control: c)
        }, rgb(0xFFD84D), outlineWidth: 1.4)
    case 8: // code "</>"
        drawText(ctx, "</>", size: 20, at: CGPoint(x: c.x - 19, y: c.y + 7), color: rgb(0x5B8DEF))
    case 9: // check mark
        ctx.stroke({ p in
            p.move(to: CGPoint(x: c.x - 12, y: c.y)); p.addLine(to: CGPoint(x: c.x - 3, y: c.y + 10)); p.addLine(to: CGPoint(x: c.x + 14, y: c.y - 12))
        }, outline, 8)
        ctx.stroke({ p in
            p.move(to: CGPoint(x: c.x - 12, y: c.y)); p.addLine(to: CGPoint(x: c.x - 3, y: c.y + 10)); p.addLine(to: CGPoint(x: c.x + 14, y: c.y - 12))
        }, rgb(0x3DBE6A), 5)
    case 10: // Frieren's treasure chest (really a Mimic), standing where a character's feet would be
        ctx.translateBy(x: feet.x, y: feet.y)
        drawChest(ctx)
        fillStar(ctx, CGPoint(x: 19, y: -36), 5, rgb(0xFFF3A8))
    case 11, 12, 13: // flowers for Frieren's flower field; the stem ends at the bottom center
        let petals = [rgb(0xFF9EC4), white, rgb(0x9CC8FF)][index - 11]
        ctx.stroke({ p in p.move(to: CGPoint(x: 64, y: 124)); p.addQuadCurve(to: CGPoint(x: 64, y: 58), control: CGPoint(x: 56, y: 92)) }, outline, 9)
        ctx.stroke({ p in p.move(to: CGPoint(x: 64, y: 124)); p.addQuadCurve(to: CGPoint(x: 64, y: 58), control: CGPoint(x: 56, y: 92)) }, rgb(0x5DBB63), 5)
        for side: CGFloat in [-1, 1] {
            ctx.fill({ p in
                p.move(to: CGPoint(x: 61, y: 100))
                p.addQuadCurve(to: CGPoint(x: 61 + side * 26, y: 88), control: CGPoint(x: 61 + side * 16, y: 104))
                p.addQuadCurve(to: CGPoint(x: 61, y: 100), control: CGPoint(x: 61 + side * 12, y: 86))
            }, rgb(0x6ACB70), outlineWidth: 4)
        }
        let head = CGPoint(x: 64, y: 44)
        for k in 0..<5 {
            let a = CGFloat(k) / 5 * 2 * .pi - .pi / 2
            let c = CGPoint(x: head.x + cos(a) * 19, y: head.y + sin(a) * 19)
            ctx.fill({ $0.addEllipse(in: CGRect(x: c.x - 16, y: c.y - 16, width: 32, height: 32)) }, petals, outlineWidth: 4.5)
        }
        ctx.fill({ $0.addEllipse(in: CGRect(x: head.x - 13, y: head.y - 13, width: 26, height: 26)) }, rgb(0xFFD84D), outlineWidth: 4.5)
    case 14: // flame particle
        drawFlame(ctx, at: CGPoint(x: 64, y: 112), size: 100, colors: [rgb(0xE8336F), rgb(0xFF6FA8), rgb(0xFFE3EF, 0.9)])
    case 15: // soft glow particle
        let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                           colors: [rgb(0xFFFFFF), rgb(0xBFE0FF, 0.7), rgb(0x8DBBF7, 0)] as CFArray, locations: [0, 0.35, 1])!
        ctx.drawRadialGradient(g, startCenter: c, startRadius: 0, endCenter: c, endRadius: 60, options: [])
    case 16: // smoke puff
        for (dx, dy, r) in [(-22.0, 10.0, 26.0), (20.0, 12.0, 24.0), (0.0, -8.0, 32.0), (-4.0, 18.0, 24.0)] {
            ctx.fill({ $0.addEllipse(in: CGRect(x: c.x + CGFloat(dx) - CGFloat(r), y: c.y + CGFloat(dy) - CGFloat(r),
                                                width: CGFloat(r) * 2, height: CGFloat(r) * 2)) }, rgb(0xD8DCE6), outlineWidth: 0)
        }
        for (dx, dy, r) in [(-22.0, 6.0, 22.0), (20.0, 8.0, 20.0), (0.0, -12.0, 28.0), (-4.0, 14.0, 20.0)] {
            ctx.fillEllipse(CGPoint(x: c.x + CGFloat(dx), y: c.y + CGFloat(dy)), CGFloat(r), CGFloat(r), white)
        }
    case 17: // Trump's wall, filling the whole frame so the app can stretch it
        let mortar = rgb(0x8E6A55), brick = rgb(0xC2724E), brickLight = rgb(0xD98D66)
        ctx.setFillColor(mortar); ctx.fill(CGRect(x: 0, y: 14, width: 128, height: 114))
        let h: CGFloat = 13
        for row in 0..<9 {
            let y = 16 + CGFloat(row) * h
            let shift: CGFloat = row % 2 == 0 ? 0 : -13
            for col in 0..<6 {
                let r = CGRect(x: shift + CGFloat(col) * 26 + 1, y: y, width: 24, height: h - 2)
                ctx.setFillColor(row % 3 == col % 3 ? brickLight : brick); ctx.fill(r)
                ctx.setFillColor(rgb(0xFFFFFF, 0.18)); ctx.fill(CGRect(x: r.minX, y: r.minY, width: r.width, height: 2))
            }
        }
        // Concrete coping along the top.
        ctx.fill({ $0.addRoundedRect(in: CGRect(x: 1, y: 2, width: 126, height: 15), cornerWidth: 3, cornerHeight: 3) },
                 rgb(0xC9C3BA), outlineWidth: 2)
        ctx.setStrokeColor(outline); ctx.setLineWidth(3); ctx.stroke(CGRect(x: 1.5, y: 14, width: 125, height: 112.5))
        // A gold plaque, of course.
        ctx.fill({ $0.addRoundedRect(in: CGRect(x: 30, y: 50, width: 68, height: 24), cornerWidth: 4, cornerHeight: 4) },
                 rgb(0xF2C14E), outlineWidth: 2.4)
        drawText(ctx, "TRUMP", size: 13.5, at: CGPoint(x: 39, y: 67), color: rgb(0x7A5418))
    case 18: // gold coin
        ctx.fill({ $0.addEllipse(in: CGRect(x: 22, y: 22, width: 84, height: 84)) }, rgb(0xF2C14E), outlineWidth: 5)
        ctx.stroke({ $0.addEllipse(in: CGRect(x: 34, y: 34, width: 60, height: 60)) }, rgb(0xC9922E), 4)
        drawText(ctx, "$", size: 54, at: CGPoint(x: 49, y: 84), color: rgb(0x8A5A18))
    case 19: // comic "BOOM!" burst
        let star = CGMutablePath()
        for k in 0..<24 {
            let a = CGFloat(k) / 24 * 2 * .pi
            let r: CGFloat = k % 2 == 0 ? 62 : 40
            let p = CGPoint(x: c.x + cos(a) * r, y: c.y + sin(a) * r * 0.8)
            k == 0 ? star.move(to: p) : star.addLine(to: p)
        }
        star.closeSubpath()
        ctx.fill({ $0.addPath(star) }, rgb(0xFF5A3A), outlineWidth: 3.5)
        ctx.fill({ $0.addPath(star.copy(using: [CGAffineTransform(translationX: c.x, y: c.y).scaledBy(x: 0.72, y: 0.72)
            .translatedBy(x: -c.x, y: -c.y)])!) }, rgb(0xFFD84D), outlineWidth: 0)
        drawText(ctx, "BOOM!", size: 21, at: CGPoint(x: 26, y: 72), color: rgb(0xC2182E))
    case 20, 21: // parade vehicles, driving toward +x, wheels on the bottom edge
        let olive = rgb(0x5E6B3A), oliveDark = rgb(0x434D28), oliveLight = rgb(0x7D8C50)
        // Tracks or wheels.
        if index == 20 {
            ctx.fill({ $0.addRoundedRect(in: CGRect(x: 8, y: 96, width: 112, height: 26), cornerWidth: 13, cornerHeight: 13) },
                     rgb(0x3A3A3A), outlineWidth: 3)
            for k in 0..<6 { ctx.fill({ $0.addEllipse(in: CGRect(x: 14 + CGFloat(k) * 17.5, y: 100, width: 17, height: 17)) },
                                      rgb(0x8A8A8A), outlineWidth: 2) }
            // Hull, turret and the long gun.
            ctx.fill({ p in
                p.move(to: CGPoint(x: 4, y: 98)); p.addLine(to: CGPoint(x: 14, y: 76)); p.addLine(to: CGPoint(x: 112, y: 76))
                p.addLine(to: CGPoint(x: 124, y: 98)); p.closeSubpath()
            }, olive, outlineWidth: 3)
            ctx.fill({ $0.addRoundedRect(in: CGRect(x: 80, y: 61, width: 47, height: 7), cornerWidth: 3, cornerHeight: 3) },
                     oliveDark, outlineWidth: 2.5)
            ctx.fill({ $0.addRoundedRect(in: CGRect(x: 36, y: 50, width: 52, height: 28), cornerWidth: 12, cornerHeight: 12) },
                     oliveLight, outlineWidth: 3)
            ctx.fill({ $0.addRoundedRect(in: CGRect(x: 50, y: 42, width: 18, height: 10), cornerWidth: 4, cornerHeight: 4) },
                     oliveDark, outlineWidth: 2.5)
        } else {
            for x: CGFloat in [28, 66, 100] {
                ctx.fill({ $0.addEllipse(in: CGRect(x: x - 13, y: 96, width: 26, height: 26)) }, rgb(0x2E2E2E), outlineWidth: 3)
                ctx.fillEllipse(CGPoint(x: x, y: 109), 5, 5, rgb(0x9A9A9A))
            }
            // Armored body with a sloped nose and a flag mast.
            ctx.fill({ p in
                p.move(to: CGPoint(x: 6, y: 104)); p.addLine(to: CGPoint(x: 6, y: 58)); p.addLine(to: CGPoint(x: 84, y: 58))
                p.addLine(to: CGPoint(x: 122, y: 84)); p.addLine(to: CGPoint(x: 122, y: 104)); p.closeSubpath()
            }, olive, outlineWidth: 3)
            ctx.fill({ $0.addRoundedRect(in: CGRect(x: 86, y: 64, width: 18, height: 10), cornerWidth: 2, cornerHeight: 2) },
                     rgb(0x9FC3D6), outlineWidth: 2)
            ctx.stroke({ $0.move(to: CGPoint(x: 10, y: 84)); $0.addLine(to: CGPoint(x: 80, y: 84)) }, oliveDark, 3)
            ctx.stroke({ $0.move(to: CGPoint(x: 24, y: 58)); $0.addLine(to: CGPoint(x: 24, y: 14)) }, outline, 3.5)
            ctx.fill({ p in
                p.move(to: CGPoint(x: 24, y: 14)); p.addQuadCurve(to: CGPoint(x: 56, y: 22), control: CGPoint(x: 40, y: 10))
                p.addLine(to: CGPoint(x: 56, y: 38)); p.addQuadCurve(to: CGPoint(x: 24, y: 34), control: CGPoint(x: 40, y: 30))
                p.closeSubpath()
            }, rgb(0xE8423A), outlineWidth: 2.5)
        }
    case 22: // one of Megumi's Divine Dogs, running toward +x with its feet on the bottom edge
        let fur = rgb(0xF2F2F6), shade = rgb(0xC9CBD6)
        for (x, back) in [(30.0, true), (88.0, true), (40.0, false), (98.0, false)] {
            ctx.stroke({ p in p.move(to: CGPoint(x: x, y: 86)); p.addLine(to: CGPoint(x: x + (back ? -8 : 8), y: 118)) }, outline, 12)
            ctx.stroke({ p in p.move(to: CGPoint(x: x, y: 86)); p.addLine(to: CGPoint(x: x + (back ? -8 : 8), y: 118)) }, back ? shade : fur, 8)
        }
        ctx.fill({ p in
            p.move(to: CGPoint(x: 18, y: 70)); p.addLine(to: CGPoint(x: 4, y: 52)); p.addLine(to: CGPoint(x: 22, y: 62)); p.closeSubpath()
        }, fur, outlineWidth: 3)
        ctx.fill({ $0.addRoundedRect(in: CGRect(x: 16, y: 60, width: 86, height: 36), cornerWidth: 18, cornerHeight: 18) }, fur, outlineWidth: 3.5)
        ctx.fill({ $0.addEllipse(in: CGRect(x: 82, y: 34, width: 40, height: 38)) }, fur, outlineWidth: 3.5)
        ctx.fill({ p in
            p.move(to: CGPoint(x: 88, y: 42)); p.addLine(to: CGPoint(x: 92, y: 18)); p.addLine(to: CGPoint(x: 104, y: 38)); p.closeSubpath()
        }, fur, outlineWidth: 3)
        ctx.fill({ $0.addRoundedRect(in: CGRect(x: 108, y: 52, width: 18, height: 14), cornerWidth: 6, cornerHeight: 6) }, fur, outlineWidth: 3)
        ctx.fillEllipse(CGPoint(x: 124, y: 56), 3.5, 3, outline)
        // Black markings across the eye, like a shikigami's pattern.
        ctx.fill({ p in
            p.move(to: CGPoint(x: 96, y: 46)); p.addLine(to: CGPoint(x: 118, y: 44)); p.addLine(to: CGPoint(x: 112, y: 54)); p.closeSubpath()
        }, rgb(0x2A2A30), outlineWidth: 0)
        ctx.fillEllipse(CGPoint(x: 110, y: 48), 2.5, 2.5, rgb(0xFFD84D))
    case 23: // one of Megumi's rabbits, hopping toward +x
        let fur = white
        ctx.fill({ $0.addEllipse(in: CGRect(x: 30, y: 74, width: 58, height: 46)) }, fur, outlineWidth: 4)
        ctx.fill({ $0.addEllipse(in: CGRect(x: 24, y: 82, width: 16, height: 16)) }, fur, outlineWidth: 3.5)
        ctx.fill({ $0.addEllipse(in: CGRect(x: 70, y: 52, width: 40, height: 38)) }, fur, outlineWidth: 4)
        for (x, tilt) in [(78.0, -0.3), (92.0, 0.15)] {
            ctx.saveGState()
            ctx.translateBy(x: CGFloat(x), y: 56)
            ctx.rotate(by: CGFloat(tilt))
            ctx.fill({ $0.addEllipse(in: CGRect(x: -7, y: -44, width: 14, height: 46)) }, fur, outlineWidth: 3.5)
            ctx.fillEllipse(CGPoint(x: 0, y: -22), 3.5, 14, rgb(0xFFB3C6))
            ctx.restoreGState()
        }
        ctx.fillEllipse(CGPoint(x: 98, y: 68), 4, 4.5, outline)
        ctx.fillEllipse(CGPoint(x: 108, y: 78), 3, 2.4, rgb(0xFF8FA3))
    default: break
    }
}
