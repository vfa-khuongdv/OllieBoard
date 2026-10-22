import AppKit

// The two special-move rows ("skill1", "skill2") hold a different move for each character,
// props included. Agent mascots have no special moves, so their skill rows stay empty.

/// Both rows loop at 8 fps; the app plays a move that shouldn't loop for exactly one cycle (or holds its last frame).
func skillAnimation(_ which: Int) -> Animation {
    Animation(name: "skill\(which)", fps: 8, loop: true, frames: (0..<8).map { i in
        var p = Pose()
        p.skill = (which, i)
        return p
    })
}

func drawSkill(_ ctx: CGContext, _ look: Look, _ which: Int, _ i: Int) {
    switch (look.style, which) {
    case (.anya, 1): anyaTelepathy(ctx, look, i)
    case (.anya, 2): anyaSmug(ctx, look, i)
    case (.nezuko, 1): nezukoBurst(ctx, look, i)
    case (.nezuko, 2): nezukoWindup(ctx, look, i)
    case (.frieren, 1): frierenCast(ctx, look, i)
    case (.frieren, 2): frierenMimic(ctx, look, i)
    case (.bocchi, 1): bocchiGuitar(ctx, look, i)
    case (.bocchi, 2): bocchiMelt(ctx, look, i)
    case (.rem, 1): remMorningStar(ctx, look, i)
    case (.rem, 2): remOni(ctx, look, i)
    case (.trump, 1): trumpSpeech(ctx, look, i)
    case (.trump, 2): trumpFired(ctx, look, i)
    case (.putin, 1): putinJudo(ctx, look, i)
    case (.putin, 2): putinFishing(ctx, look, i)
    case (.xi, 1): xiFootball(ctx, look, i)
    case (.xi, 2): xiWave(ctx, look, i)
    default: break
    }
}

// MARK: - Helpers

/// Runs `draw` in the space drawCharacter draws the body in: origin at the feet, y down, after bob and lean.
private func inBody(_ ctx: CGContext, _ pose: Pose, _ draw: () -> Void) {
    ctx.saveGState()
    ctx.translateBy(x: feet.x, y: feet.y + pose.bob + (pose.sitting ? 15 : 0))
    ctx.rotate(by: pose.lean)
    draw()
    ctx.restoreGState()
}

/// Where a hand ends up for an arm angle (same geometry as drawCharacter's arms).
private func hand(_ angle: CGFloat, front: Bool) -> CGPoint {
    CGPoint(x: (front ? 9 : -9) + sin(angle) * 15, y: -44 + cos(angle) * 15)
}

private func drawHand(_ ctx: CGContext, _ p: CGPoint, _ look: Look, dark: Bool = false) {
    ctx.fill({ $0.addEllipse(in: CGRect(x: p.x - 3.4, y: p.y - 3.4, width: 6.8, height: 6.8)) },
             dark ? look.skinShade : look.skin, outlineWidth: 1.2)
}

/// Redraws an arm on top of a prop that was drawn over it.
private func drawArm(_ ctx: CGContext, _ angle: CGFloat, _ look: Look, front: Bool) {
    limb(ctx, from: CGPoint(x: front ? 9 : -9, y: -44), angle: angle, length: 15, width: 5,
         color: front ? look.sleeve : look.sleeveDark) { hand in
        drawCuff(ctx, hand: hand, angle: angle, look)
        drawHand(ctx, hand, look, dark: !front)
    }
}

/// A teardrop flame `size` tall, rising from `base` (the bottom of its round end).
func drawFlame(_ ctx: CGContext, at base: CGPoint, size s: CGFloat, lean: CGFloat = 0, colors: [CGColor]) {
    let w = s * 0.32
    let tip = CGPoint(x: base.x + lean * s, y: base.y - s)
    let path = CGMutablePath()
    path.move(to: tip)
    path.addQuadCurve(to: CGPoint(x: base.x + w, y: base.y - w), control: CGPoint(x: base.x + w * 1.15, y: base.y - s * 0.55))
    path.addArc(center: CGPoint(x: base.x, y: base.y - w), radius: w, startAngle: 0, endAngle: .pi, clockwise: false)
    path.addQuadCurve(to: tip, control: CGPoint(x: base.x - w * 1.15, y: base.y - s * 0.55))
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
    ctx.drawLinearGradient(g, start: base, end: tip, options: [])
    ctx.restoreGState()
}

let nezukoFlame = [rgb(0xE8336F, 0.95), rgb(0xFF6FA8, 0.9), rgb(0xFFD6E8, 0.7)]

// MARK: - Anya: telepathy and the smug "heh"

private func anyaTelepathy(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    let reach: CGFloat = i % 4 < 2 ? 0 : 0.12
    p.armFront = 2.5 + reach; p.armBack = -2.5 - reach
    p.eyes = .sparkle; p.mouth = .open; p.blush = 1
    p.bob = [0, -1, -2, -1, 0, -1, -2, -1][i]
    drawCharacter(ctx, p, look)
    // Waves coming off the hair ornaments.
    inBody(ctx, p) {
        let pulse = CGFloat(i % 4) / 3
        for side: CGFloat in [-1, 1] {
            for k in 0..<2 {
                let r = 9 + CGFloat(k) * 7 + pulse * 4
                ctx.stroke({ path in
                    path.addArc(center: CGPoint(x: side * 20, y: -106), radius: r,
                                startAngle: side > 0 ? -.pi / 2 : -.pi, endAngle: side > 0 ? 0 : -.pi / 2, clockwise: false)
                }, rgb(0xFF6FA8, 0.95 - CGFloat(k) * 0.35), 2.2)
            }
        }
    }
}

