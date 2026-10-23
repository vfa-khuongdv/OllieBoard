import AppKit

// Special-move rows for the anime series' characters (Kimetsu no Yaiba, One Piece, Attack on Titan,
// Jujutsu Kaisen, Hunter x Hunter) and the Cat Knight. Each move is 8 frames; see Skills.swift for the shared helpers.

func drawAnimeSkill(_ ctx: CGContext, _ look: Look, _ which: Int, _ i: Int) {
    switch (look.id, which) {
    case ("tanjiro", 1): tanjiroWater(ctx, look, i)
    case ("tanjiro", 2): tanjiroHinokami(ctx, look, i)
    case ("zenitsu", 1): zenitsuThunder(ctx, look, i)
    case ("zenitsu", 2): zenitsuCry(ctx, look, i)
    case ("luffy", 1): luffyPistol(ctx, look, i)
    case ("luffy", 2): luffyGear5(ctx, look, i)
    case ("zoro", 1): zoroThreeSword(ctx, look, i)
    case ("zoro", 2): zoroLost(ctx, look, i)
    case ("nami", 1): namiClimaTact(ctx, look, i)
    case ("nami", 2): namiBerries(ctx, look, i)
    case ("eren", 1): erenTitan(ctx, look, i)
    case ("eren", 2): erenTatakae(ctx, look, i)
    case ("mikasa", 1): mikasaODM(ctx, look, i)
    case ("mikasa", 2): mikasaScarf(ctx, look, i)
    case ("levi", 1): leviSpin(ctx, look, i)
    case ("levi", 2): leviCleaning(ctx, look, i)
    case ("yuji", 1): yujiFist(ctx, look, i)
    case ("yuji", 2): yujiSukuna(ctx, look, i)
    case ("gojo", 1): gojoVoid(ctx, look, i)
    case ("gojo", 2): gojoPurple(ctx, look, i)
    case ("megumi", 1): megumiShadows(ctx, look, i, rabbits: false)
    case ("megumi", 2): megumiShadows(ctx, look, i, rabbits: true)
    case ("gon", 1): gonJajanken(ctx, look, i)
    case ("gon", 2): gonFishing(ctx, look, i)
    case ("killua", 1): killuaGodspeed(ctx, look, i)
    case ("killua", 2): killuaChocolate(ctx, look, i)
    case ("kurapika", 1): kurapikaChains(ctx, look, i)
    case ("kurapika", 2): kurapikaScarlet(ctx, look, i)
    case ("catknight", 1): catKnightOath(ctx, look, i)
    case ("catknight", 2): catKnightShield(ctx, look, i)
    case ("mikoto", 1): mikotoRailgun(ctx, look, i)
    case ("mikoto", 2): mikotoIronSand(ctx, look, i)
    case ("maomao", 1): maomaoPoisonTest(ctx, look, i)
    case ("maomao", 2): maomaoHerbalBrew(ctx, look, i)
    default: break
    }
}

// MARK: - Shared props

/// A sword held at `grip`, pointing along `angle` (the limbs' convention: 0 is straight down, π/2 is forward).
func drawSword(_ ctx: CGContext, grip: CGPoint, angle: CGFloat, length: CGFloat = 32,
                       blade: CGColor = rgb(0xD8E2EA), hilt: CGColor = rgb(0x2A2A30)) {
    let d = CGPoint(x: sin(angle), y: cos(angle)), n = CGPoint(x: -cos(angle), y: sin(angle))
    let pommel = CGPoint(x: grip.x - d.x * 5, y: grip.y - d.y * 5)
    let guardPoint = CGPoint(x: grip.x + d.x * 4, y: grip.y + d.y * 4)
    let tip = CGPoint(x: grip.x + d.x * length, y: grip.y + d.y * length)
    ctx.stroke({ $0.move(to: guardPoint); $0.addLine(to: tip) }, outline, 4.6)
    ctx.stroke({ $0.move(to: guardPoint); $0.addLine(to: tip) }, blade, 2.6)
    ctx.stroke({ $0.move(to: pommel); $0.addLine(to: guardPoint) }, hilt, 3.6)
    ctx.stroke({ p in
        p.move(to: CGPoint(x: guardPoint.x - n.x * 3.5, y: guardPoint.y - n.y * 3.5))
        p.addLine(to: CGPoint(x: guardPoint.x + n.x * 3.5, y: guardPoint.y + n.y * 3.5))
    }, rgb(0xE3B341), 2.4)
}

/// A jagged lightning line from `a` to `b`; `seed` picks the jags.
private func zigzag(_ ctx: CGContext, from a: CGPoint, to b: CGPoint, color: CGColor, width: CGFloat = 2, seed: Int) {
    let dx = b.x - a.x, dy = b.y - a.y, len = max(hypot(dx, dy), 1)
    let n = CGPoint(x: -dy / len, y: dx / len)
    ctx.stroke({ p in
        p.move(to: a)
        for k in 1..<5 {
            let t = CGFloat(k) / 5, off: CGFloat = ((k + seed) % 2 == 0 ? 1 : -1) * CGFloat(3 + (k * 7 + seed) % 3)
            p.addLine(to: CGPoint(x: a.x + dx * t + n.x * off, y: a.y + dy * t + n.y * off))
        }
        p.addLine(to: b)
    }, color, width)
}

/// Soft round puffs (steam, smoke) around `points`.
private func puffs(_ ctx: CGContext, _ points: [(CGFloat, CGFloat, CGFloat)], alpha: CGFloat = 0.85) {
    for (x, y, r) in points {
        ctx.fill({ $0.addEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)) }, rgb(0xF4F5F8, alpha), outlineWidth: 0)
    }
}

/// A glowing ball (cursed energy, Nen) centered on `c`.
private func orb(_ ctx: CGContext, _ c: CGPoint, _ r: CGFloat, _ color: CGColor) {
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                       colors: [white, color, color.copy(alpha: 0)!] as CFArray, locations: [0, 0.4, 1])!
    ctx.drawRadialGradient(g, startCenter: c, startRadius: 0, endCenter: c, endRadius: r, options: [])
}

private let swing8: [CGFloat] = [0, 0.02, 0.04, 0.02, 0, -0.02, -0.04, -0.02]

// MARK: - Tanjiro: Water Breathing and Hinokami Kagura

private func tanjiroWater(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    let arc: [CGFloat] = [2.6, 2.8, 2.2, 1.2, 0.55, 0.5, 0.5, 0.55]
    p.armFront = arc[i]; p.armBack = arc[i] - 0.35
    p.lean = i >= 3 ? 0.08 : -0.04
    p.legFront = 0.45; p.legBack = -0.35
    p.eyes = .angry; p.brows = .angry; p.mouth = .open
    p.hairSwing = i >= 3 ? -0.08 : 0.04
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let h = hand(p.armFront, front: true)
        drawSword(ctx, grip: h, angle: p.armFront, length: 34, blade: rgb(0x2A3A44))
        drawHand(ctx, h, look)
        // Water swirling along the cut.
        if i >= 3 {
            let fade = 1 - CGFloat(i - 3) / 6
            for k in 0..<3 {
                ctx.stroke({ $0.addArc(center: CGPoint(x: 6, y: -50), radius: 30 + CGFloat(k) * 7,
                                       startAngle: -1.1 + CGFloat(k) * 0.15, endAngle: 1.3, clockwise: false) },
                           rgb(k == 1 ? 0xBFE3FF : 0x4FA3F7, 0.95 * fade), k == 1 ? 1.6 : 3)
            }
            for k in 0..<4 {
                let a = 1.3 - CGFloat(k) * 0.5
                ctx.fillEllipse(CGPoint(x: 6 + cos(a) * 44, y: -50 + sin(a) * 44), 2.4, 2.4, rgb(0x9CD2FF, fade))
            }
        }
    }
}

