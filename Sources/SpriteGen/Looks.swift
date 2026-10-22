import AppKit

// Each look is a chibi fan-art take on a popular anime character, a chibi caricature of a world leader
// (or a mascot for an AI coding agent), built from the same skeleton so all sheets share identical animation rows.

enum HairStyle { case anya, nezuko, frieren, bocchi, rem, trump, putin, xi, bob, spiky, buns, ponytail }
enum Outfit { case eden, kimono, robe, track, maid, suit, dragonRobe, hoodie }

/// Extra props for the agent mascots, drawn on top of the hair-style accessories.
enum Accessory { case starClip, sparkleClip, cubeClip, glasses, headphones, beanie }

struct Look {
    let id: String
    var skin = rgb(0xFFE6D6), skinShade = rgb(0xF3C7B4)
    let hair: CGColor, hairDark: CGColor, hairLight: CGColor
    let iris: CGColor, irisDark: CGColor, irisLight: CGColor
    let style: HairStyle
    let outfit: Outfit
    let sleeve: CGColor, sleeveDark: CGColor
    var shoe = rgb(0x3A2A2A)
    var sock = white
    var trousers: CGColor? = nil   // legs are bare skin unless set
    var restingLid: CGFloat = 0     // how much the upper lid covers the eye at rest
    var extraBlush: CGFloat = 0
    var muzzle = false
    var accent = rgb(0xE3B341)     // small details: hoodie strings, laptop logo, clips
    var extras: [Accessory] = []
    /// Caricature features: a wide jaw, small pale eyes in lighter "goggle" patches,
    /// thick brows in the hair color and pursed lips that open into a shout.
    var caricature = false
    var jowls: CGFloat = 0          // width of a heavy jaw drawn under the face (0: none)
    var ears = false
    var smirk = false               // the resting smile is lopsided
    var cuff: CGColor? = nil        // band of a different color at the end of the sleeves
}

let looks: [Look] = [
    Look(id: "anya",
         hair: rgb(0xF7A8C4), hairDark: rgb(0xDB7AA0), hairLight: rgb(0xFFD3E2),
         iris: rgb(0x3FBF8F), irisDark: rgb(0x1E6E52), irisLight: rgb(0xA8F0CF),
         style: .anya, outfit: .eden, sleeve: rgb(0x2E2B3A), sleeveDark: rgb(0x1E1C28)),
    Look(id: "nezuko",
         hair: rgb(0x2E2633), hairDark: rgb(0x1A1520), hairLight: rgb(0x5A4C66),
         iris: rgb(0xF07AA8), irisDark: rgb(0x9C2F63), irisLight: rgb(0xFFC2DB),
         style: .nezuko, outfit: .kimono, sleeve: rgb(0xF4A6B8), sleeveDark: rgb(0xD9849A),
         shoe: rgb(0x8A5A3C), sock: white, muzzle: true),
    Look(id: "frieren",
         hair: rgb(0xEEF0F6), hairDark: rgb(0xC3C7D6), hairLight: white,
         iris: rgb(0x4FAE7A), irisDark: rgb(0x22553B), irisLight: rgb(0xB5E8C9),
         style: .frieren, outfit: .robe, sleeve: rgb(0xF5F5F8), sleeveDark: rgb(0xD6D7E0),
         shoe: rgb(0x5A3B32), sock: rgb(0x2F2F3A), restingLid: 0.3),
    Look(id: "bocchi",
         hair: rgb(0xF59BC2), hairDark: rgb(0xD96E9C), hairLight: rgb(0xFFCFE3),
         iris: rgb(0x58BFD6), irisDark: rgb(0x226B80), irisLight: rgb(0xB5ECF7),
         style: .bocchi, outfit: .track, sleeve: rgb(0xF48FB1), sleeveDark: rgb(0xD66F93),
         shoe: rgb(0x3A3A48), extraBlush: 0.8),
    Look(id: "rem",
         hair: rgb(0x8DBBF7), hairDark: rgb(0x5B8AD6), hairLight: rgb(0xCDE2FF),
         iris: rgb(0x4F86E8), irisDark: rgb(0x1F3F87), irisLight: rgb(0xB3CCFF),
         style: .rem, outfit: .maid, sleeve: rgb(0x2B2B35), sleeveDark: rgb(0x1C1C24)),

    // World leaders, in dark suits; `accent` is the tie.
    Look(id: "trump", skin: rgb(0xF4AE80), skinShade: rgb(0xDE9062),
         hair: rgb(0xF8E04E), hairDark: rgb(0xE2B830), hairLight: rgb(0xFFF6A8),
         iris: rgb(0x9CC0DE), irisDark: rgb(0x3A5F80), irisLight: rgb(0xE2F0FA),
         style: .trump, outfit: .suit, sleeve: rgb(0x24252C), sleeveDark: rgb(0x16171C),
         shoe: rgb(0x1A1A20), sock: rgb(0x1A1A20), trousers: rgb(0x24252C), restingLid: 0.3, accent: rgb(0xD8262E),
         caricature: true, jowls: 60),
    Look(id: "putin", skin: rgb(0xF8DCCD), skinShade: rgb(0xEBC2AE),
         hair: rgb(0xDDD4C5), hairDark: rgb(0xBFB4A2), hairLight: rgb(0xF4EFE6),
         iris: rgb(0x7FA0BE), irisDark: rgb(0x34506E), irisLight: rgb(0xD2E2F0),
         style: .putin, outfit: .suit, sleeve: rgb(0x20242F), sleeveDark: rgb(0x14171F),
         shoe: rgb(0x16161C), sock: rgb(0x16161C), trousers: rgb(0x20242F), restingLid: 0.45, accent: rgb(0x8E1F2B),
         ears: true, smirk: true),
    // Xi as a Qing emperor: yellow dragon robe under a black cape collar.
    Look(id: "xi", skin: rgb(0xF5D3B5), skinShade: rgb(0xE6B998),
         hair: rgb(0x26262C), hairDark: rgb(0x141418), hairLight: rgb(0x5E5E6A),
         iris: rgb(0x6B4A36), irisDark: rgb(0x2E1C12), irisLight: rgb(0xC49A7C),
         style: .xi, outfit: .dragonRobe, sleeve: rgb(0xF4CB4E), sleeveDark: rgb(0xD9A82E),
         shoe: rgb(0x1A1A20), sock: rgb(0x1A1A20), trousers: rgb(0xE3B03A), restingLid: 0.4,
         jowls: 57, ears: true, cuff: rgb(0x1E1E24)),

    // AI coding agents.
    Look(id: "claude",
         hair: rgb(0xD97757), hairDark: rgb(0xB0563A), hairLight: rgb(0xF2B39A),
         iris: rgb(0xC0763A), irisDark: rgb(0x6B3A1A), irisLight: rgb(0xF2C89A),
         style: .bob, outfit: .hoodie, sleeve: rgb(0xF0EEE6), sleeveDark: rgb(0xD6D1C2),
         shoe: rgb(0x8A4A32), accent: rgb(0xD97757), extras: [.starClip]),
    Look(id: "codex",
         hair: rgb(0x2E2E33), hairDark: rgb(0x18181C), hairLight: rgb(0x6A6A75),
         iris: rgb(0x5E8C8C), irisDark: rgb(0x203A3A), irisLight: rgb(0xB8DADA),
         style: .spiky, outfit: .hoodie, sleeve: rgb(0x2A2A30), sleeveDark: rgb(0x18181D),
         shoe: rgb(0xEDEDED), accent: white, extras: [.glasses]),
    Look(id: "gemini",
         hair: rgb(0x6F86F2), hairDark: rgb(0x8B5CE0), hairLight: rgb(0xBFD0FF),
         iris: rgb(0x4F7FEA), irisDark: rgb(0x23338A), irisLight: rgb(0xC7B8FF),
         style: .buns, outfit: .eden, sleeve: rgb(0x2D3E8C), sleeveDark: rgb(0x1E2A63),
         accent: rgb(0x9B7BFF), extras: [.sparkleClip]),
    Look(id: "opencode",
         hair: rgb(0x454B55), hairDark: rgb(0x2B2F36), hairLight: rgb(0x7D8592),
         iris: rgb(0x3DBE7A), irisDark: rgb(0x1A5A38), irisLight: rgb(0xA6F0C6),
         style: .bob, outfit: .hoodie, sleeve: rgb(0x3A3F48), sleeveDark: rgb(0x272B32),
         shoe: rgb(0x22252B), accent: rgb(0x3DDC84), extras: [.headphones]),
    Look(id: "cursor",
         hair: rgb(0x2C3550), hairDark: rgb(0x1A2035), hairLight: rgb(0x5E6C96),
         iris: rgb(0x6FB6F0), irisDark: rgb(0x22507A), irisLight: rgb(0xC6E6FF),
         style: .ponytail, outfit: .hoodie, sleeve: rgb(0xF4F5F7), sleeveDark: rgb(0xD5D8DE),
         shoe: rgb(0x1E1E24), accent: rgb(0x1E1E24), extras: [.cubeClip]),
    Look(id: "aider",
         hair: rgb(0x8A5A3B), hairDark: rgb(0x6A4029), hairLight: rgb(0xC4936F),
         iris: rgb(0x4CAF50), irisDark: rgb(0x1E5A22), irisLight: rgb(0xB4E8B6),
         style: .spiky, outfit: .hoodie, sleeve: rgb(0x2E9E5B), sleeveDark: rgb(0x217544),
         shoe: rgb(0x3A2A20), accent: rgb(0xF2C14E), extras: [.beanie]),
]