private func anyaSmug(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.eyes = .half; p.mouth = .smirk; p.brows = .raised; p.blush = 0.8
    p.armFront = -0.45; p.armBack = 0.45   // hands on hips
    p.tilt = -0.06
    p.bob = i % 4 < 2 ? 0 : -0.8
    drawCharacter(ctx, p, look)
    if (2...5).contains(i) {
        inBody(ctx, p) { fillStar(ctx, CGPoint(x: 31, y: -96), i == 3 || i == 4 ? 5 : 3, rgb(0xFFD84D)) }
    }
}

// MARK: - Nezuko: Exploding Blood (wind-up, then the burst)

private func nezukoWindup(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.bob = 4; p.legFront = 0.45; p.legBack = -0.45
    p.armFront = 0.75; p.armBack = 0.65
    p.eyes = .angry; p.brows = .angry; p.blush = 0.8
    p.hairSwing = [0, 0.03, 0.05, 0.03, 0, -0.03, -0.05, -0.03][i]
    p.lean = 0.05
    let flicker = CGFloat([0, 2, 4, 2, 0, 3, 1, 2][i])
    inBody(ctx, p) {
        for (x, y, s) in [(-22.0, -4.0, 12.0), (20.0, -2.0, 10.0), (-30.0, -38.0, 9.0)] {
            drawFlame(ctx, at: CGPoint(x: x, y: y), size: CGFloat(s) + flicker, colors: nezukoFlame)
        }
    }
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let h = hand(p.armFront, front: true)
        drawFlame(ctx, at: CGPoint(x: h.x + 2, y: h.y + 3), size: 14 + flicker, colors: nezukoFlame)
    }
}

private func nezukoBurst(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = 2.3; p.armBack = -2.3
    p.legFront = 0.35; p.legBack = -0.35
    p.eyes = .angry; p.brows = .angry; p.blush = 1
    p.hairSwing = i % 2 == 0 ? 0.1 : -0.06
    p.bob = i % 2 == 0 ? -2 : 0
    // A ring of flame tongues behind her...
    inBody(ctx, p) {
        for k in 0..<10 {
            let a = CGFloat(k) / 10 * 2 * .pi
            let size = 18 + CGFloat((k * 7 + i * 3) % 5) * 3
            drawFlame(ctx, at: CGPoint(x: cos(a) * 34, y: -48 + sin(a) * 38), size: size, lean: cos(a) * 0.3, colors: nezukoFlame)
        }
    }
    drawCharacter(ctx, p, look)
    // ...and a few licking up in front.
    inBody(ctx, p) {
        for (k, x) in [-18.0, 4.0, 22.0].enumerated() {
            drawFlame(ctx, at: CGPoint(x: x, y: 2), size: 12 + CGFloat((k + i) % 3) * 4, colors: nezukoFlame)
        }
    }
}

// MARK: - Frieren: the flower-field spell and the Mimic

private func frierenCast(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = 2.25; p.armBack = 0.35
    p.eyes = .closed; p.mouth = .flat; p.blush = 0.3
    p.hairSwing = [0, 0.02, 0.04, 0.02, 0, -0.02, -0.04, -0.02][i]
    p.bob = [0, -0.5, -1, -0.5, 0, -0.5, -1, -0.5][i]
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let h = hand(p.armFront, front: true)
        drawStaff(ctx, grip: h, glow: 0.5 + 0.5 * sin(CGFloat(i) / 8 * 2 * .pi))
        drawHand(ctx, h, look)
        for k in 0..<3 {
            let t = CGFloat((i + k * 3) % 8) / 8
            fillStar(ctx, CGPoint(x: h.x - 4 + CGFloat(k) * 7, y: h.y - 52 - t * 16), 3.5 * (1 - t) + 1, rgb(0xFFF3A8, 1 - t * 0.8))
        }
    }
}

/// Frieren's staff: a wooden shaft topped by a golden crescent holding a red gem.
private func drawStaff(_ ctx: CGContext, grip: CGPoint, glow: CGFloat) {
    let bottom = CGPoint(x: grip.x - 2, y: grip.y + 30), top = CGPoint(x: grip.x + 3, y: grip.y - 40)
    ctx.stroke({ $0.move(to: bottom); $0.addLine(to: top) }, outline, 5.4)
    ctx.stroke({ $0.move(to: bottom); $0.addLine(to: top) }, rgb(0x9B6A43), 3)
    let gem = CGPoint(x: top.x + 0.5, y: top.y - 8)
    ctx.fillEllipse(gem, 9 + glow * 5, 9 + glow * 5, rgb(0xFF8A8A, 0.2 + 0.25 * glow))
    for (color, width) in [(outline, CGFloat(4.8)), (rgb(0xE3B341), CGFloat(2.6))] {
        ctx.stroke({ $0.addArc(center: gem, radius: 7.5, startAngle: -.pi * 0.1, endAngle: .pi * 1.1, clockwise: false) }, color, width)
    }
    ctx.fill({ $0.addEllipse(in: CGRect(x: gem.x - 4.5, y: gem.y - 4.5, width: 9, height: 9)) }, rgb(0xD83A3A), outlineWidth: 1.3)
    ctx.fillEllipse(CGPoint(x: gem.x - 1.5, y: gem.y - 1.5), 1.5, 1.5, rgb(0xFFFFFF, 0.9))
}