private func tanjiroHinokami(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    let t = CGFloat(i) / 8 * 2 * .pi
    p.armFront = 2.4 + sin(t) * 0.5; p.armBack = 2.2 + sin(t) * 0.4
    p.bob = [0, -2, -3, -2, 0, -2, -3, -2][i]
    p.legFront = 0.3 * sin(t); p.legBack = -0.3 * sin(t)
    p.eyes = .angry; p.brows = .angry; p.mouth = .flat
    p.hairSwing = sin(t) * 0.08
    let fire = [rgb(0xD8341E, 0.95), rgb(0xFF8A2A, 0.9), rgb(0xFFE9A0, 0.75)]
    inBody(ctx, p) {
        for k in 0..<8 {
            let a = CGFloat(k) / 8 * 2 * .pi + t * 0.5
            drawFlame(ctx, at: CGPoint(x: cos(a) * 36, y: -50 + sin(a) * 40), size: 14 + CGFloat((k + i) % 3) * 4,
                      lean: cos(a) * 0.3, colors: fire)
        }
    }
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let h = hand(p.armFront, front: true)
        let angle = p.armFront + 0.3
        drawSword(ctx, grip: h, angle: angle, length: 34, blade: rgb(0x2A3A44))
        for k in 1...3 {
            let d = CGFloat(k) * 9
            drawFlame(ctx, at: CGPoint(x: h.x + sin(angle) * d, y: h.y + cos(angle) * d + 4),
                      size: 10 + CGFloat((k + i) % 3) * 3, lean: 0.2, colors: fire)
        }
        drawHand(ctx, h, look)
    }
}

// MARK: - Zenitsu: Thunderclap and Flash (asleep) and crying for help

private func zenitsuThunder(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    let drawn = i >= 4
    p.bob = 7; p.lean = drawn ? 0.3 : 0.18
    p.legFront = 0.9; p.legBack = -0.7
    p.armFront = drawn ? 1.6 : 0.5; p.armBack = drawn ? -1.2 : 0.35
    p.eyes = .closed; p.mouth = .flat; p.blush = 0.3
    p.hairSwing = drawn ? -0.15 : -0.05
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        // Scabbard at the hip, sword half drawn or out.
        ctx.stroke({ $0.move(to: CGPoint(x: -20, y: -28)); $0.addLine(to: CGPoint(x: 14, y: -34)) }, outline, 5)
        ctx.stroke({ $0.move(to: CGPoint(x: -20, y: -28)); $0.addLine(to: CGPoint(x: 14, y: -34)) }, rgb(0x3A3A48), 3)
        let h = hand(p.armFront, front: true)
        drawSword(ctx, grip: h, angle: drawn ? p.armFront : 1.75, length: drawn ? 36 : 8, blade: rgb(0xF2E7B8))
        drawHand(ctx, h, look)
        let bright = rgb(0xFFE14D)
        for k in 0..<(drawn ? 6 : 3) {
            let a = CGFloat(k) * 1.05 + CGFloat(i) * 0.7
            zigzag(ctx, from: CGPoint(x: cos(a) * 20, y: -50 + sin(a) * 26), to: CGPoint(x: cos(a) * 34, y: -50 + sin(a) * 42),
                   color: bright, width: 2, seed: i + k)
        }
        if drawn {
            for y: CGFloat in [-30, -50, -70] {
                ctx.stroke({ $0.move(to: CGPoint(x: -24, y: y)); $0.addLine(to: CGPoint(x: -58, y: y)) }, rgb(0xFFE14D, 0.8), 2.4)
            }
        }
    }
}

private func zenitsuCry(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = i % 2 == 0 ? 2.6 : 2.1; p.armBack = i % 2 == 0 ? 2.0 : 2.6
    p.bob = i % 2 == 0 ? -1 : 1
    p.legFront = i % 2 == 0 ? 0.25 : -0.1; p.legBack = -p.legFront
    p.eyes = .teary; p.brows = .sad; p.mouth = .open; p.blush = 1; p.sweat = true
    p.tilt = i % 2 == 0 ? -0.06 : 0.06
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        // Tears streaming off both sides.
        for (k, side) in [CGFloat(-1), 1].enumerated() {
            let t = CGFloat((i + k * 2) % 4) / 4
            for j in 0..<3 {
                let s = t + CGFloat(j) * 0.33
                let x = side * (16 + s * 22), y = -74 - sin(s * .pi) * 12 + s * 18
                ctx.fill({ $0.addEllipse(in: CGRect(x: x - 2.4, y: y - 3, width: 4.8, height: 6)) }, rgb(0x9AD8FF), outlineWidth: 0.8)
            }
        }
    }
}

// MARK: - Luffy: Gum-Gum Pistol and Gear Fifth

private func luffyPistol(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    let length: [CGFloat] = [15, 28, 42, 50, 50, 42, 28, 15]
    p.armFront = .pi / 2; p.armBack = -0.6
    p.lean = 0.08; p.legFront = 0.5; p.legBack = -0.5
    p.eyes = .angry; p.brows = .angry; p.mouth = .grin
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        // The stretched rubber arm, with motion lines along it.
        limb(ctx, from: CGPoint(x: 9, y: -44), angle: .pi / 2, length: length[i], width: 5, color: look.skin) { fist in
            ctx.fill({ $0.addEllipse(in: CGRect(x: fist.x - 5.5, y: fist.y - 5.5, width: 11, height: 11)) }, look.skin, outlineWidth: 1.4)
            if (2...5).contains(i) {
                for dy: CGFloat in [-6, 0, 6] {
                    ctx.stroke({ $0.move(to: CGPoint(x: fist.x - 12, y: fist.y + dy)); $0.addLine(to: CGPoint(x: fist.x - 24, y: fist.y + dy)) },
                               rgb(0x4A2D3A, 0.5), 1.2)
                }
            }
        }
    }
}

private func luffyGear5(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var white5 = look
    white5.hair = rgb(0xF7F7FA); white5.hairDark = rgb(0xDADDE8); white5.hairLight = white
    var p = Pose()
    p.bob = [0, -2, -4, -2, 0, -2, -4, -2][i]
    p.armFront = [2.8, 2.2, 1.6, 2.2, 2.8, 2.2, 1.6, 2.2][i]; p.armBack = 4.4 - p.armFront
    p.legFront = [0, 0.5, 0.8, 0.5, 0, -0.4, -0.6, -0.4][i]; p.legBack = -p.legFront
    p.eyes = .happy; p.mouth = .grin; p.blush = 1
    p.hairSwing = swing8[i] * 3
    p.tilt = [0, 0.08, 0.12, 0.08, 0, -0.08, -0.12, -0.08][i]
    inBody(ctx, p) {
        // Clouds of steam swirling behind him.
        let t = CGFloat(i) / 8 * 2 * .pi
        puffs(ctx, (0..<6).map { k in
            let a = CGFloat(k) / 6 * 2 * .pi + t
            return (cos(a) * 40, -70 + sin(a) * 24, 8 + CGFloat(k % 2) * 3)
        }, alpha: 0.7)
    }
    drawCharacter(ctx, p, white5)
}

// MARK: - Zoro: Three Sword Style and getting lost

