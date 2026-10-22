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
        ctx.saveGState()
        if look.caricature {
            // Pale patches around small eyes.
            ctx.fillEllipse(CGPoint(x: e.x, y: e.y + 0.5), 8.5, 7, rgb(0xFFDCC0, 0.95))
            ctx.translateBy(x: e.x, y: e.y); ctx.scaleBy(x: 0.68, y: 0.6); ctx.translateBy(x: -e.x, y: -e.y)
        }
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
        let x = c.x + o.x, y = c.y + o.y - 11
        if look.caricature {
            drawHeavyBrow(ctx, x: x, y: y + 2, inner: inner, pose.brows, look)
            continue
        }
        switch pose.brows {
        case .none: break
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
        let color = rgb(0xFF8FA3, 0.3 + 0.4 * blush)
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

    if look.muzzle { return }   // Nezuko's bamboo covers the mouth.
    if look.caricature { return drawCaricatureMouth(ctx, CGPoint(x: c.x + 3, y: c.y + 15), pose.mouth) }
    var mouth = pose.mouth
    if look.smirk, case .smile = mouth { mouth = .smirk }
    drawMouth(ctx, CGPoint(x: c.x + 3, y: c.y + 15), mouth)
}

/// A thick brow in the hair color, scowling unless the pose says otherwise.
func drawHeavyBrow(_ ctx: CGContext, x: CGFloat, y: CGFloat, inner: CGFloat, _ brows: Brows, _ look: Look) {
    let from: CGPoint, to: CGPoint, control: CGPoint
    switch brows {
    case .raised:
        from = CGPoint(x: x - inner * 6, y: y - 1); to = CGPoint(x: x + inner * 5, y: y - 1); control = CGPoint(x: x, y: y - 7)
    case .sad:
        from = CGPoint(x: x - inner * 6, y: y + 1); to = CGPoint(x: x + inner * 5, y: y - 3); control = CGPoint(x: x, y: y - 3)
    case .angry:
        from = CGPoint(x: x - inner * 6, y: y - 4); to = CGPoint(x: x + inner * 5, y: y + 3); control = CGPoint(x: x, y: y - 2)
    case .none:
        from = CGPoint(x: x - inner * 6, y: y - 2); to = CGPoint(x: x + inner * 5, y: y + 1); control = CGPoint(x: x, y: y - 3)
    }
    for (color, width) in [(outline, CGFloat(5.4)), (look.hair, CGFloat(3.6))] {
        ctx.stroke({ $0.move(to: from); $0.addQuadCurve(to: to, control: control) }, color, width)
    }
}