/// Wooden chest with gold bands standing on the origin; `open` leaves the lid off (the Mimic's mouth is drawn separately).
func drawChest(_ ctx: CGContext, open: Bool = false) {
    ctx.fillEllipse(.zero, 31, 4.5, rgb(0x000000, 0.18))
    let gold = rgb(0xE3B341)
    let box = CGRect(x: -26, y: -28, width: 52, height: 28)
    ctx.fillGradient({ $0.addRoundedRect(in: box, cornerWidth: 3, cornerHeight: 3) }, [rgb(0xB8743E), rgb(0x8A5228)],
                     from: box.minY, to: box.maxY)
    for y: CGFloat in [-19, -10] {
        ctx.stroke({ $0.move(to: CGPoint(x: -25, y: y)); $0.addLine(to: CGPoint(x: 25, y: y)) }, rgb(0x6E3F1D, 0.7), 1)
    }
    for x: CGFloat in [-18, 14] {
        ctx.fill({ $0.addRect(CGRect(x: x, y: -28, width: 4, height: 28)) }, gold, outlineWidth: 1)
    }
    if open { return }
    ctx.fillGradient({ p in
        p.move(to: CGPoint(x: -26, y: -27)); p.addLine(to: CGPoint(x: -26, y: -33))
        p.addQuadCurve(to: CGPoint(x: 26, y: -33), control: CGPoint(x: 0, y: -50))
        p.addLine(to: CGPoint(x: 26, y: -27)); p.closeSubpath()
    }, [rgb(0xC98450), rgb(0x9A5A2C)], from: -45, to: -27)
    ctx.fill({ $0.addRoundedRect(in: CGRect(x: -4.5, y: -33, width: 9, height: 10), cornerWidth: 2, cornerHeight: 2) }, gold, outlineWidth: 1)
    ctx.fillEllipse(CGPoint(x: 0, y: -29.5), 1.4, 2.2, rgb(0x3A2A20))
}

private func frierenMimic(_ ctx: CGContext, _ look: Look, _ i: Int) {
    let shake: [CGFloat] = [-1.5, 1.5, -1, 1.5, -1.5, 1, -1, 1.5]
    ctx.saveGState()
    ctx.translateBy(x: feet.x + shake[i], y: feet.y)
    // Only her legs stick out, kicking.
    let kick = sin(CGFloat(i) / 4 * 2 * .pi) * 0.4
    drawMimicMouth(ctx)
    for (x, angle, dark) in [(-4.0, CGFloat.pi + 0.25 + kick, true), (4.0, CGFloat.pi - 0.25 - kick, false)] {
        limb(ctx, from: CGPoint(x: x, y: -44), angle: angle, length: 23, width: 6, color: dark ? look.skinShade : look.skin) { foot in
            ctx.fillEllipse(CGPoint(x: foot.x, y: foot.y + 3), 3.6, 3, look.sock)
            ctx.saveGState()
            ctx.translateBy(x: foot.x, y: foot.y)
            ctx.rotate(by: .pi - angle * 0.5)
            ctx.fill({ $0.addEllipse(in: CGRect(x: -4, y: -2, width: 10, height: 6)) }, look.shoe, outlineWidth: 1.2)
            ctx.restoreGState()
        }
    }
    // The robe, upside down: waist in the chest, hem flaring up around her legs.
    ctx.fill({ p in
        p.move(to: CGPoint(x: -10, y: -27)); p.addLine(to: CGPoint(x: -16, y: -47))
        p.addQuadCurve(to: CGPoint(x: 16, y: -47), control: CGPoint(x: 0, y: -51))
        p.addLine(to: CGPoint(x: 10, y: -27)); p.closeSubpath()
    }, look.sleeve)
    ctx.stroke({ p in
        p.move(to: CGPoint(x: -15, y: -43)); p.addQuadCurve(to: CGPoint(x: 15, y: -43), control: CGPoint(x: 0, y: -47))
    }, rgb(0xE3B341), 1.8)
    drawChest(ctx, open: true)
    // Teeth on the box's rim, biting down on her.
    for k in 0..<8 {
        let x = -21 + CGFloat(k) * 6
        ctx.fill({ p in
            p.move(to: CGPoint(x: x - 3, y: -27)); p.addLine(to: CGPoint(x: x + 3, y: -27)); p.addLine(to: CGPoint(x: x, y: -33))
            p.closeSubpath()
        }, white, outlineWidth: 1)
    }
    if i % 2 == 0 {   // flailing lines
        for side: CGFloat in [-1, 1] {
            ctx.stroke({ p in
                p.move(to: CGPoint(x: side * 20, y: -66)); p.addLine(to: CGPoint(x: side * 26, y: -71))
                p.move(to: CGPoint(x: side * 21, y: -57)); p.addLine(to: CGPoint(x: side * 28, y: -59))
            }, outline, 1.6)
        }
    }
    ctx.restoreGState()
}