// MARK: - Character

let feet = CGPoint(x: 64, y: 122)

func drawCharacter(_ ctx: CGContext, _ pose: Pose, _ look: Look) {
    if let skill = pose.skill { return drawSkill(ctx, look, skill.which, skill.frame) }
    ctx.saveGState()
    ctx.translateBy(x: feet.x, y: feet.y)

    // Ground shadow (does not bob).
    ctx.fillEllipse(.zero, 22, 4.5, rgb(0x000000, 0.18))

    ctx.translateBy(x: 0, y: pose.bob + (pose.sitting ? 15 : 0))
    ctx.rotate(by: pose.lean)

    let head = CGPoint(x: 0, y: -76)
    func withHead(_ draw: () -> Void) {
        ctx.saveGState()
        ctx.translateBy(x: 0, y: -50); ctx.rotate(by: pose.tilt); ctx.translateBy(x: 0, y: 50)
        draw()
        ctx.restoreGState()
    }

    func leg(_ x: CGFloat, _ angle: CGFloat, dark: Bool) {
        limb(ctx, from: CGPoint(x: x, y: -20), angle: angle, length: 17, width: 6,
             color: look.trousers.map { dark ? shade($0) : $0 } ?? (dark ? look.skinShade : look.skin)) { foot in
            ctx.fillEllipse(CGPoint(x: foot.x, y: foot.y - 3), 3.6, 3, look.sock)
            ctx.saveGState()
            ctx.translateBy(x: foot.x, y: foot.y)
            ctx.rotate(by: -angle * 0.5)
            ctx.fill({ $0.addEllipse(in: CGRect(x: -4, y: -2, width: 10, height: 6)) }, look.shoe, outlineWidth: 1.2)
            ctx.restoreGState()
        }
    }

    func arm(_ x: CGFloat, _ angle: CGFloat, dark: Bool) {
        limb(ctx, from: CGPoint(x: x, y: -44), angle: angle, length: 15, width: 5,
             color: dark ? look.sleeveDark : look.sleeve) { hand in
            drawCuff(ctx, hand: hand, angle: angle, look)
            ctx.fill({ $0.addEllipse(in: CGRect(x: hand.x - 3.4, y: hand.y - 3.4, width: 6.8, height: 6.8)) },
                     dark ? look.skinShade : look.skin, outlineWidth: 1.2)
        }
    }

    withHead { drawLongHair(ctx, look, head, swing: pose.hairSwing, sitting: pose.sitting) }

    leg(-5, pose.sitting ? 1.45 : pose.legBack, dark: true)
    arm(-9, pose.armBack, dark: true)
    drawOutfit(ctx, look)
    leg(5, pose.sitting ? 1.6 : pose.legFront, dark: false)

    withHead {
        drawHairCap(ctx, look, head)
        if look.ears {
            for side: CGFloat in [-1, 1] {
                let ear = CGPoint(x: head.x + side * 27, y: head.y + 3)
                ctx.fill({ $0.addEllipse(in: CGRect(x: ear.x - 5, y: ear.y - 7, width: 10, height: 14)) }, look.skin, outlineWidth: 1.4)
                ctx.stroke({ p in
                    p.move(to: CGPoint(x: ear.x + side * 1.5, y: ear.y - 4)); p.addQuadCurve(to: CGPoint(x: ear.x + side * 1, y: ear.y + 4), control: CGPoint(x: ear.x - side * 1.5, y: ear.y))
                }, look.skinShade, 1.4)
            }
        }
        // A heavy jaw: the jowl shape is outlined, then the face covers its top edge
        // and the jowls are filled again to hide the face's outline inside them.
        let jowls = CGRect(x: head.x - look.jowls / 2, y: head.y + 1, width: look.jowls, height: 27)
        if look.jowls > 0 { ctx.fill({ $0.addEllipse(in: jowls) }, look.skin) }
        ctx.fill({ $0.addEllipse(in: CGRect(x: head.x - 27, y: head.y - 25, width: 54, height: 50)) }, look.skin)
        if look.jowls > 0 { ctx.fill({ $0.addEllipse(in: jowls.insetBy(dx: 0.9, dy: 0.9)) }, look.skin, outlineWidth: 0) }
        drawFace(ctx, head: head, pose: pose, look: look)
        if look.muzzle { drawMuzzle(ctx, head) }
        if look.extras.contains(.glasses) { drawGlasses(ctx, head) }
        drawBangs(ctx, look, head)
        drawAccessories(ctx, look, head)
        for extra in look.extras where extra != .glasses { drawExtra(ctx, extra, look, head) }
    }

    arm(9, pose.armFront, dark: false)
    if pose.laptop { drawLaptop(ctx, look) }
    if pose.sweat { drawDrop(ctx, at: CGPoint(x: -25, y: head.y - 14), size: 1) }
    ctx.restoreGState()
}

// MARK: - Hair