private func zoroThreeSword(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    let lunge = i >= 4
    p.armFront = lunge ? 0.9 : 1.9; p.armBack = lunge ? 0.6 : 1.5
    p.lean = lunge ? 0.16 : -0.02
    p.legFront = lunge ? 0.8 : 0.35; p.legBack = lunge ? -0.7 : -0.35
    p.bob = lunge ? 3 : 0
    p.eyes = .angry; p.brows = .angry; p.mouth = .flat
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        // Black bandana tied on for the real fights.
        let head = CGPoint(x: 0, y: -76)
        ctx.fill({ p in
            p.move(to: CGPoint(x: head.x - 29, y: head.y - 8))
            p.addCurve(to: CGPoint(x: head.x + 29, y: head.y - 8), control1: CGPoint(x: head.x - 30, y: head.y - 40),
                       control2: CGPoint(x: head.x + 30, y: head.y - 40))
            p.addQuadCurve(to: CGPoint(x: head.x - 29, y: head.y - 8), control: CGPoint(x: head.x, y: head.y - 16))
        }, rgb(0x22252A), outlineWidth: 1.4)
        ctx.fill({ p in
            p.move(to: CGPoint(x: head.x - 28, y: head.y - 12)); p.addLine(to: CGPoint(x: head.x - 40, y: head.y - 4 + swing8[i] * 40))
            p.addLine(to: CGPoint(x: head.x - 36, y: head.y + 4)); p.closeSubpath()
        }, rgb(0x22252A), outlineWidth: 1.2)
        // The third sword, in his mouth.
        drawSword(ctx, grip: CGPoint(x: head.x + 6, y: head.y + 16), angle: .pi / 2 + 0.15, length: 30, hilt: rgb(0xF4F4F4))
        for (front, hilt) in [(false, rgb(0x1E1E24)), (true, rgb(0xB8323A))] {
            let angle = front ? p.armFront : p.armBack
            let h = hand(angle, front: front)
            drawSword(ctx, grip: h, angle: angle + (front ? 0.2 : -0.1), length: 32, hilt: hilt)
            drawHand(ctx, h, look, dark: !front)
        }
        if lunge {
            ctx.stroke({ $0.addArc(center: CGPoint(x: 10, y: -50), radius: 44, startAngle: -1.0, endAngle: 1.1, clockwise: false) },
                       rgb(0x8FE3A0, 0.8 - CGFloat(i - 4) * 0.15), 3)
        }
    }
}

private func zoroLost(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = -0.4; p.armBack = 0.4   // arms folded behind
    p.tilt = [-0.12, -0.12, -0.06, 0.06, 0.12, 0.12, 0.06, -0.06][i]
    p.eyes = .open(look: i < 4 ? -1 : 2); p.mouth = .flat; p.brows = .raised; p.blush = 0.3
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let side: CGFloat = i < 4 ? -1 : 1
        drawText(ctx, "?", size: 16, at: CGPoint(x: side * 28 - 5, y: -104), color: rgb(0x5B8DEF))
        if i % 4 >= 2 { drawText(ctx, "?", size: 11, at: CGPoint(x: side * 38 - 3, y: -94), color: rgb(0x5B8DEF)) }
    }
}

// MARK: - Nami: Clima-Tact and counting berries

private func namiClimaTact(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = 2.9; p.armBack = 0.5
    p.eyes = .angry; p.brows = .angry; p.mouth = .grin
    p.hairSwing = swing8[i] * 2
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let h = hand(p.armFront, front: true)
        // The staff, held up toward the cloud.
        ctx.stroke({ $0.move(to: CGPoint(x: h.x - 6, y: h.y + 18)); $0.addLine(to: CGPoint(x: h.x + 7, y: h.y - 26)) }, outline, 5)
        ctx.stroke({ $0.move(to: CGPoint(x: h.x - 6, y: h.y + 18)); $0.addLine(to: CGPoint(x: h.x + 7, y: h.y - 26)) }, rgb(0x5BA8F5), 3)
        drawHand(ctx, h, look)
        let cloud = CGPoint(x: 36, y: -104)
        for (dx, dy, r) in [(-10.0, 2.0, 8.0), (0.0, -3.0, 10.0), (11.0, 2.0, 8.0)] {
            ctx.fill({ $0.addEllipse(in: CGRect(x: cloud.x + CGFloat(dx) - CGFloat(r), y: cloud.y + CGFloat(dy) - CGFloat(r),
                                                width: CGFloat(r) * 2, height: CGFloat(r) * 2)) }, rgb(0x5A6070), outlineWidth: 1.2)
        }
        if (3...5).contains(i) {
            zigzag(ctx, from: CGPoint(x: cloud.x + 2, y: cloud.y + 8), to: CGPoint(x: cloud.x + 8, y: -4),
                   color: rgb(0xFFE14D), width: 3, seed: i)
            zigzag(ctx, from: CGPoint(x: cloud.x + 2, y: cloud.y + 8), to: CGPoint(x: cloud.x + 8, y: -4),
                   color: white, width: 1.2, seed: i)
        }
    }
}

private func namiBerries(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = 1.5 + (i % 2 == 0 ? 0 : 0.15); p.armBack = 1.2
    p.eyes = .sparkle; p.mouth = .grin; p.blush = 1
    p.bob = i % 4 < 2 ? 0 : -1.5
    p.tilt = -0.05
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let h = hand(p.armFront, front: true)
        // A fan of banknotes.
        for k in 0..<4 {
            ctx.saveGState()
            ctx.translateBy(x: h.x + 2, y: h.y)
            ctx.rotate(by: -0.6 + CGFloat(k) * 0.3 + (i % 2 == 0 ? 0 : 0.06))
            ctx.fill({ $0.addRect(CGRect(x: -4, y: -24, width: 8, height: 22)) }, rgb(0x9ED38A), outlineWidth: 1)
            ctx.restoreGState()
        }
        drawText(ctx, "฿", size: 11, at: CGPoint(x: h.x - 2, y: h.y - 12), color: rgb(0x2E6B2E))
        drawHand(ctx, h, look)
        if i % 4 == 1 { fillStar(ctx, CGPoint(x: 30, y: -100), 4, rgb(0xFFD84D)) }
    }
}

// MARK: - Eren: Titan shift and "Tatakae!"

private func erenTitan(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = 1.9 + (i % 2 == 0 ? 0 : 0.1); p.armBack = -1.9
    p.legFront = 0.45; p.legBack = -0.45
    p.lean = -0.06; p.bob = i % 2 == 0 ? 0 : -1
    p.eyes = .angry; p.brows = .angry; p.mouth = .open; p.blush = 0
    p.hairSwing = i % 2 == 0 ? 0.08 : -0.04
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        // Titan marks running from the eyes, and steam everywhere.
        for o in eyeOffsets {
            ctx.stroke({ $0.move(to: CGPoint(x: o.x - 4, y: -76 + o.y + 7)); $0.addLine(to: CGPoint(x: o.x - 8, y: -76 + o.y + 16)) },
                       rgb(0xB8443A), 1.6)
        }
        let rise = CGFloat(i % 4) * 4
        puffs(ctx, [(-34, -40 - rise, 7), (30, -56 - rise, 8), (-26, -96 - rise, 6), (24, -100 - rise, 7), (0, -116 + rise / 2, 5)],
              alpha: 0.75)
    }
}

private func erenTatakae(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = 2.2 + (i % 2 == 0 ? 0 : 0.15); p.armBack = 0.35
    p.bob = [0, -2, -4, -2, 0, -2, -4, -2][i]
    p.eyes = .angry; p.brows = .angry; p.mouth = .open
    p.hairSwing = swing8[i] * 2
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        // Shout lines bursting out in front of his mouth.
        let f = CGPoint(x: 26, y: -60)
        for k in 0..<5 {
            let a = (CGFloat(k) - 2) * 0.4
            let r0: CGFloat = 8 + CGFloat(i % 2) * 3
            ctx.stroke({ $0.move(to: CGPoint(x: f.x + cos(a) * r0, y: f.y + sin(a) * r0))
                         $0.addLine(to: CGPoint(x: f.x + cos(a) * (r0 + 8), y: f.y + sin(a) * (r0 + 8))) }, rgb(0xD8343A), 2)
        }
    }
}

// MARK: - Mikasa: ODM gear and the scarf