/// The Mimic's open mouth behind her legs: the lid swung up, its dark inside and the upper teeth along its rim.
private func drawMimicMouth(_ ctx: CGContext) {
    ctx.fill({ p in
        p.move(to: CGPoint(x: -27, y: -29))
        p.addQuadCurve(to: CGPoint(x: 27, y: -29), control: CGPoint(x: 0, y: -70))
        p.addQuadCurve(to: CGPoint(x: -27, y: -29), control: CGPoint(x: 0, y: -52))
    }, rgb(0x9A5A2C))
    ctx.fill({ p in
        p.move(to: CGPoint(x: -24, y: -30))
        p.addQuadCurve(to: CGPoint(x: 24, y: -30), control: CGPoint(x: 0, y: -52))
        p.closeSubpath()
    }, rgb(0x3A1A22), outlineWidth: 1.2)
    for k in 0..<7 {
        // Points on the rim curve, pointing down into the mouth.
        let t = (CGFloat(k) + 0.5) / 7
        let x = -24 + 48 * t, y = -30 - 44 * t * (1 - t)
        ctx.fill({ p in
            p.move(to: CGPoint(x: x - 3, y: y)); p.addLine(to: CGPoint(x: x + 3, y: y)); p.addLine(to: CGPoint(x: x, y: y + 6))
            p.closeSubpath()
        }, white, outlineWidth: 1)
    }
}

// MARK: - Bocchi: guitar solo and melting

private func bocchiGuitar(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = [0.5, 0.25, 0.5, 0.25, 0.55, 0.2, 0.5, 0.3][i]; p.armBack = -2.1
    p.legFront = 0.15; p.legBack = -0.15
    p.eyes = .half; p.mouth = .flat; p.blush = 0.4
    p.tilt = [0, 0.05, 0.09, 0.05, 0, 0.05, 0.09, 0.05][i]
    p.hairSwing = [0, 0.04, 0.07, 0.04, 0, 0.04, 0.07, 0.04][i]
    p.bob = [0, -1, -1.5, -1, 0, -1, -1.5, -1][i]
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        drawGuitar(ctx)
        drawHand(ctx, hand(p.armBack, front: false), look, dark: true)   // fretting hand over the neck
        drawArm(ctx, p.armFront, look, front: true)                     // strumming arm over the body
    }
}

/// Bocchi's black Les Paul, slung across the body with the neck pointing up behind her.
private func drawGuitar(_ ctx: CGContext) {
    ctx.saveGState()
    ctx.translateBy(x: 6, y: -29)
    ctx.rotate(by: 0.6)
    ctx.fill({ $0.addRect(CGRect(x: -40, y: -2, width: 32, height: 4)) }, rgb(0x5A3A24), outlineWidth: 1.2)
    ctx.fill({ $0.addRoundedRect(in: CGRect(x: -49, y: -3.5, width: 10, height: 7), cornerWidth: 2, cornerHeight: 2) },
             rgb(0x1E1E24), outlineWidth: 1.2)
    for x: CGFloat in [-47, -42.5] {
        ctx.fillEllipse(CGPoint(x: x, y: -4.6), 1.3, 1.3, rgb(0xE3B341))
        ctx.fillEllipse(CGPoint(x: x, y: 4.6), 1.3, 1.3, rgb(0xE3B341))
    }
    // Body: upper and lower bouts with cream binding.
    let body = CGMutablePath()
    body.addEllipse(in: CGRect(x: -10, y: -8, width: 15, height: 16))
    body.addEllipse(in: CGRect(x: -2, y: -10.5, width: 20, height: 21))
    ctx.addPath(body); ctx.setStrokeColor(outline); ctx.setLineWidth(5.2); ctx.strokePath()
    ctx.addPath(body); ctx.setStrokeColor(rgb(0xF2E8D0)); ctx.setLineWidth(3); ctx.strokePath()
    ctx.addPath(body); ctx.setFillColor(rgb(0x1E1E24)); ctx.fillPath()
    for x: CGFloat in [0.5, 7] {
        ctx.fill({ $0.addRoundedRect(in: CGRect(x: x, y: -4, width: 4, height: 8), cornerWidth: 1, cornerHeight: 1) },
                 rgb(0xF2E8D0), outlineWidth: 0.8)
    }
    ctx.fill({ $0.addRect(CGRect(x: 12.5, y: -3, width: 2, height: 6)) }, rgb(0xE3B341), outlineWidth: 0)
    for y: CGFloat in [-1.2, 0, 1.2] {
        ctx.stroke({ $0.move(to: CGPoint(x: -40, y: y)); $0.addLine(to: CGPoint(x: 13.5, y: y)) }, rgb(0xDADDE4, 0.8), 0.4)
    }
    for (x, y) in [(13.0, 6.5), (9.0, 7.5)] { ctx.fillEllipse(CGPoint(x: x, y: y), 1.4, 1.4, rgb(0xE3B341)) }
    ctx.restoreGState()
}