/// Hair that hangs behind the body.
func drawLongHair(_ ctx: CGContext, _ look: Look, _ h: CGPoint, swing: CGFloat, sitting: Bool) {
    let shorten: CGFloat = sitting ? 18 : 0   // hair rests on the floor when sitting
    switch look.style {
    case .nezuko, .bocchi:
        let bottom = h.y + (look.style == .nezuko ? 74 : 66) - shorten
        let colors = look.style == .nezuko
            ? [look.hair, look.hair, rgb(0xF08A3C)]   // black fading to orange tips
            : [look.hairDark, look.hair]
        ctx.fillGradient({ p in
            p.move(to: CGPoint(x: h.x - 28, y: h.y - 4))
            p.addCurve(to: CGPoint(x: h.x - 30 + swing * 20, y: bottom),
                       control1: CGPoint(x: h.x - 36, y: h.y + 24), control2: CGPoint(x: h.x - 34, y: bottom - 20))
            // Ragged ends.
            let steps = 6
            for i in 1...steps {
                let t = CGFloat(i) / CGFloat(steps)
                let x = h.x - 30 + 58 * t + swing * 20
                p.addLine(to: CGPoint(x: x - 4.8, y: bottom - 7))
                p.addLine(to: CGPoint(x: x, y: bottom + (i % 2 == 0 ? 0 : 3)))
            }
            p.addCurve(to: CGPoint(x: h.x + 28, y: h.y - 4),
                       control1: CGPoint(x: h.x + 34, y: bottom - 20), control2: CGPoint(x: h.x + 36, y: h.y + 24))
            p.closeSubpath()
        }, colors, from: h.y + 20, to: bottom)
    case .frieren:
        // Low twin tails.
        for side: CGFloat in [-1, 1] {
            let top = CGPoint(x: h.x + side * 23, y: h.y + 4)
            let tip = CGPoint(x: h.x + side * 27 + swing * 24, y: h.y + 72 - shorten)
            ctx.fill({ p in
                p.move(to: CGPoint(x: top.x - 6, y: top.y))
                p.addCurve(to: tip, control1: CGPoint(x: top.x + side * 4 - 8, y: top.y + 30),
                           control2: CGPoint(x: tip.x - 8, y: tip.y - 20))
                p.addCurve(to: CGPoint(x: top.x + 6, y: top.y), control1: CGPoint(x: tip.x + 8, y: tip.y - 22),
                           control2: CGPoint(x: top.x + side * 4 + 9, y: top.y + 30))
                p.closeSubpath()
            }, look.hair)
            ctx.stroke({ p in
                p.move(to: CGPoint(x: top.x, y: top.y + 6))
                p.addQuadCurve(to: CGPoint(x: tip.x, y: tip.y - 14), control: CGPoint(x: top.x + side * 4, y: top.y + 36))
            }, look.hairDark, 1.2)
            // Hair tie.
            ctx.fill({ $0.addRoundedRect(in: CGRect(x: top.x - 5, y: top.y + 2, width: 10, height: 4), cornerWidth: 2, cornerHeight: 2) },
                     rgb(0xE3B341), outlineWidth: 1)
        }
    case .ponytail:
        // Ponytail swinging behind the back-side of the head.
        let top = CGPoint(x: h.x - 22, y: h.y - 14)
        let tip = CGPoint(x: h.x - 34 + swing * 30, y: h.y + 40 - shorten / 2)
        ctx.fill({ p in
            p.move(to: CGPoint(x: top.x - 2, y: top.y - 6))
            p.addCurve(to: tip, control1: CGPoint(x: top.x - 22, y: top.y + 4), control2: CGPoint(x: tip.x - 10, y: tip.y - 16))
            p.addCurve(to: CGPoint(x: top.x + 6, y: top.y + 4), control1: CGPoint(x: tip.x + 6, y: tip.y - 14),
                       control2: CGPoint(x: top.x - 4, y: top.y + 16))
            p.closeSubpath()
        }, look.hair)
    case .anya, .rem, .trump, .putin, .xi, .bob, .spiky, .buns:
        break
    }
}

/// Hair volume behind the face (and anything that must peek out from behind it).
func drawHairCap(_ ctx: CGContext, _ look: Look, _ h: CGPoint) {
    switch look.style {
    case .anya:
        // Shoulder-length hair with outward flips.
        ctx.fill({ p in
            p.addEllipse(in: CGRect(x: h.x - 31, y: h.y - 31, width: 62, height: 56))
            for side: CGFloat in [-1, 1] {
                p.move(to: CGPoint(x: h.x + side * 28, y: h.y))
                p.addQuadCurve(to: CGPoint(x: h.x + side * 34, y: h.y + 22), control: CGPoint(x: h.x + side * 30, y: h.y + 18))
                p.addLine(to: CGPoint(x: h.x + side * 22, y: h.y + 18))
                p.closeSubpath()
            }
        }, look.hairDark)
    case .rem:
        // Rounded bob framing the face.
        ctx.fill({ p in
            p.move(to: CGPoint(x: h.x - 22, y: h.y + 20))
            p.addCurve(to: CGPoint(x: h.x, y: h.y - 32), control1: CGPoint(x: h.x - 40, y: h.y + 12), control2: CGPoint(x: h.x - 36, y: h.y - 32))
            p.addCurve(to: CGPoint(x: h.x + 22, y: h.y + 20), control1: CGPoint(x: h.x + 36, y: h.y - 32), control2: CGPoint(x: h.x + 40, y: h.y + 12))
            p.closeSubpath()
        }, look.hairDark)
    case .frieren:
        // Pointy elf ears stick out from behind the hair.
        for side: CGFloat in [-1, 1] {
            ctx.fill({ p in
                p.move(to: CGPoint(x: h.x + side * 22, y: h.y - 2))
                p.addQuadCurve(to: CGPoint(x: h.x + side * 45, y: h.y - 12), control: CGPoint(x: h.x + side * 34, y: h.y - 4))
                p.addQuadCurve(to: CGPoint(x: h.x + side * 23, y: h.y + 11), control: CGPoint(x: h.x + side * 36, y: h.y + 6))
                p.closeSubpath()
            }, look.skin, outlineWidth: 1.4)
        }
        ctx.fill({ $0.addEllipse(in: CGRect(x: h.x - 30, y: h.y - 31, width: 60, height: 54)) }, look.hairDark)
    case .nezuko, .bocchi, .ponytail:
        ctx.fill({ $0.addEllipse(in: CGRect(x: h.x - 31, y: h.y - 31, width: 62, height: 56)) }, look.hairDark)
    case .xi:
        // Full, high hair combed straight back.
        ctx.fill({ $0.addEllipse(in: CGRect(x: h.x - 31, y: h.y - 37, width: 62, height: 58)) }, look.hairDark)
    case .trump:
        // Full volume swept back behind the head.
        ctx.fill({ p in
            p.addEllipse(in: CGRect(x: h.x - 34, y: h.y - 36, width: 66, height: 56))
            p.move(to: CGPoint(x: h.x - 26, y: h.y - 24))
            p.addQuadCurve(to: CGPoint(x: h.x - 37, y: h.y + 8), control: CGPoint(x: h.x - 42, y: h.y - 12))
            p.addLine(to: CGPoint(x: h.x - 25, y: h.y + 6))
            p.closeSubpath()
        }, look.hairDark)
    case .putin:
        // Short hair only around the sides and back; the crown is mostly bare.
        ctx.fill({ $0.addEllipse(in: CGRect(x: h.x - 29, y: h.y - 22, width: 58, height: 42)) }, look.hairDark)
    case .bob:
        // Chin-length bob curling in under the cheeks.
        ctx.fill({ p in
            p.move(to: CGPoint(x: h.x - 20, y: h.y + 22))
            p.addCurve(to: CGPoint(x: h.x, y: h.y - 32), control1: CGPoint(x: h.x - 40, y: h.y + 18), control2: CGPoint(x: h.x - 37, y: h.y - 32))
            p.addCurve(to: CGPoint(x: h.x + 20, y: h.y + 22), control1: CGPoint(x: h.x + 37, y: h.y - 32), control2: CGPoint(x: h.x + 40, y: h.y + 18))
            p.closeSubpath()
        }, look.hairDark)
    case .spiky:
        ctx.fill({ p in
            p.addEllipse(in: CGRect(x: h.x - 31, y: h.y - 31, width: 62, height: 54))
            // Tufts sticking out at the sides.
            for (bx, by, tx, ty) in [(-29.0, -10.0, -38.0, -2.0), (-27.0, 2.0, -34.0, 12.0), (29.0, -10.0, 38.0, -2.0),
                                     (27.0, 2.0, 33.0, 12.0)] {
                p.move(to: CGPoint(x: h.x + CGFloat(bx), y: h.y + CGFloat(by) - 6))
                p.addLine(to: CGPoint(x: h.x + CGFloat(tx), y: h.y + CGFloat(ty)))
                p.addLine(to: CGPoint(x: h.x + CGFloat(bx), y: h.y + CGFloat(by) + 6))
                p.closeSubpath()
            }
        }, look.hairDark)
    case .buns:
        // Twin buns on top, one per Gemini twin.
        for side: CGFloat in [-1, 1] {
            ctx.fillGradient({ $0.addEllipse(in: CGRect(x: h.x + side * 22 - 10, y: h.y - 38, width: 20, height: 20)) },
                             [look.hair, look.hairDark], from: h.y - 38, to: h.y - 18)
        }
        ctx.fill({ $0.addEllipse(in: CGRect(x: h.x - 31, y: h.y - 31, width: 62, height: 56)) }, look.hairDark)
    }
}