/// Pursed lips at rest; a wide-open shout for the open-mouthed expressions.
func drawCaricatureMouth(_ ctx: CGContext, _ m: CGPoint, _ mouth: Mouth) {
    let lip = rgb(0xD9786A)
    switch mouth {
    case .open, .grin, .o, .yawn:
        ctx.fill({ $0.addEllipse(in: CGRect(x: m.x - 5.5, y: m.y - 3, width: 11, height: 11)) }, lip, outlineWidth: 1.4)
        ctx.fill({ $0.addEllipse(in: CGRect(x: m.x - 3.8, y: m.y - 1.5, width: 7.6, height: 8)) }, rgb(0x4A1A22), outlineWidth: 0)
        ctx.fillEllipse(CGPoint(x: m.x, y: m.y - 0.6), 3, 1, white)
        ctx.fillEllipse(CGPoint(x: m.x, y: m.y + 4.5), 2.2, 1.2, rgb(0xE07A86))
    case .frown, .wavy, .pout:
        ctx.fill({ $0.addEllipse(in: CGRect(x: m.x - 4.5, y: m.y - 1, width: 9, height: 5)) }, lip, outlineWidth: 1.2)
        ctx.stroke({ p in p.move(to: CGPoint(x: m.x - 2.5, y: m.y + 2)); p.addQuadCurve(to: CGPoint(x: m.x + 2.5, y: m.y + 2), control: CGPoint(x: m.x, y: m.y)) }, outline, 1)
    case .smile, .flat, .smirk:
        // Pushed-out pucker.
        ctx.fill({ $0.addEllipse(in: CGRect(x: m.x - 3.5, y: m.y - 1.5, width: 7, height: 5.5)) }, lip, outlineWidth: 1.2)
        ctx.fillEllipse(CGPoint(x: m.x, y: m.y + 1.2), 1.4, 1, rgb(0x6A2A30))
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
                   "fish", "panda"]

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
    case 17: // Putin's catch, wriggling above his head
        ctx.saveGState()
        ctx.translateBy(x: c.x, y: c.y)
        ctx.rotate(by: -0.35)
        ctx.fill({ p in
            p.move(to: CGPoint(x: 14, y: 0)); p.addLine(to: CGPoint(x: 26, y: -10)); p.addLine(to: CGPoint(x: 24, y: 0))
            p.addLine(to: CGPoint(x: 26, y: 10)); p.closeSubpath()
        }, rgb(0x6E9CC4), outlineWidth: 2)
        ctx.fillGradient({ $0.addEllipse(in: CGRect(x: -22, y: -11, width: 40, height: 22)) }, [rgb(0x9CC4E6), rgb(0xDCEBF7)],
                         from: -11, to: 11, outlineWidth: 2)
        ctx.stroke({ p in p.move(to: CGPoint(x: -8, y: -10)); p.addQuadCurve(to: CGPoint(x: -8, y: 10), control: CGPoint(x: -3, y: 0)) }, rgb(0x6E9CC4), 1.6)
        ctx.fillEllipse(CGPoint(x: -14, y: -3), 3, 3, white)
        ctx.fillEllipse(CGPoint(x: -14, y: -3), 1.6, 1.6, outline)
        ctx.restoreGState()
        drawDrop(ctx, at: CGPoint(x: c.x - 24, y: c.y - 14), size: 1.1)
        drawDrop(ctx, at: CGPoint(x: c.x + 22, y: c.y + 16), size: 0.9)
    case 18: // a giant panda sitting beside Xi, standing where a character's feet would be
        ctx.translateBy(x: feet.x, y: feet.y)
        ctx.fillEllipse(.zero, 22, 4.5, rgb(0x000000, 0.18))
        let black = rgb(0x2B2B33)
        for side: CGFloat in [-1, 1] {   // feet, then arms holding bamboo
            ctx.fill({ $0.addEllipse(in: CGRect(x: side * 13 - 7, y: -11, width: 14, height: 11)) }, black, outlineWidth: 1.4)
        }
        ctx.fill({ $0.addEllipse(in: CGRect(x: -17, y: -40, width: 34, height: 36)) }, white, outlineWidth: 1.6)
        ctx.stroke({ $0.move(to: CGPoint(x: 9, y: -12)); $0.addLine(to: CGPoint(x: 15, y: -58)) }, outline, 5)
        ctx.stroke({ $0.move(to: CGPoint(x: 9, y: -12)); $0.addLine(to: CGPoint(x: 15, y: -58)) }, rgb(0x7CC46A), 3)
        ctx.fill({ p in
            p.move(to: CGPoint(x: 15, y: -56)); p.addQuadCurve(to: CGPoint(x: 26, y: -64), control: CGPoint(x: 24, y: -56)); p.closeSubpath()
        }, rgb(0x6ACB70), outlineWidth: 1)
        for side: CGFloat in [-1, 1] {
            ctx.fill({ $0.addEllipse(in: CGRect(x: side * 10 - 5.5, y: -35, width: 11, height: 16)) }, black, outlineWidth: 1.2)
        }
        let head = CGPoint(x: 0, y: -52)
        for side: CGFloat in [-1, 1] {
            ctx.fill({ $0.addEllipse(in: CGRect(x: head.x + side * 12 - 5, y: head.y - 17, width: 10, height: 10)) }, black, outlineWidth: 1.2)
        }
        ctx.fill({ $0.addEllipse(in: CGRect(x: head.x - 16, y: head.y - 14, width: 32, height: 27)) }, white, outlineWidth: 1.6)
        for side: CGFloat in [-1, 1] {
            ctx.saveGState()
            ctx.translateBy(x: head.x + side * 6.5, y: head.y - 1)
            ctx.rotate(by: side * 0.5)
            ctx.fillEllipse(.zero, 4, 5.5, black)
            ctx.restoreGState()
            ctx.fillEllipse(CGPoint(x: head.x + side * 6, y: head.y - 2), 1.5, 1.5, white)
        }
        ctx.fillEllipse(CGPoint(x: head.x, y: head.y + 5), 2.4, 1.6, black)
        ctx.stroke({ p in
            p.move(to: CGPoint(x: head.x - 3, y: head.y + 8)); p.addQuadCurve(to: CGPoint(x: head.x + 3, y: head.y + 8), control: CGPoint(x: head.x, y: head.y + 10))
        }, black, 1)
        ctx.fillEllipse(CGPoint(x: head.x - 10, y: head.y + 5), 3, 1.6, rgb(0xFF8FA3, 0.6))
        ctx.fillEllipse(CGPoint(x: head.x + 10, y: head.y + 5), 3, 1.6, rgb(0xFF8FA3, 0.6))
    default: break
    }
}