private func bocchiMelt(_ ctx: CGContext, _ look: Look, _ i: Int) {
    if i >= 5 { return drawPuddle(ctx, look, i) }
    var p = Pose()
    p.eyes = .wide; p.mouth = .wavy; p.brows = .sad; p.sweat = true; p.blush = 0.2
    p.armFront = 0.9; p.armBack = 1.1
    let sy: CGFloat = [1, 0.86, 0.68, 0.5, 0.34][i], sx = 1 + (1 - sy) * 0.55
    if i > 0 {
        let rx = 16 + (1 - sy) * 30
        ctx.saveGState()
        ctx.translateBy(x: feet.x, y: feet.y)
        ctx.fill({ $0.addEllipse(in: CGRect(x: -rx, y: -5, width: rx * 2, height: 9)) }, look.hair, outlineWidth: 1.4)
        ctx.restoreGState()
    }
    ctx.saveGState()
    ctx.translateBy(x: feet.x + (i == 0 ? 1.5 : 0), y: feet.y)
    ctx.scaleBy(x: sx, y: sy)
    ctx.translateBy(x: -feet.x, y: -feet.y)
    drawCharacter(ctx, p, look)
    ctx.restoreGState()
}

/// Bocchi melted into a pink puddle that still has her face and hair clips.
private func drawPuddle(_ ctx: CGContext, _ look: Look, _ i: Int) {
    let wobble: CGFloat = [0, 1.5, -1][i - 5]
    ctx.saveGState()
    ctx.translateBy(x: feet.x, y: feet.y)
    ctx.fillGradient({ p in
        p.move(to: CGPoint(x: -44, y: 0))
        p.addCurve(to: CGPoint(x: 0, y: -30 - wobble), control1: CGPoint(x: -40, y: -12), control2: CGPoint(x: -22, y: -30 - wobble))
        p.addCurve(to: CGPoint(x: 44, y: 0), control1: CGPoint(x: 22, y: -30 - wobble), control2: CGPoint(x: 40, y: -12))
        p.addQuadCurve(to: CGPoint(x: -44, y: 0), control: CGPoint(x: 0, y: 6))
    }, [look.hairLight, look.hair, look.hairDark], from: -30, to: 4)
    for (x, y, r) in [(-50.0, -2.0, 3.5), (49.0, -1.0, 2.5), (-36.0, 4.0, 2.0)] {
        ctx.fill({ $0.addEllipse(in: CGRect(x: CGFloat(x) - CGFloat(r), y: CGFloat(y) - CGFloat(r), width: CGFloat(r) * 2, height: CGFloat(r) * 2)) },
                 look.hair, outlineWidth: 1)
    }
    for x: CGFloat in [-7, 7] {
        ctx.fill({ $0.addEllipse(in: CGRect(x: x - 3.5, y: -21 - wobble, width: 7, height: 9)) }, white, outlineWidth: 1.2)
        ctx.fillEllipse(CGPoint(x: x, y: -16.5 - wobble), 1.4, 1.8, look.irisDark)
    }
    drawMouth(ctx, CGPoint(x: 0, y: -9 - wobble), .wavy)
    for (pos, color) in [(CGPoint(x: -18, y: -22), rgb(0xFFD84D)), (CGPoint(x: -11, y: -27), rgb(0x5BA8F5))] {
        ctx.saveGState()
        ctx.translateBy(x: pos.x, y: pos.y - wobble)
        ctx.rotate(by: 0.3)
        ctx.fill({ $0.addRect(CGRect(x: -3.5, y: -3.5, width: 7, height: 7)) }, color, outlineWidth: 1.2)
        ctx.restoreGState()
    }
    ctx.restoreGState()
}

// MARK: - Rem: morning star and oni form

private func remMorningStar(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = [-0.6, -1.5, -2.5, 3.0, 2.2, 1.25, 0.95, 0.7][i]
    p.armBack = [0.4, 0.5, 0.6, 0.3, -0.2, -0.5, -0.3, 0][i]
    p.lean = [-0.04, -0.07, -0.08, -0.03, 0.05, 0.06, 0.04, 0.02][i]
    p.legFront = [0, 0.1, 0.2, 0.3, 0.4, 0.45, 0.3, 0.1][i]; p.legBack = -p.legFront * 0.6
    p.eyes = i < 4 ? .angry : .open(look: 2); p.brows = i < 4 ? .angry : .none
    p.mouth = i == 5 ? .open : .flat
    p.hairSwing = [0.04, 0.06, 0.04, 0, -0.06, -0.1, -0.06, -0.02][i]
    let h = hand(p.armFront, front: true)
    // The ball trails the swing, then lies where it smashed into the ground.
    let trail = p.armFront + 0.7
    let ball = i >= 5 ? CGPoint(x: 44, y: -8) : CGPoint(x: h.x + sin(trail) * 30, y: h.y + cos(trail) * 30)
    let behind = ball.x < 0
    if behind { inBody(ctx, p) { drawFlail(ctx, from: h, to: ball, impact: false) } }
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        if !behind { drawFlail(ctx, from: h, to: ball, impact: i == 5) }
        drawHand(ctx, h, look)
    }
}