/// Fringe over the forehead. Tips are listed right-to-left relative to the head center.
func drawBangs(_ ctx: CGContext, _ look: Look, _ h: CGPoint) {
    let tips: [(CGFloat, CGFloat)]
    switch look.style {
    case .anya:
        tips = [(25, -6), (18, -2), (13, -13), (5, -5), (-2, -14), (-9, -5), (-15, -12), (-22, -2), (-26, -6)]
    case .nezuko:
        tips = [(26, -2), (20, 2), (13, -11), (6, -2), (1, -16), (-4, -2), (-12, -11), (-19, 2), (-26, -2)]
    case .bocchi:
        tips = [(26, 0), (21, 2), (15, -7), (9, 0), (3, -9), (-3, 0), (-9, -8), (-15, 1), (-21, -5), (-26, 0)]
    case .frieren:
        tips = [(26, 8), (19, -4), (11, -12), (3, -19), (0, -24), (-4, -18), (-11, -11), (-19, -4), (-26, 8)]
    case .rem:
        tips = [(26, -2), (20, 0), (13, -12), (6, -6), (1, -16), (-1, 10), (-8, 16), (-15, 9), (-22, 2), (-26, -2)]
    case .bob, .buns:
        tips = [(26, -2), (19, 1), (12, -10), (5, -2), (-1, -12), (-7, -2), (-14, -10), (-20, 1), (-26, -2)]
    case .spiky:
        tips = [(27, 4), (22, -6), (17, -2), (12, -14), (6, -6), (1, -18), (-5, -7), (-11, -15), (-17, -4), (-22, -8), (-27, 4)]
    case .ponytail:
        tips = [(26, 0), (20, -4), (12, -14), (4, -12), (-4, -10), (-12, -6), (-20, 0), (-26, 2)]
    case .trump, .putin, .xi:
        return drawLeaderHair(ctx, look, h)
    }
    ctx.fill({ p in
        p.move(to: CGPoint(x: h.x - 30, y: h.y + 6))
        p.addCurve(to: CGPoint(x: h.x + 30, y: h.y + 6),
                   control1: CGPoint(x: h.x - 34, y: h.y - 40), control2: CGPoint(x: h.x + 34, y: h.y - 40))
        for (x, y) in tips { p.addLine(to: CGPoint(x: h.x + x, y: h.y + y)) }
        p.closeSubpath()
    }, look.hair)

    // Side locks framing the cheeks.
    if look.style == .frieren || look.style == .nezuko || look.style == .bocchi {
        for side: CGFloat in [-1, 1] {
            ctx.fill({ p in
                p.move(to: CGPoint(x: h.x + side * 27, y: h.y - 8))
                p.addQuadCurve(to: CGPoint(x: h.x + side * 23, y: h.y + 26), control: CGPoint(x: h.x + side * 30, y: h.y + 12))
                p.addQuadCurve(to: CGPoint(x: h.x + side * 21, y: h.y - 4), control: CGPoint(x: h.x + side * 22, y: h.y + 10))
                p.closeSubpath()
            }, look.hair, outlineWidth: 1.2)
        }
    }

    // Shine.
    ctx.stroke({ p in
        p.addArc(center: CGPoint(x: h.x - 4, y: h.y - 6), radius: 22, startAngle: .pi * 1.18, endAngle: .pi * 1.38, clockwise: false)
    }, look.hairLight, 3)
}