private func mikasaODM(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.bob = [-10, -13, -15, -13, -10, -13, -15, -13][i]
    p.lean = 0.3
    p.legFront = 1.3; p.legBack = 0.9
    p.armFront = -0.9; p.armBack = -1.15
    p.eyes = .angry; p.brows = .angry; p.mouth = .flat
    p.hairSwing = -0.15
    // Wires to wherever the hooks bit, and gas behind.
    inBody(ctx, p) {
        for dx: CGFloat in [-4, 4] {
            ctx.stroke({ $0.move(to: CGPoint(x: dx, y: -28)); $0.addLine(to: CGPoint(x: 64 + dx * 2, y: -128)) }, rgb(0x6A6A78), 1)
        }
        puffs(ctx, [(-26, -22, 6), (-36, -16, 5), (-44, -24, 4)], alpha: 0.7)
    }
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        // Gear boxes at the hips and the blades swept back.
        ctx.fill({ $0.addRoundedRect(in: CGRect(x: -16, y: -30, width: 12, height: 7), cornerWidth: 2, cornerHeight: 2) },
                 rgb(0x9AA0AA), outlineWidth: 1.1)
        for front in [false, true] {
            let angle = front ? p.armFront : p.armBack
            let h = hand(angle, front: front)
            drawSword(ctx, grip: h, angle: angle - 0.2, length: 26, blade: rgb(0xE6EEF4), hilt: rgb(0x6A6A78))
            drawHand(ctx, h, look, dark: !front)
        }
    }
}

private func mikasaScarf(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = 2.3; p.armBack = 2.1
    p.eyes = .closed; p.mouth = .smile; p.blush = 1
    p.tilt = 0.08 + swing8[i]
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        // The scarf pulled up over her mouth.
        ctx.saveGState()
        ctx.translateBy(x: 0, y: -50); ctx.rotate(by: p.tilt); ctx.translateBy(x: 0, y: 50)
        ctx.fill({ $0.addRoundedRect(in: CGRect(x: -24, y: -63, width: 50, height: 11), cornerWidth: 5, cornerHeight: 5) },
                 look.tie ?? rgb(0xC8323A), outlineWidth: 1.3)
        ctx.restoreGState()
        for front in [false, true] {
            drawHand(ctx, hand(front ? p.armFront : p.armBack, front: front), look, dark: !front)
        }
    }
}

// MARK: - Levi: spinning slash and cleaning

private func leviSpin(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = .pi / 2; p.armBack = -.pi / 2
    p.legFront = 0.4; p.legBack = -0.4
    p.eyes = .half; p.mouth = .flat; p.blush = 0
    let center = CGPoint(x: feet.x, y: feet.y - 52)
    ctx.saveGState()
    ctx.translateBy(x: center.x, y: center.y)
    ctx.rotate(by: CGFloat(i) / 8 * 2 * .pi)
    ctx.translateBy(x: -center.x, y: -center.y)
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        for front in [false, true] {
            let angle = front ? p.armFront : p.armBack
            let h = hand(angle, front: front)
            drawSword(ctx, grip: h, angle: angle, length: 28, blade: rgb(0xE6EEF4), hilt: rgb(0x6A6A78))
            drawHand(ctx, h, look, dark: !front)
        }
    }
    ctx.restoreGState()
    // Whirl around him.
    ctx.stroke({ $0.addArc(center: center, radius: 54, startAngle: CGFloat(i) * 0.8, endAngle: CGFloat(i) * 0.8 + 2.4, clockwise: false) },
               rgb(0xDDE6F0, 0.8), 3)
}

private func leviCleaning(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    let sweep: [CGFloat] = [0.9, 1.1, 1.3, 1.1, 0.9, 0.7, 0.5, 0.7]
    p.armFront = sweep[i]; p.armBack = sweep[i] + 0.3
    p.lean = 0.1
    p.eyes = .half; p.mouth = .flat; p.blush = 0
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        // White kerchief over the hair, and a mask.
        let head = CGPoint(x: 0, y: -76)
        ctx.fill({ p in
            p.move(to: CGPoint(x: head.x - 30, y: head.y - 6))
            p.addCurve(to: CGPoint(x: head.x + 30, y: head.y - 6), control1: CGPoint(x: head.x - 31, y: head.y - 44),
                       control2: CGPoint(x: head.x + 31, y: head.y - 44))
            p.addQuadCurve(to: CGPoint(x: head.x - 30, y: head.y - 6), control: CGPoint(x: head.x, y: head.y - 14))
        }, rgb(0xF4F4F4), outlineWidth: 1.4)
        ctx.fill({ $0.addRoundedRect(in: CGRect(x: head.x - 14, y: head.y + 9, width: 34, height: 13), cornerWidth: 5, cornerHeight: 5) },
                 rgb(0xF4F4F4), outlineWidth: 1.2)
        // Broom.
        let h = hand(p.armFront, front: true)
        let bristles = CGPoint(x: h.x + 14 + sweep[i] * 8, y: 0)
        ctx.stroke({ $0.move(to: CGPoint(x: h.x - 8, y: h.y - 16)); $0.addLine(to: bristles) }, outline, 4.6)
        ctx.stroke({ $0.move(to: CGPoint(x: h.x - 8, y: h.y - 16)); $0.addLine(to: bristles) }, rgb(0xB8874E), 2.6)
        ctx.fill({ p in
            p.move(to: CGPoint(x: bristles.x - 4, y: -8)); p.addLine(to: CGPoint(x: bristles.x + 4, y: -8))
            p.addLine(to: CGPoint(x: bristles.x + 9, y: 2)); p.addLine(to: CGPoint(x: bristles.x - 8, y: 2)); p.closeSubpath()
        }, rgb(0xE8C66A), outlineWidth: 1.2)
        drawHand(ctx, h, look)
        if i % 4 == 2 { puffs(ctx, [(bristles.x + 14, -4, 4), (bristles.x + 20, -8, 3)], alpha: 0.8) }
    }
}

// MARK: - Yuji: Divergent Fist and Sukuna

private func yujiFist(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    let punched = i >= 2
    p.armFront = punched ? .pi / 2 : -0.5; p.armBack = punched ? -0.5 : 0.8
    p.lean = punched ? 0.12 : -0.05
    p.legFront = 0.6; p.legBack = -0.5
    p.eyes = .angry; p.brows = .angry; p.mouth = .open
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let f = hand(p.armFront, front: true)
        orb(ctx, f, punched ? 14 : 9, rgb(0x5A8CFF, 0.8))
        drawHand(ctx, f, look)
        if i >= 4 {
            // The delayed second hit.
            let r = 10 + CGFloat(i - 4) * 6
            ctx.stroke({ $0.addEllipse(in: CGRect(x: f.x + 6 - r, y: f.y - r, width: r * 2, height: r * 2)) },
                       rgb(0x5A8CFF, 1 - CGFloat(i - 4) * 0.2), 2.4)
        }
    }
}

private func yujiSukuna(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = 0.25; p.armBack = -0.25
    p.eyes = .half; p.brows = .angry; p.mouth = .smirk; p.blush = 0
    p.tilt = -0.08
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        ctx.saveGState()
        ctx.translateBy(x: 0, y: -50); ctx.rotate(by: p.tilt); ctx.translateBy(x: 0, y: 50)
        let head = CGPoint(x: 0, y: -76)
        // Sukuna's second pair of eyes and his markings.
        for o in eyeOffsets {
            let e = CGPoint(x: head.x + o.x, y: head.y + o.y + 9)
            ctx.stroke({ $0.move(to: CGPoint(x: e.x - 3.5, y: e.y)); $0.addQuadCurve(to: CGPoint(x: e.x + 3.5, y: e.y), control: CGPoint(x: e.x, y: e.y - 3)) },
                       outline, 1.6)
            ctx.fillEllipse(CGPoint(x: e.x, y: e.y - 0.6), 1.2, 1.2, rgb(0xC81E2A))
        }
        ctx.stroke({ $0.move(to: CGPoint(x: head.x - 6, y: head.y - 12)); $0.addLine(to: CGPoint(x: head.x + 10, y: head.y - 12)) },
                   rgb(0x1E1E24), 1.4)
        for x: CGFloat in [-22, 24] {
            ctx.stroke({ $0.move(to: CGPoint(x: head.x + x, y: head.y + 6)); $0.addLine(to: CGPoint(x: head.x + x * 0.8, y: head.y + 14)) },
                       rgb(0x1E1E24), 1.6)
        }
        ctx.restoreGState()
        if i % 4 < 2 {
            for k in 0..<3 {
                fillStar(ctx, CGPoint(x: -30 + CGFloat(k) * 28, y: -110 + CGFloat((k + i) % 2) * 6), 2.5, rgb(0xE8333A, 0.9))
            }
        }
    }
}