/// Rem's morning star: a handle, a chain and a spiked iron ball.
private func drawFlail(_ ctx: CGContext, from grip: CGPoint, to ball: CGPoint, impact: Bool) {
    let dx = ball.x - grip.x, dy = ball.y - grip.y
    let len = max(hypot(dx, dy), 0.001)
    let dir = CGPoint(x: dx / len, y: dy / len)
    ctx.stroke({ $0.move(to: CGPoint(x: grip.x - dir.x * 4, y: grip.y - dir.y * 4)); $0.addLine(to: CGPoint(x: grip.x + dir.x * 7, y: grip.y + dir.y * 7)) },
               outline, 5.4)
    ctx.stroke({ $0.move(to: CGPoint(x: grip.x - dir.x * 4, y: grip.y - dir.y * 4)); $0.addLine(to: CGPoint(x: grip.x + dir.x * 7, y: grip.y + dir.y * 7)) },
               rgb(0x5A4636), 3.2)
    for k in 1..<6 {
        let t = CGFloat(k) / 6
        let c = CGPoint(x: grip.x + dx * t, y: grip.y + dy * t + sin(t * .pi) * 3)
        ctx.fill({ $0.addEllipse(in: CGRect(x: c.x - 2.2, y: c.y - 1.6, width: 4.4, height: 3.2)) }, rgb(0x9AA3B5), outlineWidth: 0.9)
    }
    for k in 0..<8 {
        let a = CGFloat(k) / 8 * 2 * .pi
        let d = CGPoint(x: cos(a), y: sin(a)), n = CGPoint(x: -sin(a), y: cos(a))
        ctx.fill({ p in
            p.move(to: CGPoint(x: ball.x + d.x * 6 + n.x * 2.8, y: ball.y + d.y * 6 + n.y * 2.8))
            p.addLine(to: CGPoint(x: ball.x + d.x * 13, y: ball.y + d.y * 13))
            p.addLine(to: CGPoint(x: ball.x + d.x * 6 - n.x * 2.8, y: ball.y + d.y * 6 - n.y * 2.8))
            p.closeSubpath()
        }, rgb(0xB8C0CE), outlineWidth: 1.1)
    }
    ctx.fillGradient({ $0.addEllipse(in: CGRect(x: ball.x - 8.5, y: ball.y - 8.5, width: 17, height: 17)) },
                     [rgb(0xC9D1DE), rgb(0x6B7385)], from: ball.y - 8.5, to: ball.y + 8.5, outlineWidth: 1.4)
    ctx.fillEllipse(CGPoint(x: ball.x - 3, y: ball.y - 3), 2.2, 1.6, rgb(0xFFFFFF, 0.8))
    if impact {
        for (x, y, x2, y2) in [(-14.0, 4.0, -22.0, 0.0), (14.0, 4.0, 22.0, 0.0), (-10.0, -6.0, -17.0, -12.0), (10.0, -6.0, 17.0, -12.0)] {
            ctx.stroke({ $0.move(to: CGPoint(x: ball.x + CGFloat(x), y: ball.y + CGFloat(y))); $0.addLine(to: CGPoint(x: ball.x + CGFloat(x2), y: ball.y + CGFloat(y2))) },
                       outline, 1.8)
        }
    }
}

private func remOni(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.eyes = .angry; p.brows = .angry; p.mouth = .flat; p.blush = 0.2
    p.armFront = -0.25; p.armBack = 0.25
    p.bob = [0, -1, -2, -3, -3, -2, -1, 0][i]
    p.hairSwing = [0, 0.03, 0.06, 0.08, 0.06, 0.03, 0, -0.03][i]
    let glow = 0.5 + 0.5 * sin(CGFloat(i) / 8 * 2 * .pi)
    // Wisps of power rising around her.
    inBody(ctx, p) {
        for k in 0..<6 {
            let side: CGFloat = k % 2 == 0 ? -1 : 1
            let t = CGFloat((i + k * 3) % 8) / 8
            let x = side * (26 + CGFloat(k / 2) * 6), y = -10 - CGFloat(k / 2) * 22 - t * 18
            ctx.stroke({ path in
                path.move(to: CGPoint(x: x, y: y)); path.addQuadCurve(to: CGPoint(x: x - side * 4, y: y - 14), control: CGPoint(x: x + side * 5, y: y - 7))
            }, rgb(0xBFE0FF, 0.9 * (1 - t)), 2.4)
        }
    }
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let base = CGPoint(x: 5, y: -96)
        ctx.fillEllipse(CGPoint(x: base.x + 2, y: base.y - 9), 10 + glow * 4, 12 + glow * 4, rgb(0xDDEEFF, 0.25 + 0.3 * glow))
        ctx.fill({ p in
            p.move(to: CGPoint(x: base.x - 4.5, y: base.y))
            p.addQuadCurve(to: CGPoint(x: base.x + 3, y: base.y - 19), control: CGPoint(x: base.x - 2, y: base.y - 12))
            p.addQuadCurve(to: CGPoint(x: base.x + 4.5, y: base.y), control: CGPoint(x: base.x + 4.5, y: base.y - 10))
            p.closeSubpath()
        }, white, outlineWidth: 1.4)
        ctx.stroke({ $0.move(to: CGPoint(x: base.x - 2, y: base.y - 5)); $0.addLine(to: CGPoint(x: base.x + 2.5, y: base.y - 6)) }, rgb(0xC3C7D6), 1)
    }
}

// MARK: - Trump: rally speech and "You're fired!"