func drawAccessories(_ ctx: CGContext, _ look: Look, _ h: CGPoint) {
    switch look.style {
    case .bob, .spiky, .buns, .ponytail:
        break   // agent mascots use `extras` instead
    case .trump, .putin, .xi:
        break
    case .anya:
        // Black horn-shaped hair ornaments.
        for side: CGFloat in [-1, 1] {
            let base = CGPoint(x: h.x + side * 17, y: h.y - 24)
            ctx.fill({ p in
                p.move(to: CGPoint(x: base.x - 6, y: base.y + 3))
                p.addQuadCurve(to: CGPoint(x: base.x + side * 7, y: base.y - 13), control: CGPoint(x: base.x - side * 2, y: base.y - 8))
                p.addQuadCurve(to: CGPoint(x: base.x + 6, y: base.y + 3), control: CGPoint(x: base.x + side * 6, y: base.y - 2))
                p.closeSubpath()
            }, rgb(0x2B2B33), outlineWidth: 1.2)
            ctx.stroke({ p in
                p.move(to: CGPoint(x: base.x - side * 1, y: base.y - 1)); p.addLine(to: CGPoint(x: base.x + side * 3, y: base.y - 7))
            }, rgb(0x6B6B7A), 1.2)
        }
    case .nezuko:
        // Pink ribbon tied at the back of the head.
        let c = CGPoint(x: h.x - 22, y: h.y - 22)
        let pink = rgb(0xF7A1C4)
        ctx.fill({ p in
            p.move(to: c); p.addLine(to: CGPoint(x: c.x - 11, y: c.y - 8)); p.addLine(to: CGPoint(x: c.x - 9, y: c.y + 7)); p.closeSubpath()
            p.move(to: c); p.addLine(to: CGPoint(x: c.x + 9, y: c.y - 10)); p.addLine(to: CGPoint(x: c.x + 10, y: c.y + 4)); p.closeSubpath()
        }, pink, outlineWidth: 1.2)
        ctx.fill({ $0.addEllipse(in: CGRect(x: c.x - 3, y: c.y - 3, width: 6, height: 6)) }, rgb(0xE07AA6), outlineWidth: 1)
    case .frieren:
        // Red drop earrings.
        for x: CGFloat in [-25, 27] {
            ctx.stroke({ p in p.move(to: CGPoint(x: h.x + x, y: h.y + 8)); p.addLine(to: CGPoint(x: h.x + x, y: h.y + 12)) }, rgb(0xE3B341), 1)
            ctx.fill({ $0.addEllipse(in: CGRect(x: h.x + x - 2, y: h.y + 12, width: 4, height: 5)) }, rgb(0xD83A3A), outlineWidth: 0.8)
        }
    case .bocchi:
        // Cube hair clips (yellow + blue).
        for (pos, color) in [(CGPoint(x: -24, y: -12), rgb(0xFFD84D)), (CGPoint(x: -16, y: -20), rgb(0x5BA8F5))] {
            ctx.saveGState()
            ctx.translateBy(x: h.x + pos.x, y: h.y + pos.y)
            ctx.rotate(by: 0.3)
            ctx.fill({ $0.addRect(CGRect(x: -3.5, y: -3.5, width: 7, height: 7)) }, color, outlineWidth: 1.2)
            ctx.restoreGState()
        }
    case .rem:
        // Frilly maid headdress.
        ctx.fill({ p in
            p.move(to: CGPoint(x: h.x - 24, y: h.y - 18))
            p.addQuadCurve(to: CGPoint(x: h.x + 24, y: h.y - 18), control: CGPoint(x: h.x, y: h.y - 44))
            p.addQuadCurve(to: CGPoint(x: h.x - 24, y: h.y - 18), control: CGPoint(x: h.x, y: h.y - 36))
        }, white, outlineWidth: 1.2)
        for i in 0..<5 {
            let t = CGFloat(i) / 4
            let x = h.x - 18 + 36 * t
            let y = h.y - 25 - sin(t * .pi) * 8
            ctx.fill({ $0.addEllipse(in: CGRect(x: x - 3.4, y: y - 5, width: 6.8, height: 6.8)) }, white, outlineWidth: 1)
        }
        // X-shaped hair clip.
        let c = CGPoint(x: h.x + 19, y: h.y - 10)
        for d: CGFloat in [-1, 1] {
            ctx.stroke({ p in p.move(to: CGPoint(x: c.x - 4, y: c.y - 4 * d)); p.addLine(to: CGPoint(x: c.x + 4, y: c.y + 4 * d)) }, outline, 3.6)
            ctx.stroke({ p in p.move(to: CGPoint(x: c.x - 4, y: c.y - 4 * d)); p.addLine(to: CGPoint(x: c.x + 4, y: c.y + 4 * d)) }, white, 2)
        }
    }
}

/// Short, combed hair that leaves the forehead clear: Trump's golden swoop, Putin's receding crop, Xi's side part.
func drawLeaderHair(_ ctx: CGContext, _ look: Look, _ h: CGPoint) {
    switch look.style {
    case .trump:
        // Swept up from the back and over to the facing side, the front hanging over the forehead.
        ctx.fill({ p in
            p.move(to: CGPoint(x: h.x - 31, y: h.y + 8))
            p.addCurve(to: CGPoint(x: h.x + 2, y: h.y - 41), control1: CGPoint(x: h.x - 38, y: h.y - 26), control2: CGPoint(x: h.x - 20, y: h.y - 42))
            p.addCurve(to: CGPoint(x: h.x + 41, y: h.y - 22), control1: CGPoint(x: h.x + 22, y: h.y - 41), control2: CGPoint(x: h.x + 38, y: h.y - 34))
            // The overhang curls under at its tip...
            p.addQuadCurve(to: CGPoint(x: h.x + 31, y: h.y - 10), control: CGPoint(x: h.x + 42, y: h.y - 11))
            p.addQuadCurve(to: CGPoint(x: h.x + 25, y: h.y - 14), control: CGPoint(x: h.x + 27, y: h.y - 9))
            // ...and its edge sweeps back across the forehead.
            p.addQuadCurve(to: CGPoint(x: h.x - 6, y: h.y - 19), control: CGPoint(x: h.x + 10, y: h.y - 21))
            p.addQuadCurve(to: CGPoint(x: h.x - 23, y: h.y - 9), control: CGPoint(x: h.x - 17, y: h.y - 17))
            p.addQuadCurve(to: CGPoint(x: h.x - 26, y: h.y + 9), control: CGPoint(x: h.x - 26, y: h.y))
            p.closeSubpath()
        }, look.hair)
        for (from, to, c) in [((-26.0, -12.0), (30.0, -26.0), (-2.0, -38.0)), ((-20.0, -6.0), (36.0, -18.0), (8.0, -30.0)),
                              ((-6.0, -18.0), (24.0, -15.0), (10.0, -24.0))] {
            ctx.stroke({ p in
                p.move(to: CGPoint(x: h.x + CGFloat(from.0), y: h.y + CGFloat(from.1)))
                p.addQuadCurve(to: CGPoint(x: h.x + CGFloat(to.0), y: h.y + CGFloat(to.1)), control: CGPoint(x: h.x + CGFloat(c.0), y: h.y + CGFloat(c.1)))
            }, look.hairDark, 1.2)
        }
    case .putin:
        // Short at the temples, with only thin, pale wisps over the bald crown.
        // Inside the head outline: clipped to the face's top so nothing sticks out.
        ctx.saveGState()
        ctx.addEllipse(in: CGRect(x: h.x - 27, y: h.y - 25, width: 54, height: 50)); ctx.clip()
        for side: CGFloat in [-1, 1] {
            ctx.fill({ p in
                p.move(to: CGPoint(x: h.x + side * 28, y: h.y + 2))
                p.addQuadCurve(to: CGPoint(x: h.x + side * 17, y: h.y - 24), control: CGPoint(x: h.x + side * 28, y: h.y - 20))
                p.addQuadCurve(to: CGPoint(x: h.x + side * 23, y: h.y + 2), control: CGPoint(x: h.x + side * 21, y: h.y - 14))
                p.closeSubpath()
            }, look.hair, outlineWidth: 0)
        }
        ctx.fillEllipse(CGPoint(x: h.x, y: h.y - 24), 23, 9, rgb(0xD6CCBB, 0.9))
        for (y, w) in [(-27.0, 12.0), (-23.0, 15.0)] {
            ctx.stroke({ p in
                p.move(to: CGPoint(x: h.x - CGFloat(w), y: h.y + CGFloat(y) + 1)); p.addQuadCurve(to: CGPoint(x: h.x + CGFloat(w), y: h.y + CGFloat(y) + 1), control: CGPoint(x: h.x, y: h.y + CGFloat(y) - 2))
            }, look.hairDark, 0.8)
        }
        ctx.restoreGState()
        return
    default:
        // Thick and high, combed straight back from a level hairline.
        ctx.fill({ p in
            p.move(to: CGPoint(x: h.x - 29, y: h.y + 4))
            p.addCurve(to: CGPoint(x: h.x + 29, y: h.y + 4), control1: CGPoint(x: h.x - 36, y: h.y - 48), control2: CGPoint(x: h.x + 36, y: h.y - 48))
            p.addQuadCurve(to: CGPoint(x: h.x + 24, y: h.y - 12), control: CGPoint(x: h.x + 27, y: h.y - 5))
            p.addQuadCurve(to: CGPoint(x: h.x - 2, y: h.y - 21), control: CGPoint(x: h.x + 12, y: h.y - 22))
            p.addQuadCurve(to: CGPoint(x: h.x - 24, y: h.y - 11), control: CGPoint(x: h.x - 16, y: h.y - 21))
            p.addQuadCurve(to: CGPoint(x: h.x - 26, y: h.y + 4), control: CGPoint(x: h.x - 27, y: h.y - 4))
            p.closeSubpath()
        }, look.hair)
        for (x, top) in [(-14.0, -30.0), (-4.0, -36.0), (6.0, -36.0), (16.0, -30.0)] {
            ctx.stroke({ p in
                p.move(to: CGPoint(x: h.x + CGFloat(x) + 2, y: h.y - 22)); p.addQuadCurve(to: CGPoint(x: h.x + CGFloat(x) - 4, y: h.y + CGFloat(top)), control: CGPoint(x: h.x + CGFloat(x), y: h.y + CGFloat(top) + 4))
            }, look.hairLight, 1)
        }
    }
    ctx.stroke({ p in
        p.addArc(center: CGPoint(x: h.x - 4, y: h.y - 8), radius: 22, startAngle: .pi * 1.22, endAngle: .pi * 1.4, clockwise: false)
    }, look.hairLight, 3)
}