// MARK: - Gojo: Infinite Void and Hollow Purple

private func gojoVoid(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var bare = look
    bare.blindfold = false
    var p = Pose()
    p.armFront = 2.5; p.armBack = 0.2
    p.eyes = .sparkle; p.mouth = .smirk; p.blush = 0.3
    // The domain behind him.
    let c = CGPoint(x: feet.x, y: feet.y - 60)
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                       colors: [rgb(0x1A0E3A, 0.85), rgb(0x5A3AB0, 0.5), rgb(0x8A70FF, 0)] as CFArray, locations: [0, 0.6, 1])!
    ctx.drawRadialGradient(g, startCenter: c, startRadius: 0, endCenter: c, endRadius: 50 + CGFloat(i % 4) * 3, options: [])
    for k in 0..<6 {
        let a = CGFloat(k) / 6 * 2 * .pi + CGFloat(i) * 0.2
        fillStar(ctx, CGPoint(x: c.x + cos(a) * 42, y: c.y + sin(a) * 36), (k + i) % 3 == 0 ? 3 : 1.8, rgb(0xDDE4FF))
    }
    drawCharacter(ctx, p, bare)
    inBody(ctx, p) {
        // The blindfold pushed up onto his forehead.
        ctx.fill({ $0.addRoundedRect(in: CGRect(x: -27, y: -102, width: 55, height: 9), cornerWidth: 4, cornerHeight: 4) },
                 rgb(0x1E1E24), outlineWidth: 1.2)
    }
}

private func gojoPurple(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = 1.6; p.armBack = 1.35
    p.lean = 0.04
    p.eyes = .half; p.mouth = .smirk
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let front = hand(p.armFront, front: true), back = hand(p.armBack, front: false)
        if i < 4 {
            let pull = CGFloat(i) / 4
            orb(ctx, CGPoint(x: back.x + 8 * pull, y: back.y - 6), 9, rgb(0x4F8EF7, 0.9))
            orb(ctx, CGPoint(x: front.x + 6 - 6 * pull, y: front.y - 4), 9, rgb(0xF0453A, 0.9))
        } else {
            orb(ctx, CGPoint(x: front.x + 10, y: front.y - 4), 15 + CGFloat(i % 2) * 2, rgb(0xA64DFF, 0.95))
        }
        drawHand(ctx, front, look)
    }
}

// MARK: - Megumi: Divine Dogs and Rabbit Escape

private func megumiShadows(_ ctx: CGContext, _ look: Look, _ i: Int, rabbits: Bool) {
    var p = Pose()
    p.armFront = rabbits ? 2.0 : 1.05; p.armBack = rabbits ? 2.2 : 1.3
    p.eyes = .angry; p.brows = .angry; p.mouth = .flat
    // A pool of shadow spreading at his feet.
    let grow = min(CGFloat(i) / 3, 1)
    ctx.fillEllipse(CGPoint(x: feet.x + 14, y: feet.y), 18 + 22 * grow, 4 + 3 * grow, rgb(0x15151C, 0.9))
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        // Hands together in the summoning sign.
        let a = hand(p.armFront, front: true), b = hand(p.armBack, front: false)
        drawHand(ctx, CGPoint(x: (a.x + b.x) / 2 + 2, y: (a.y + b.y) / 2), look)
        guard i >= 3 else { return }
        let rise = CGFloat(i - 3) * 3
        if rabbits {
            for (k, x) in [10.0, 22.0, 34.0].enumerated() {
                let up = rise * (1 + CGFloat(k % 2) * 0.4)
                for dx: CGFloat in [-3, 3] {
                    let ear = CGRect(x: CGFloat(x) + dx - 2.6, y: -4 - up - 13, width: 5.2, height: 14)
                    ctx.fill({ $0.addEllipse(in: ear) }, white, outlineWidth: 1)
                    ctx.fillEllipse(CGPoint(x: ear.midX, y: ear.midY), 1.2, 4.5, rgb(0xFFB3C6))
                }
            }
        } else {
            for (x, fur) in [(16.0, white), (36.0, rgb(0x2A2A30))] {
                let top = -4 - rise * 1.6
                ctx.fill({ p in
                    p.move(to: CGPoint(x: CGFloat(x) - 8, y: 0)); p.addLine(to: CGPoint(x: CGFloat(x) - 6, y: top))
                    p.addLine(to: CGPoint(x: CGFloat(x) - 2, y: top + 5)); p.addLine(to: CGPoint(x: CGFloat(x) + 2, y: top + 5))
                    p.addLine(to: CGPoint(x: CGFloat(x) + 6, y: top)); p.addLine(to: CGPoint(x: CGFloat(x) + 8, y: 0)); p.closeSubpath()
                }, fur, outlineWidth: 1.2)
                ctx.fillEllipse(CGPoint(x: CGFloat(x) + 3, y: top + 9), 1.2, 1.2, rgb(0xFFD84D))
            }
        }
    }
}

// MARK: - Gon: Jajanken and fishing

private func gonJajanken(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    let punch = i >= 6
    p.armFront = punch ? .pi / 2 : -0.7; p.armBack = punch ? -0.6 : 0.9
    p.bob = punch ? 0 : 6
    p.lean = punch ? 0.14 : -0.08
    p.legFront = punch ? 0.7 : 0.9; p.legBack = punch ? -0.6 : -0.8
    p.eyes = .angry; p.brows = .angry; p.mouth = punch ? .open : .flat
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let f = hand(p.armFront, front: true)
        orb(ctx, f, punch ? 22 : 6 + CGFloat(i) * 2.2, rgb(0xFFD84D, 0.9))
        ctx.fill({ $0.addEllipse(in: CGRect(x: f.x - 5, y: f.y - 5, width: 10, height: 10)) }, look.skin, outlineWidth: 1.3)
        if !punch {
            // Nen gathering into the fist.
            for k in 0..<5 {
                let a = CGFloat(k) / 5 * 2 * .pi + CGFloat(i) * 0.5
                let r = 20 - CGFloat(i) * 2
                ctx.fillEllipse(CGPoint(x: f.x + cos(a) * r, y: f.y + sin(a) * r), 1.6, 1.6, rgb(0xFFE88A))
            }
        }
    }
}

private func gonFishing(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.sitting = true
    p.armFront = 1.9; p.armBack = 1.7
    p.eyes = .open(look: 2); p.mouth = .smile
    p.bob = [0, -0.5, -1, -0.5, 0, -0.5, -1, -0.5][i]
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let h = hand(p.armFront, front: true)
        let tip = CGPoint(x: 52, y: -92 + CGFloat(i % 4 == 2 ? 4 : 0))
        ctx.stroke({ $0.move(to: CGPoint(x: h.x - 8, y: h.y + 8)); $0.addLine(to: tip) }, outline, 4)
        ctx.stroke({ $0.move(to: CGPoint(x: h.x - 8, y: h.y + 8)); $0.addLine(to: tip) }, rgb(0x9B6A43), 2.2)
        drawHand(ctx, h, look)
        let bobber = CGPoint(x: 56, y: -6 + CGFloat(i % 4 == 2 ? 2 : 0))
        ctx.stroke({ $0.move(to: tip); $0.addLine(to: bobber) }, rgb(0x4A2D3A, 0.6), 0.8)
        ctx.fillEllipse(CGPoint(x: bobber.x, y: bobber.y + 4), 9, 2, rgb(0x5BA8F5, 0.6))
        ctx.fill({ $0.addEllipse(in: CGRect(x: bobber.x - 3, y: bobber.y - 3, width: 6, height: 6)) }, rgb(0xE5484D), outlineWidth: 1)
    }
}