private func trumpSpeech(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = [2.4, 2.8, 2.4, 1.9, 1.6, 1.9, 2.6, 2.9][i]; p.armBack = 0.3
    p.mouth = i % 2 == 0 ? .open : .grin
    p.brows = i == 1 || i == 7 ? .raised : .none
    p.eyes = i == 4 ? .half : .open(look: 1)
    p.bob = [0, -1, 0, 0, 0, 0, -1, -1.5][i]
    p.tilt = [0, -0.04, 0, 0.03, 0.05, 0.03, 0, -0.04][i]
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        drawPodium(ctx)
        drawArm(ctx, p.armFront, look, front: true)   // gesturing over the podium
        drawFinger(ctx, hand(p.armFront, front: true), up: true, look)
    }
}

/// An index finger sticking out of the fist at `h`, along the arm (or straight up); returns its tip.
@discardableResult
private func drawFinger(_ ctx: CGContext, _ h: CGPoint, angle: CGFloat = .pi, up: Bool = false, _ look: Look) -> CGPoint {
    let a = up ? CGFloat.pi : angle
    let tip = CGPoint(x: h.x + sin(a) * 8, y: h.y + cos(a) * 8)
    ctx.stroke({ $0.move(to: h); $0.addLine(to: tip) }, outline, 4.6)
    ctx.stroke({ $0.move(to: h); $0.addLine(to: tip) }, look.skin, 2.4)
    drawHand(ctx, h, look)
    return tip
}

/// A lectern in front of the body with a microphone and a round gold seal.
private func drawPodium(_ ctx: CGContext) {
    ctx.stroke({ $0.move(to: CGPoint(x: 22, y: -37)); $0.addQuadCurve(to: CGPoint(x: 18, y: -54), control: CGPoint(x: 25, y: -47)) }, outline, 2.6)
    ctx.stroke({ $0.move(to: CGPoint(x: 22, y: -37)); $0.addQuadCurve(to: CGPoint(x: 18, y: -54), control: CGPoint(x: 25, y: -47)) }, rgb(0x6B7385), 1.2)
    ctx.fill({ $0.addEllipse(in: CGRect(x: 15.5, y: -58, width: 5, height: 6)) }, rgb(0x2B2B33), outlineWidth: 1)
    ctx.fillGradient({ p in
        p.move(to: CGPoint(x: 0, y: 0)); p.addLine(to: CGPoint(x: 2, y: -34))
        p.addLine(to: CGPoint(x: 34, y: -34)); p.addLine(to: CGPoint(x: 36, y: 0)); p.closeSubpath()
    }, [rgb(0x3A5BA8), rgb(0x1F3570)], from: -34, to: 0, outlineWidth: 1.4)
    ctx.fill({ $0.addRoundedRect(in: CGRect(x: -2, y: -39, width: 40, height: 6), cornerWidth: 2, cornerHeight: 2) }, rgb(0x6E4A30), outlineWidth: 1.3)
    ctx.fill({ $0.addEllipse(in: CGRect(x: 11, y: -26, width: 14, height: 14)) }, rgb(0xE3B341), outlineWidth: 1.1)
    fillStar(ctx, CGPoint(x: 18, y: -19), 4, white)
}

private func trumpFired(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    let pointing = i >= 2
    p.armFront = pointing ? 1.62 : [0.2, -0.3][i]; p.armBack = pointing ? -0.35 : 0.4
    p.lean = pointing ? 0.06 : -0.05
    p.legFront = pointing ? 0.25 : 0; p.legBack = pointing ? -0.15 : 0
    p.eyes = pointing ? .angry : .half; p.brows = pointing ? .angry : .raised
    p.mouth = (2...5).contains(i) ? .open : .pout
    p.bob = i == 2 ? -1.5 : 0
    drawCharacter(ctx, p, look)
    guard pointing else { return }
    inBody(ctx, p) {
        let h = hand(p.armFront, front: true)
        let tip = drawFinger(ctx, h, angle: p.armFront, look)
        if (2...4).contains(i) {
            for (dy, len) in [(-5.0, 9.0), (0.0, 13.0), (5.0, 9.0)] {
                let x = tip.x + 5 + CGFloat(i - 2) * 3
                ctx.stroke({ $0.move(to: CGPoint(x: x, y: tip.y + CGFloat(dy))); $0.addLine(to: CGPoint(x: x + CGFloat(len), y: tip.y + CGFloat(dy) * 1.6)) },
                           outline, 1.6)
            }
        }
    }
}

// MARK: - Putin: judo throw and fishing