/// A band at the end of the sleeve, just above the hand.
func drawCuff(_ ctx: CGContext, hand: CGPoint, angle: CGFloat, _ look: Look) {
    guard let cuff = look.cuff else { return }
    ctx.fill({ $0.addEllipse(in: CGRect(x: hand.x - sin(angle) * 3 - 4, y: hand.y - cos(angle) * 3 - 4, width: 8, height: 8)) }, cuff, outlineWidth: 1.2)
}

func drawMuzzle(_ ctx: CGContext, _ h: CGPoint) {
    let r = CGRect(x: h.x - 22, y: h.y + 11, width: 48, height: 8)
    ctx.stroke({ p in
        p.move(to: CGPoint(x: r.minX, y: r.midY)); p.addLine(to: CGPoint(x: h.x - 27, y: h.y + 6))
        p.move(to: CGPoint(x: r.maxX, y: r.midY)); p.addLine(to: CGPoint(x: h.x + 27, y: h.y + 6))
    }, rgb(0x8B3A3A), 1.6)
    ctx.fillGradient({ $0.addRoundedRect(in: r, cornerWidth: 4, cornerHeight: 4) },
                     [rgb(0xC6E59A), rgb(0x8DBE5E)], from: r.minY, to: r.maxY, outlineWidth: 1.3)
    for x: CGFloat in [-8, 12] {
        ctx.stroke({ p in p.move(to: CGPoint(x: h.x + x, y: r.minY + 1)); p.addLine(to: CGPoint(x: h.x + x, y: r.maxY - 1)) }, rgb(0x5E8A3A), 1.4)
    }
}

// MARK: - Agent props

func drawGlasses(_ ctx: CGContext, _ h: CGPoint) {
    for o in eyeOffsets {
        let r = CGRect(x: h.x + o.x - 8, y: h.y + o.y - 8, width: 16, height: 16)
        ctx.fillEllipse(CGPoint(x: r.midX, y: r.midY), 8, 8, rgb(0xFFFFFF, 0.18))
        ctx.stroke({ $0.addEllipse(in: r) }, rgb(0x1E1E24), 1.8)
    }
    ctx.stroke({ p in
        p.move(to: CGPoint(x: h.x + eyeOffsets[0].x + 8, y: h.y + eyeOffsets[0].y - 1))
        p.addQuadCurve(to: CGPoint(x: h.x + eyeOffsets[1].x - 8, y: h.y + eyeOffsets[1].y - 1),
                       control: CGPoint(x: h.x + 2, y: h.y - 2))
    }, rgb(0x1E1E24), 1.6)
}

func drawExtra(_ ctx: CGContext, _ extra: Accessory, _ look: Look, _ h: CGPoint) {
    switch extra {
    case .glasses:
        drawGlasses(ctx, h)
    case .starClip:
        // Little starburst clip.
        let c = CGPoint(x: h.x + 18, y: h.y - 17)
        for (color, width) in [(outline, CGFloat(3.6)), (look.accent, CGFloat(2))] {
            for i in 0..<8 {
                let a = CGFloat(i) / 8 * 2 * .pi
                let len: CGFloat = i % 2 == 0 ? 6 : 4.5
                ctx.stroke({ p in p.move(to: c); p.addLine(to: CGPoint(x: c.x + cos(a) * len, y: c.y + sin(a) * len)) }, color, width)
            }
        }
    case .sparkleClip:
        let c = CGPoint(x: h.x + 19, y: h.y - 16)
        ctx.fillGradient({ p in
            p.move(to: CGPoint(x: c.x, y: c.y - 8))
            p.addQuadCurve(to: CGPoint(x: c.x + 8, y: c.y), control: c)
            p.addQuadCurve(to: CGPoint(x: c.x, y: c.y + 8), control: c)
            p.addQuadCurve(to: CGPoint(x: c.x - 8, y: c.y), control: c)
            p.addQuadCurve(to: CGPoint(x: c.x, y: c.y - 8), control: c)
        }, [rgb(0x4F8EF7), rgb(0x9B6CF0)], from: c.y - 8, to: c.y + 8, outlineWidth: 1.1)
    case .cubeClip:
        // Isometric cube.
        let c = CGPoint(x: h.x + 19, y: h.y - 15), s: CGFloat = 5.5
        let top = CGPoint(x: c.x, y: c.y - s), left = CGPoint(x: c.x - s, y: c.y - s / 2), right = CGPoint(x: c.x + s, y: c.y - s / 2)
        let bottom = CGPoint(x: c.x, y: c.y + s), bl = CGPoint(x: c.x - s, y: c.y + s / 2), br = CGPoint(x: c.x + s, y: c.y + s / 2)
        ctx.fill({ p in p.addLines(between: [top, right, c, left]); p.closeSubpath() }, rgb(0x9AA0AA), outlineWidth: 1)
        ctx.fill({ p in p.addLines(between: [left, c, bottom, bl]); p.closeSubpath() }, rgb(0x2A2D33), outlineWidth: 1)
        ctx.fill({ p in p.addLines(between: [c, right, br, bottom]); p.closeSubpath() }, rgb(0x5A606B), outlineWidth: 1)
    case .headphones:
        for (color, width) in [(outline, CGFloat(6.4)), (rgb(0x2B2F36), CGFloat(4))] {
            ctx.stroke({ p in
                p.addArc(center: CGPoint(x: h.x, y: h.y + 2), radius: 33, startAngle: .pi * 1.02, endAngle: .pi * 1.98, clockwise: false)
            }, color, width)
        }
        for side: CGFloat in [-1, 1] {
            ctx.fill({ $0.addRoundedRect(in: CGRect(x: h.x + side * 31 - 5, y: h.y - 6, width: 10, height: 16),
                                         cornerWidth: 4, cornerHeight: 4) }, rgb(0x2B2F36), outlineWidth: 1.4)
            ctx.fillEllipse(CGPoint(x: h.x + side * 31, y: h.y + 2), 2.2, 4, look.accent)
        }
    case .beanie:
        ctx.fill({ p in
            p.move(to: CGPoint(x: h.x - 31, y: h.y - 6))
            p.addCurve(to: CGPoint(x: h.x + 31, y: h.y - 6), control1: CGPoint(x: h.x - 32, y: h.y - 46), control2: CGPoint(x: h.x + 32, y: h.y - 46))
            p.closeSubpath()
        }, look.sleeve)
        ctx.fill({ $0.addRoundedRect(in: CGRect(x: h.x - 32, y: h.y - 14, width: 64, height: 9), cornerWidth: 4, cornerHeight: 4) },
                 look.sleeveDark, outlineWidth: 1.4)
        for i in 0..<9 {
            let x = h.x - 28 + CGFloat(i) * 7
            ctx.stroke({ p in p.move(to: CGPoint(x: x, y: h.y - 12)); p.addLine(to: CGPoint(x: x, y: h.y - 7)) }, rgb(0x1A5C35), 1)
        }
        ctx.fill({ $0.addEllipse(in: CGRect(x: h.x - 6, y: h.y - 44, width: 12, height: 11)) }, look.accent, outlineWidth: 1.3)
    }
}