// MARK: - Killua: Godspeed and Chocorobot

private func killuaGodspeed(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = 1.3; p.armBack = 0.9
    p.lean = 0.12; p.bob = 3
    p.legFront = 0.7; p.legBack = -0.6
    p.eyes = .angry; p.mouth = .smirk
    p.hairSwing = i % 2 == 0 ? 0.1 : -0.05
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let blue = rgb(0x8FD0FF)
        for k in 0..<5 {
            let a = CGFloat(k) * 1.25 + CGFloat(i) * 0.9
            let from = CGPoint(x: cos(a) * 16, y: -52 + sin(a) * 30)
            zigzag(ctx, from: from, to: CGPoint(x: from.x * 2.4, y: -52 + (from.y + 52) * 1.5), color: blue, width: 2.2, seed: i + k)
        }
        zigzag(ctx, from: hand(p.armFront, front: true), to: CGPoint(x: 40, y: -30), color: white, width: 1.4, seed: i)
    }
}

private func killuaChocolate(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = 2.2; p.armBack = 0.3
    p.eyes = .happy; p.mouth = i % 2 == 0 ? .o : .smile; p.blush = 1
    p.puffCheek = i % 2 == 1
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        // A Chocorobot box with its robot face.
        let h = hand(p.armFront, front: true)
        let box = CGRect(x: h.x - 2, y: h.y - 16, width: 14, height: 16)
        ctx.fill({ $0.addRoundedRect(in: box, cornerWidth: 2, cornerHeight: 2) }, rgb(0xB8322E), outlineWidth: 1.3)
        ctx.fill({ $0.addRect(CGRect(x: box.minX + 3, y: box.minY + 3, width: 8, height: 6)) }, rgb(0xF2C14E), outlineWidth: 0.8)
        for x: CGFloat in [5.5, 8.5] { ctx.fillEllipse(CGPoint(x: box.minX + x, y: box.minY + 6), 0.9, 0.9, outline) }
        ctx.fillEllipse(CGPoint(x: box.midX, y: box.maxY - 3), 3, 1.4, rgb(0x6A3A22))
        drawHand(ctx, h, look)
    }
}

// MARK: - Kurapika: Chain Jail and Scarlet Eyes

/// A chain of links from `a` along a gentle curve to `b`.
private func drawChain(_ ctx: CGContext, from a: CGPoint, to b: CGPoint, sag: CGFloat) {
    let n = Int(max(hypot(b.x - a.x, b.y - a.y) / 5, 2))
    for k in 0...n {
        let t = CGFloat(k) / CGFloat(n)
        let x = a.x + (b.x - a.x) * t, y = a.y + (b.y - a.y) * t + sin(t * .pi) * sag
        let r = CGRect(x: x - 2.4, y: y - 1.6, width: 4.8, height: 3.2)
        ctx.fill({ $0.addEllipse(in: k % 2 == 0 ? r : r.insetBy(dx: 0.8, dy: -0.8)) }, rgb(0xC9CED8), outlineWidth: 1)
    }
}

private func kurapikaChains(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var p = Pose()
    p.armFront = 1.7; p.armBack = 0.3
    p.eyes = .angry; p.brows = .angry; p.mouth = .flat
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let h = hand(p.armFront, front: true)
        let reach: [CGFloat] = [6, 16, 28, 40, 44, 44, 40, 30]
        drawChain(ctx, from: h, to: CGPoint(x: h.x + reach[i], y: h.y + 6), sag: 6)
        ctx.fill({ p in
            let e = CGPoint(x: h.x + reach[i] + 4, y: h.y + 6)
            p.move(to: CGPoint(x: e.x - 3, y: e.y - 3)); p.addLine(to: CGPoint(x: e.x + 4, y: e.y)); p.addLine(to: CGPoint(x: e.x - 3, y: e.y + 3))
            p.closeSubpath()
        }, rgb(0xC9CED8), outlineWidth: 1)
        drawHand(ctx, h, look)
    }
}

private func kurapikaScarlet(_ ctx: CGContext, _ look: Look, _ i: Int) {
    var scarlet = look
    scarlet.iris = rgb(0xE5232E); scarlet.irisDark = rgb(0x7A0E14); scarlet.irisLight = rgb(0xFF9A9A)
    var p = Pose()
    p.armFront = 0.9; p.armBack = -0.2
    p.eyes = .angry; p.brows = .angry; p.mouth = .flat; p.blush = 0
    p.hairSwing = swing8[i] * 2
    drawCharacter(ctx, p, scarlet)
    inBody(ctx, p) {
        // A red glow off the eyes, and chains hanging from his fingers.
        for o in eyeOffsets {
            orb(ctx, CGPoint(x: o.x, y: -76 + o.y), 8 + CGFloat(i % 2) * 2, rgb(0xFF3040, 0.35))
        }
        let h = hand(p.armFront, front: true)
        drawChain(ctx, from: h, to: CGPoint(x: h.x + 4 + swing8[i] * 60, y: h.y + 26), sag: 2)
        drawHand(ctx, h, look)
    }
}

// MARK: - Cat Knight: the knight's oath and the shield bash

private func catKnightOath(_ ctx: CGContext, _ base: Look, _ i: Int) {
    var look = base
    look.sword = false
    // Sword held upright before her face (as in the reference), then brought down in a cut.
    let sword: [CGFloat] = [.pi, .pi, .pi, .pi, 2.3, 1.6, 1.25, 1.2]
    var p = Pose()
    p.armFront = i < 4 ? 2.0 : 2.0 - CGFloat(i - 3) * 0.25; p.armBack = p.armFront + 0.15
    p.lean = i >= 5 ? 0.08 : 0
    p.legFront = i >= 5 ? 0.4 : 0; p.legBack = i >= 5 ? -0.3 : 0
    p.eyes = i < 4 ? .sparkle : .angry; p.brows = i < 4 ? .none : .angry
    p.mouth = i < 4 ? .o : .open; p.blush = 1
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let h = hand(p.armFront, front: true)
        drawSword(ctx, grip: h, angle: sword[i], length: 40, blade: rgb(0xD8E2EA), hilt: rgb(0x6A4028))
        drawHand(ctx, h, look)
        if (1...3).contains(i) {
            fillStar(ctx, CGPoint(x: h.x, y: h.y - 44), CGFloat(i) * 1.6 + 1.5, rgb(0xFFE88A))
        }
        if i >= 5 {
            ctx.stroke({ $0.addArc(center: CGPoint(x: 6, y: -50), radius: 42, startAngle: -1.2, endAngle: 1.0, clockwise: false) },
                       rgb(0xFFFFFF, 0.9 - CGFloat(i - 5) * 0.25), 3)
        }
    }
}