private func putinJudo(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    // Grab (0-2), pull over the shoulder and slam down in front (3-5), straighten up (6-7).
    p.armFront = [1.3, 1.5, 1.65, 2.7, 1.7, 0.6, 0.3, 0][i]
    p.armBack = [1.0, 1.2, 1.4, 2.5, 1.5, 0.5, 0.3, 0.15][i]
    p.lean = [0, 0.04, 0.08, -0.12, 0.06, 0.16, 0.08, 0][i]
    p.bob = [3, 3, 3.5, 1, 2, 4, 2, 0][i]
    p.legFront = [0.4, 0.45, 0.45, 0.25, 0.5, 0.55, 0.3, 0][i]; p.legBack = -p.legFront
    p.eyes = i < 6 ? .angry : .half; p.brows = i < 6 ? .angry : .none
    p.mouth = i == 5 ? .open : .flat
    drawCharacter(ctx, p, look)
    if (3...5).contains(i) {
        inBody(ctx, p) {
            // Swoosh of the throw arcing over to the front.
            let start: CGFloat = [.pi * 1.25, .pi * 1.45, .pi * 1.7][i - 3]
            for (k, width) in [(0, CGFloat(3)), (1, CGFloat(1.8))] {
                ctx.stroke({ $0.addArc(center: CGPoint(x: 6, y: -44), radius: 34 + CGFloat(k) * 6, startAngle: start, endAngle: start + 0.9, clockwise: false) },
                           rgb(0xFFFFFF, 0.9 - CGFloat(k) * 0.3), width)
                ctx.stroke({ $0.addArc(center: CGPoint(x: 6, y: -44), radius: 34 + CGFloat(k) * 6, startAngle: start, endAngle: start + 0.9, clockwise: false) },
                           rgb(0x8A9BB8, 0.5), width * 0.4)
            }
        }
    }
}

private func putinFishing(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.sitting = true
    p.armFront = 1.15; p.armBack = 1.0
    p.eyes = i == 6 ? .wide : .half; p.mouth = i == 6 ? .o : .flat; p.brows = i == 6 ? .raised : .none
    p.blush = 0.2
    p.tilt = 0.05
    let tug: CGFloat = [0, 1, 0, -1, 0, 1, 4, 1][i]
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let h = hand(p.armFront, front: true)
        let tip = CGPoint(x: h.x + 34, y: h.y - 30 + tug * 0.6)
        let bobber = CGPoint(x: tip.x + 4, y: -17 + tug)
        // A small pond in front of him.
        ctx.fillEllipse(CGPoint(x: bobber.x, y: -14), 18, 4, rgb(0x7FB8E6, 0.7))
        let ripple = CGFloat(i % 4) / 3
        ctx.stroke({ $0.addEllipse(in: CGRect(x: bobber.x - 6 - ripple * 6, y: -16 - ripple * 1.5, width: 12 + ripple * 12, height: 3 + ripple * 3)) },
                   rgb(0xFFFFFF, 0.9 - ripple * 0.6), 1)
        ctx.stroke({ $0.move(to: tip); $0.addLine(to: CGPoint(x: bobber.x, y: bobber.y - 3)) }, rgb(0x4A4A55, 0.8), 0.7)
        ctx.stroke({ $0.move(to: CGPoint(x: h.x - 6, y: h.y + 6)); $0.addLine(to: tip) }, outline, 4)
        ctx.stroke({ $0.move(to: CGPoint(x: h.x - 6, y: h.y + 6)); $0.addLine(to: tip) }, rgb(0x9B6A43), 2)
        ctx.fill({ $0.addEllipse(in: CGRect(x: bobber.x - 2.5, y: bobber.y - 3, width: 5, height: 5)) }, rgb(0xE5484D), outlineWidth: 0.9)
        drawHand(ctx, h, look)
    }
}

// MARK: - Xi: keepy-uppy and a friendly wave

private func xiFootball(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.legFront = [0.95, 0.5, 0.1, 0, 0.95, 0.5, 0.1, 0][i]
    p.armFront = 0.55; p.armBack = -0.55
    p.eyes = i % 4 == 2 ? .happy : .open(look: 1.5); p.mouth = i % 4 == 2 ? .grin : .smile
    p.bob = [0, -0.5, -1, -0.5, 0, -0.5, -1, -0.5][i]
    p.tilt = 0.08
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let y: CGFloat = [-19, -36, -50, -36, -19, -36, -50, -36][i]
        drawFootball(ctx, CGPoint(x: 21, y: y), spin: CGFloat(i) * 0.8)
    }
}

/// A black-and-white football.
private func drawFootball(_ ctx: CGContext, _ c: CGPoint, spin: CGFloat) {
    let r: CGFloat = 6.5
    ctx.fill({ $0.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)) }, white, outlineWidth: 1.3)
    ctx.saveGState()
    ctx.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)); ctx.clip()
    func pentagon(_ center: CGPoint, _ size: CGFloat) {
        ctx.fill({ p in
            for k in 0..<5 {
                let a = spin + CGFloat(k) / 5 * 2 * .pi
                let pt = CGPoint(x: center.x + cos(a) * size, y: center.y + sin(a) * size)
                if k == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
            p.closeSubpath()
        }, rgb(0x2B2B33), outlineWidth: 0)
    }
    pentagon(c, 2.6)
    for k in 0..<5 {
        let a = spin + .pi / 5 + CGFloat(k) / 5 * 2 * .pi
        pentagon(CGPoint(x: c.x + cos(a) * 7, y: c.y + sin(a) * 7), 2.2)
    }
    ctx.restoreGState()
}

private func xiWave(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = [2.5, 2.8, 2.5, 2.2, 2.5, 2.8, 2.5, 2.2][i]; p.armBack = 0.1
    p.eyes = .happy; p.mouth = i % 4 < 2 ? .smile : .grin; p.blush = 0.8
    p.bob = [0, -0.6, -1, -0.6, 0, -0.6, -1, -0.6][i]
    p.tilt = -0.05
    drawCharacter(ctx, p, look)
}