/// Laptop on the lap, screen facing the character (we see its back).
func drawLaptop(_ ctx: CGContext, _ look: Look) {
    ctx.fill({ $0.addRoundedRect(in: CGRect(x: -15, y: -24, width: 34, height: 5), cornerWidth: 2, cornerHeight: 2) },
             rgb(0xB8BDC8), outlineWidth: 1.3)
    ctx.fillGradient({ $0.addRoundedRect(in: CGRect(x: -13, y: -46, width: 30, height: 23), cornerWidth: 3, cornerHeight: 3) },
                     [rgb(0xDADDE4), rgb(0xA9AFBC)], from: -46, to: -23, outlineWidth: 1.4)
    ctx.fillEllipse(CGPoint(x: 2, y: -35), 3, 3, look.accent)
}

// MARK: - Outfits

/// A darker tone of `c` for the far-side limbs.
func shade(_ c: CGColor) -> CGColor {
    let k = c.components ?? [0, 0, 0, 1]
    return CGColor(red: k[0] * 0.75, green: k[1] * 0.75, blue: k[2] * 0.75, alpha: k[3])
}

func dressPath(_ p: CGMutablePath) {
    p.move(to: CGPoint(x: -9, y: -48))
    p.addLine(to: CGPoint(x: 9, y: -48))
    p.addQuadCurve(to: CGPoint(x: 17, y: -17), control: CGPoint(x: 13, y: -30))
    p.addQuadCurve(to: CGPoint(x: -17, y: -17), control: CGPoint(x: 0, y: -13))
    p.addQuadCurve(to: CGPoint(x: -9, y: -48), control: CGPoint(x: -13, y: -30))
}

/// Draws inside the dress silhouette only.
func insideDress(_ ctx: CGContext, _ draw: () -> Void) {
    ctx.saveGState()
    let p = CGMutablePath(); dressPath(p)
    ctx.addPath(p); ctx.clip()
    draw()
    ctx.restoreGState()
}