private func catKnightShield(_ ctx: CGContext, _ base: Look, _ i: Int) {
    var look = base
    look.sword = false
    // Shoving a shield bigger than herself, with a bash on frames 3 and 4.
    let push: [CGFloat] = [0, 1, 3, 8, 8, 4, 2, 0]
    var p = Pose()
    p.armFront = 1.45; p.armBack = 1.3
    p.lean = 0.1 + push[i] * 0.01
    p.legFront = [0.3, 0.5, 0.6, 0.7, 0.7, 0.5, 0.3, 0.2][i]; p.legBack = -p.legFront
    p.eyes = .angry; p.brows = .angry; p.mouth = push[i] > 6 ? .open : .pout; p.blush = 1
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let x0 = 14 + push[i], x1 = x0 + 34, top: CGFloat = -92, bottom: CGFloat = -2
        let mid = (x0 + x1) / 2
        let shield = CGMutablePath()
        shield.move(to: CGPoint(x: x0, y: top + 8))
        shield.addQuadCurve(to: CGPoint(x: x1, y: top + 8), control: CGPoint(x: mid, y: top - 6))
        shield.addLine(to: CGPoint(x: x1, y: bottom - 22))
        shield.addQuadCurve(to: CGPoint(x: mid, y: bottom), control: CGPoint(x: x1, y: bottom - 6))
        shield.addQuadCurve(to: CGPoint(x: x0, y: bottom - 22), control: CGPoint(x: x0, y: bottom - 6))
        shield.closeSubpath()
        ctx.fill({ $0.addPath(shield) }, rgb(0xB8432E), outlineWidth: 2)
        ctx.saveGState()
        ctx.addPath(shield); ctx.clip()
        ctx.setFillColor(rgb(0x2F4E8C))
        ctx.fill(CGRect(x: mid - 4, y: top - 10, width: 8, height: bottom - top + 10))
        ctx.fill(CGRect(x: x0 - 2, y: -56, width: 38, height: 8))
        for (dx, dy) in [(-9.0, -72.0), (9.0, -72.0), (-9.0, -32.0), (9.0, -32.0)] {
            fillStar(ctx, CGPoint(x: mid + CGFloat(dx), y: CGFloat(dy)), 4, rgb(0xE3B341))
        }
        ctx.restoreGState()
        ctx.fill({ $0.addEllipse(in: CGRect(x: mid - 5, y: -57, width: 10, height: 10)) }, rgb(0xB8C0CC), outlineWidth: 1.2)
        if push[i] > 6 {
            for dy: CGFloat in [-70, -46, -22] {
                ctx.stroke({ $0.move(to: CGPoint(x: x1 + 4, y: dy)); $0.addLine(to: CGPoint(x: x1 + 12, y: dy - 3)) }, outline, 2)
            }
        }
    }
}

// MARK: - Maomao: testing a suspicious vial and brewing herbs in a mortar

private func maomaoPoisonTest(_ ctx: CGContext, _ look: Look, _ i: Int) {
    // Holds a vial up, shakes it, sniffs it, then nods at the verdict. Purely a visual effect.
    let shake: [CGFloat] = [0, 0.3, -0.3, 0.3, -0.3, 0.2, 0, 0]
    var p = Pose()
    p.armFront = [1.6, 2.2, 2.4, 2.4, 2.4, 2.2, 2.0, 1.8][i]; p.armBack = 0.2
    p.eyes = i < 5 ? .open(look: 1) : .half; p.brows = i < 5 ? .none : .sad
    p.mouth = i == 6 ? .smile : .flat
    p.tilt = shake[i] * 0.06
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let h = hand(p.armFront, front: true)
        let at = CGPoint(x: h.x + shake[i] * 6, y: h.y - 4)
        ctx.fill({ $0.addRoundedRect(in: CGRect(x: at.x - 4.5, y: at.y - 8, width: 9, height: 13), cornerWidth: 3, cornerHeight: 3) },
                 rgb(0xB28CFF, 0.85), outlineWidth: 1.4)
        ctx.fill({ $0.addRect(CGRect(x: at.x - 2, y: at.y - 13, width: 4, height: 6)) }, rgb(0xF4E7D2), outlineWidth: 1.2)
        ctx.fill({ $0.addRect(CGRect(x: at.x - 4, y: at.y - 1, width: 8, height: 4)) }, rgb(0x7ADFA8, 0.9), outlineWidth: 0)
        drawHand(ctx, h, look)
        if (2...5).contains(i) {
            for k in 0..<3 {
                let r = CGFloat(2 + k % 2), y = at.y - 16 - CGFloat((i * 3 + k * 5) % 12)
                let x = at.x + CGFloat(k - 1) * 6 + shake[i] * 4
                ctx.fill({ $0.addEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)) },
                         k == 1 ? rgb(0x7ADFA8, 0.9) : rgb(0xB28CFF, 0.9), outlineWidth: 0.8)
            }
        }
        if i >= 6 { fillStar(ctx, CGPoint(x: at.x + 12, y: at.y - 16), 4, rgb(0xFFE88A)) }
    }
}

private func maomaoHerbalBrew(_ ctx: CGContext, _ look: Look, _ i: Int) {
    // A mortar held in front; the pestle grinds (frames 0-4), herbs swirl up, then a soft glow of recovery.
    var p = Pose()
    p.armFront = 0.9 + [0, 0.15, 0, 0.15, 0, 0.1, 0, 0][i]; p.armBack = 0.9
    p.eyes = i < 5 ? .open(look: 0.5) : .happy; p.mouth = i < 5 ? .flat : .smile
    p.blush = i < 5 ? 0.3 : 1
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let c = CGPoint(x: 20, y: -24)
        ctx.fill({ p in
            p.move(to: CGPoint(x: c.x - 12, y: c.y - 8)); p.addLine(to: CGPoint(x: c.x + 12, y: c.y - 8))
            p.addQuadCurve(to: CGPoint(x: c.x, y: c.y + 8), control: CGPoint(x: c.x + 12, y: c.y + 8))
            p.addQuadCurve(to: CGPoint(x: c.x - 12, y: c.y - 8), control: CGPoint(x: c.x - 12, y: c.y + 8))
        }, rgb(0x9A8A7A), outlineWidth: 1.6)
        ctx.fill({ $0.addEllipse(in: CGRect(x: c.x - 10, y: c.y - 11, width: 20, height: 6)) }, rgb(0x5A7A4A), outlineWidth: 1.2)
        let sway: CGFloat = i < 5 ? [-4, 0, 4, 0, -4][i] : 0
        ctx.stroke({ $0.move(to: CGPoint(x: c.x + sway, y: c.y - 8)); $0.addLine(to: CGPoint(x: c.x + 6 + sway * 1.5, y: c.y - 30)) },
                   rgb(0xE8D8B8), 4)
        drawHand(ctx, CGPoint(x: c.x + 6 + sway * 1.5, y: c.y - 30), look)
        for k in 0..<4 {
            let t = CGFloat(i) / 8 + CGFloat(k) * 0.25
            let a = t * 2 * .pi
            let leaf = CGPoint(x: c.x + 22 + cos(a) * 8, y: c.y - 14 - (t.truncatingRemainder(dividingBy: 1)) * 30 + sin(a) * 4)
            ctx.fill({ $0.addEllipse(in: CGRect(x: leaf.x - 3.5, y: leaf.y - 2, width: 7, height: 4)) },
                     k % 2 == 0 ? rgb(0x6FBF73) : rgb(0xE88AB0), outlineWidth: 0.8)
        }
        if i >= 5 {
            let a = CGFloat(i - 4) * 0.25
            ctx.fillEllipse(CGPoint(x: c.x, y: c.y - 14), 14 + CGFloat(i - 5) * 4, 14 + CGFloat(i - 5) * 4, rgb(0xCFFFD8, 0.4 - a * 0.2))
            fillStar(ctx, CGPoint(x: c.x + 24, y: c.y - 40), 4, rgb(0xFFE88A))
            fillStar(ctx, CGPoint(x: c.x + 32, y: c.y - 22), 3, rgb(0xFFFFFF))
        }
    }
}

// MARK: - Misaka Mikoto: Railgun and the Iron Sand sword

private func sparkBolt(_ ctx: CGContext, from a: CGPoint, to b: CGPoint, seed: Int, width: CGFloat = 2) {
    let path = CGMutablePath(); path.move(to: a)
    let n = 4
    for k in 1..<n {
        let t = CGFloat(k) / CGFloat(n)
        let jag = CGFloat((seed * 7 + k * 5) % 9) - 4
        path.addLine(to: CGPoint(x: a.x + (b.x - a.x) * t + jag * 0.6, y: a.y + (b.y - a.y) * t + jag))
    }
    path.addLine(to: b)
    ctx.stroke({ $0.addPath(path) }, rgb(0xFFFFFF, 0.95), width + 1.6)
    ctx.stroke({ $0.addPath(path) }, rgb(0x6FB8FF), width)
}

private func mikotoRailgun(_ ctx: CGContext, _ look: Look, _ i: Int) {
    // Flicks a coin up (0-2), catches it and aims (3), fires an orange beam (4-6), then smirks (7).
    var p = Pose()
    p.armFront = [2.3, 2.6, 2.1, 1.55, 1.55, 1.55, 1.55, 1.2][i]; p.armBack = i < 3 ? 0.3 : 0.8
    p.legFront = i >= 3 ? 0.35 : 0; p.legBack = i >= 3 ? -0.35 : 0
    p.lean = i >= 4 && i <= 6 ? -0.08 : 0
    p.eyes = i < 3 ? .open(look: 1) : (i == 7 ? .happy : .angry)
    p.brows = i >= 3 && i < 7 ? .angry : .none
    p.mouth = i >= 4 && i <= 6 ? .open : (i == 7 ? .smirk : .flat)
    p.blush = i == 7 ? 1 : 0.5
    p.hairSwing = i >= 4 && i <= 6 ? 0.1 : 0
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let h = hand(p.armFront, front: true)
        if i <= 2 {
            let coinY = h.y - [10, 24, 12][i]
            ctx.fill({ $0.addEllipse(in: CGRect(x: h.x - 4, y: coinY - 4, width: 8, height: 8)) }, rgb(0xE8E4D8), outlineWidth: 1.3)
            ctx.fillEllipse(CGPoint(x: h.x, y: coinY), 1.6, 1.6, rgb(0xB5B09E))
            if i == 1 { fillStar(ctx, CGPoint(x: h.x + 7, y: coinY - 5), 3, rgb(0xFFE88A)) }
        }
        drawHand(ctx, h, look)
        if i >= 2 && i <= 6 {
            for k in 0..<3 { sparkBolt(ctx, from: CGPoint(x: -14 + CGFloat(k) * 14, y: -62 + CGFloat(k % 2) * 4),
                                       to: CGPoint(x: -22 + CGFloat(k) * 22, y: -78 - CGFloat(k % 2) * 6), seed: i + k) }
        }
        if i == 3 {
            ctx.fill({ $0.addEllipse(in: CGRect(x: h.x - 2, y: h.y - 5, width: 10, height: 10)) }, rgb(0xFFD89A, 0.9), outlineWidth: 0)
            ctx.stroke({ $0.addEllipse(in: CGRect(x: h.x - 5, y: h.y - 8, width: 16, height: 16)) }, rgb(0xFFB347, 0.8), 1.6)
        }
        if i >= 4 && i <= 6 {
            let thick: CGFloat = [7, 10, 5][i - 4]
            let start = CGPoint(x: h.x + 4, y: h.y)
            let end = CGPoint(x: 70, y: h.y)
            ctx.stroke({ $0.move(to: start); $0.addLine(to: end) }, rgb(0xFF9A2E, 0.55), thick + 5)
            ctx.stroke({ $0.move(to: start); $0.addLine(to: end) }, rgb(0xFFC15A), thick)
            ctx.stroke({ $0.move(to: start); $0.addLine(to: end) }, rgb(0xFFFFFF), thick * 0.45)
            ctx.fill({ $0.addEllipse(in: CGRect(x: h.x - 4, y: h.y - thick, width: thick * 2, height: thick * 2)) }, rgb(0xFFFFFF, 0.95), outlineWidth: 0)
            for k in 0..<3 { sparkBolt(ctx, from: CGPoint(x: h.x + 14 + CGFloat(k) * 14, y: h.y), to: CGPoint(x: h.x + 22 + CGFloat(k) * 14, y: h.y + (k % 2 == 0 ? -12 : 12)), seed: i + k) }
        }
        if i == 7 { fillStar(ctx, CGPoint(x: h.x + 14, y: h.y - 8), 4, rgb(0xFFE88A)) }
    }
}

private func mikotoIronSand(_ ctx: CGContext, _ look: Look, _ i: Int) {
    // Black sand gathers into a long sword (0-3), she swings it down (4-5) and it crumbles back to sand (6-7).
    var p = Pose()
    p.armFront = [2.2, 2.4, 2.5, 2.5, 2.1, 1.3, 1.1, 1.0][i]; p.armBack = i < 4 ? 2.0 : 0.6
    p.lean = [0, 0, -0.05, -0.05, 0.05, 0.12, 0.08, 0][i]
    p.legFront = i >= 4 ? 0.45 : 0; p.legBack = i >= 4 ? -0.35 : 0
    p.eyes = i < 7 ? .angry : .half; p.brows = i < 7 ? .angry : .none
    p.mouth = i >= 4 && i <= 5 ? .open : .pout; p.blush = 0.7
    drawCharacter(ctx, p, look)
    inBody(ctx, p) {
        let h = hand(p.armFront, front: true)
        let sand = rgb(0x2A2A32), sandLight = rgb(0x55556A)
        // Drifting grains of sand.
        for k in 0..<10 {
            let a: CGFloat = CGFloat(k) * 0.9 + CGFloat(i) * 0.7
            let wobble: CGFloat = CGFloat(k % 3)
            let r: CGFloat = i < 4 ? 34 - CGFloat(i) * 7 - wobble * 3 : 8 + CGFloat(i - 4) * 9 + wobble * 4
            let cx: CGFloat = h.x + 4 + cos(a) * r * 0.8
            let cy: CGFloat = h.y - 14 + sin(a) * r * 0.55
            let grain: CGColor = k % 2 == 0 ? sand : sandLight
            ctx.fill({ $0.addEllipse(in: CGRect(x: cx - 1.4, y: cy - 1.4, width: 2.8, height: 2.8)) }, grain, outlineWidth: 0)
        }
        if i >= 2 && i <= 6 {
            let lens: [CGFloat] = [0, 0, 20, 40, 48, 48, 26, 0]
            let angles: [CGFloat] = [0, 0, 3.1, 3.0, 2.5, 1.6, 1.2, 0]
            let len = lens[i], angle = angles[i]
            let d = CGPoint(x: sin(angle), y: cos(angle))
            let tip = CGPoint(x: h.x + d.x * len, y: h.y + d.y * len)
            ctx.stroke({ $0.move(to: h); $0.addLine(to: tip) }, outline, 9)
            ctx.stroke({ $0.move(to: h); $0.addLine(to: tip) }, sand, 7)
            ctx.stroke({ $0.move(to: CGPoint(x: h.x + d.x * 3, y: h.y + d.y * 3)); $0.addLine(to: tip) }, sandLight, 1.6)
            // Serrated edge, like grains held together by magnetism.
            for k in 1..<Int(len / 6) {
                let c = CGPoint(x: h.x + d.x * CGFloat(k) * 6, y: h.y + d.y * CGFloat(k) * 6)
                ctx.fill({ $0.addEllipse(in: CGRect(x: c.x + d.y * 2.5 - 1.2, y: c.y - d.x * 2.5 - 1.2, width: 2.4, height: 2.4)) }, sand, outlineWidth: 0)
            }
            if i == 5 {
                ctx.stroke({ $0.addArc(center: CGPoint(x: 4, y: -60), radius: 46, startAngle: -1.0, endAngle: 0.9, clockwise: false) },
                           rgb(0xFFFFFF, 0.9), 3)
                sparkBolt(ctx, from: tip, to: CGPoint(x: tip.x + 10, y: tip.y + 8), seed: 3)
            }
        }
        drawHand(ctx, h, look)
        if i >= 2 && i <= 5 {
            sparkBolt(ctx, from: CGPoint(x: h.x, y: h.y - 4), to: CGPoint(x: h.x + 10, y: h.y - 16), seed: i)
        }
    }
}