func drawOutfit(_ ctx: CGContext, _ look: Look) {
    let gold = rgb(0xE3B341)
    switch look.outfit {
    case .eden:
        ctx.fill(dressPath, look.sleeve)
        insideDress(ctx) {
            ctx.stroke({ p in p.move(to: CGPoint(x: -20, y: -21)); p.addQuadCurve(to: CGPoint(x: 20, y: -21), control: CGPoint(x: 0, y: -17)) }, gold, 1.6)
        }
        for side: CGFloat in [-1, 1] {
            ctx.fill({ p in
                p.move(to: CGPoint(x: 0, y: -47)); p.addLine(to: CGPoint(x: side * 10, y: -48))
                p.addQuadCurve(to: CGPoint(x: side * 2, y: -40), control: CGPoint(x: side * 10, y: -41))
                p.closeSubpath()
            }, white, outlineWidth: 1.1)
        }
        ctx.fill({ $0.addEllipse(in: CGRect(x: -2.5, y: -41, width: 5, height: 5)) }, gold, outlineWidth: 1)
    case .kimono:
        ctx.fill(dressPath, look.sleeve)
        insideDress(ctx) {
            // Hemp-leaf hint pattern.
            for (x, y) in [(-10, -24), (6, -22), (-3, -20), (11, -28), (-12, -30)] {
                ctx.fillEllipse(CGPoint(x: CGFloat(x), y: CGFloat(y)), 1.3, 1.3, rgb(0xD9748F))
            }
            ctx.setFillColor(rgb(0x7A2E3A))
            ctx.fill(CGRect(x: -20, y: -37, width: 40, height: 6))
            ctx.stroke({ p in p.move(to: CGPoint(x: -20, y: -34)); p.addLine(to: CGPoint(x: 20, y: -34)) }, rgb(0xF2C14E), 1)
        }
        ctx.fill({ p in
            p.move(to: CGPoint(x: -8, y: -48)); p.addLine(to: CGPoint(x: 1, y: -38)); p.addLine(to: CGPoint(x: 8, y: -48)); p.closeSubpath()
        }, white, outlineWidth: 1.1)
    case .robe:
        ctx.fill(dressPath, look.sleeve)
        insideDress(ctx) {
            ctx.stroke({ p in p.move(to: CGPoint(x: -20, y: -21)); p.addQuadCurve(to: CGPoint(x: 20, y: -21), control: CGPoint(x: 0, y: -17)) }, gold, 2)
            ctx.stroke({ p in p.move(to: CGPoint(x: 1, y: -40)); p.addLine(to: CGPoint(x: 1, y: -15)) }, gold, 1.4)
        }
        ctx.fill({ $0.addRoundedRect(in: CGRect(x: -8, y: -49, width: 17, height: 5), cornerWidth: 2, cornerHeight: 2) },
                 rgb(0x2F3A4F), outlineWidth: 1)
        ctx.fill({ $0.addEllipse(in: CGRect(x: -2, y: -43, width: 5, height: 5)) }, rgb(0xD83A3A), outlineWidth: 1)
    case .track:
        ctx.fill(dressPath, rgb(0x9A9AA8))
        insideDress(ctx) {
            ctx.setFillColor(look.sleeve)
            ctx.fill(CGRect(x: -20, y: -50, width: 40, height: 22))
            ctx.stroke({ p in p.move(to: CGPoint(x: -20, y: -28)); p.addLine(to: CGPoint(x: 20, y: -28)) }, outline, 1.2)
            ctx.stroke({ p in p.move(to: CGPoint(x: 1, y: -46)); p.addLine(to: CGPoint(x: 1, y: -28)) }, white, 1.4)
            for x: CGFloat in [-9, -2, 5, 12] {
                ctx.stroke({ p in p.move(to: CGPoint(x: x, y: -26)); p.addLine(to: CGPoint(x: x * 1.2, y: -16)) }, rgb(0x7A7A88), 0.9)
            }
        }
        ctx.fill({ $0.addRoundedRect(in: CGRect(x: -8, y: -50, width: 17, height: 5), cornerWidth: 2, cornerHeight: 2) },
                 look.sleeve, outlineWidth: 1)
    case .maid:
        ctx.fill(dressPath, look.sleeve)
        ctx.fill({ p in
            p.move(to: CGPoint(x: -8, y: -36)); p.addLine(to: CGPoint(x: 9, y: -36))
            p.addQuadCurve(to: CGPoint(x: 13, y: -19), control: CGPoint(x: 12, y: -28))
            p.addQuadCurve(to: CGPoint(x: -12, y: -19), control: CGPoint(x: 0, y: -15))
            p.addQuadCurve(to: CGPoint(x: -8, y: -36), control: CGPoint(x: -11, y: -28))
        }, white, outlineWidth: 1.1)
        ctx.fill({ p in
            p.move(to: CGPoint(x: -9, y: -48)); p.addLine(to: CGPoint(x: 10, y: -48))
            p.addLine(to: CGPoint(x: 1, y: -42)); p.closeSubpath()
        }, white, outlineWidth: 1.1)
        ctx.fill({ $0.addEllipse(in: CGRect(x: -2, y: -44, width: 5, height: 4)) }, rgb(0x5B8AD6), outlineWidth: 0.8)
    case .suit:
        // Jacket with lapels over a white shirt and a long tie.
        ctx.fill(dressPath, look.sleeve)
        insideDress(ctx) {
            ctx.fill({ p in
                p.move(to: CGPoint(x: -8, y: -49)); p.addLine(to: CGPoint(x: 9, y: -49)); p.addLine(to: CGPoint(x: 1, y: -30)); p.closeSubpath()
            }, white, outlineWidth: 1)
            ctx.fill({ p in
                p.move(to: CGPoint(x: -1.5, y: -46)); p.addLine(to: CGPoint(x: 3.5, y: -46)); p.addLine(to: CGPoint(x: 4, y: -26))
                p.addLine(to: CGPoint(x: 1, y: -22)); p.addLine(to: CGPoint(x: -2, y: -26)); p.closeSubpath()
            }, look.accent, outlineWidth: 1)
            for side: CGFloat in [-1, 1] {
                ctx.stroke({ p in
                    p.move(to: CGPoint(x: 1 + side * 9, y: -48)); p.addLine(to: CGPoint(x: 1 + side * 4, y: -38)); p.addLine(to: CGPoint(x: 1 + side * 1.5, y: -28))
                }, look.sleeveDark, 1.6)
            }
            ctx.fillEllipse(CGPoint(x: 1, y: -24), 1.2, 1.2, look.sleeveDark)
        }
    case .dragonRobe:
        ctx.fillGradient(dressPath, [look.sleeve, look.sleeveDark], from: -48, to: -17)
        insideDress(ctx) {
            // Clouds, a red dragon on the chest and a striped wave hem.
            for (x, y) in [(-12.0, -30.0), (9.0, -27.0), (-3.0, -24.0)] {
                ctx.stroke({ $0.addArc(center: CGPoint(x: CGFloat(x), y: CGFloat(y)), radius: 2.4, startAngle: .pi, endAngle: 0, clockwise: false)
                           $0.addArc(center: CGPoint(x: CGFloat(x) + 4.4, y: CGFloat(y)), radius: 2, startAngle: .pi, endAngle: 0, clockwise: false) },
                           rgb(0x4F7FC9), 1)
            }
            ctx.stroke({ p in
                p.move(to: CGPoint(x: -5, y: -30)); p.addCurve(to: CGPoint(x: 5, y: -36), control1: CGPoint(x: -7, y: -36), control2: CGPoint(x: 2, y: -31))
                p.addQuadCurve(to: CGPoint(x: 2, y: -40), control: CGPoint(x: 7, y: -39))
            }, rgb(0xC8352E), 1.8)
            ctx.fillEllipse(CGPoint(x: 2, y: -40), 1.8, 1.6, rgb(0xC8352E))
            for (y, color) in [(-21.0, rgb(0x3A6FC4)), (-19.0, white), (-17.5, rgb(0xC8352E))] {
                ctx.stroke({ p in
                    p.move(to: CGPoint(x: -20, y: CGFloat(y)))
                    for k in 0..<8 { p.addQuadCurve(to: CGPoint(x: -20 + CGFloat(k + 1) * 5, y: CGFloat(y)), control: CGPoint(x: -17.5 + CGFloat(k) * 5, y: CGFloat(y) - 2)) }
                }, color, 1.6)
            }
        }
        // Black cape collar over the shoulders with a red trim, leaving the chest's dragon in view.
        ctx.fill({ p in
            p.move(to: CGPoint(x: -15, y: -38))
            p.addQuadCurve(to: CGPoint(x: -8, y: -50), control: CGPoint(x: -15, y: -47))
            p.addLine(to: CGPoint(x: 10, y: -50))
            p.addQuadCurve(to: CGPoint(x: 17, y: -38), control: CGPoint(x: 17, y: -47))
            p.addQuadCurve(to: CGPoint(x: -15, y: -38), control: CGPoint(x: 1, y: -50))
        }, rgb(0x1E1E24), outlineWidth: 1.2)
        ctx.stroke({ p in p.move(to: CGPoint(x: -12, y: -40)); p.addQuadCurve(to: CGPoint(x: 14, y: -40), control: CGPoint(x: 1, y: -50)) }, rgb(0xC8352E), 1.2)
        ctx.fill({ $0.addRoundedRect(in: CGRect(x: -7, y: -51, width: 16, height: 5), cornerWidth: 2, cornerHeight: 2) }, rgb(0x1E1E24), outlineWidth: 1)
    case .hoodie:
        ctx.fill(dressPath, look.sleeve)
        insideDress(ctx) {
            // Kangaroo pocket and ribbed hem.
            ctx.stroke({ $0.addRoundedRect(in: CGRect(x: -9, y: -31, width: 20, height: 8), cornerWidth: 3, cornerHeight: 3) }, look.sleeveDark, 1.4)
            ctx.stroke({ p in p.move(to: CGPoint(x: -20, y: -20)); p.addQuadCurve(to: CGPoint(x: 20, y: -20), control: CGPoint(x: 0, y: -16)) }, look.sleeveDark, 1.6)
        }
        // Hood around the neck.
        ctx.stroke({ p in
            p.move(to: CGPoint(x: -10, y: -48)); p.addQuadCurve(to: CGPoint(x: 11, y: -48), control: CGPoint(x: 1, y: -39))
        }, look.sleeveDark, 3)
        for x: CGFloat in [-3, 5] {
            ctx.stroke({ p in p.move(to: CGPoint(x: x, y: -44)); p.addLine(to: CGPoint(x: x - 0.5, y: -36)) }, look.accent, 1.3)
            ctx.fillEllipse(CGPoint(x: x - 0.5, y: -35.5), 1.3, 1.3, look.accent)
        }
    }
}
