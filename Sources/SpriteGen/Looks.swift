import AppKit

// Each look is a chibi fan-art take on a popular anime character (or a mascot for
// an AI coding agent), built from the same skeleton so all sheets share identical animation rows.

enum HairStyle { case anya, nezuko, frieren, bocchi, rem, bob, spiky, buns, ponytail,
                 trumpSwoop, putinShort, xiSlick, kimSide,
                 tanjiro, zenitsu, luffy, zoro, nami, eren, levi, yuji, gojo, megumi, gon, killua, catKnight, maomao, mikoto }
enum Outfit { case eden, kimono, robe, track, maid, hoodie, suit, judogi,
              haori, vest, haramaki, stripes, surveyCorps, gakuran, jacket, armor, hanfu, tokiwadai }

/// Likeness details drawn on the face of the real-life caricatures.
enum FaceDetail { case nose, eyeBags, cheekbones, jowls, thickBrows }

/// Extra props for the agent mascots, drawn on top of the hair-style accessories.
enum Accessory { case starClip, sparkleClip, cubeClip, glasses, headphones, beanie }

struct Look {
    let id: String
    var skin = rgb(0xFFE6D6), skinShade = rgb(0xF3C7B4)
    var hair: CGColor, hairDark: CGColor, hairLight: CGColor
    var iris: CGColor, irisDark: CGColor, irisLight: CGColor
    let style: HairStyle
    var outfit: Outfit
    var sleeve: CGColor, sleeveDark: CGColor
    var shoe = rgb(0x3A2A2A)
    var sock = white
    var restingLid: CGFloat = 0     // how much the upper lid covers the eye at rest
    var extraBlush: CGFloat = 0
    var muzzle = false
    var accent = rgb(0xE3B341)     // small details: hoodie strings, laptop logo, clips
    var extras: [Accessory] = []
    /// Suit extras: a tie (Trump's long red one) and a lapel pin. The tie color is also the
    /// Survey Corps neckwear (Mikasa's scarf, Levi's cravat) and the hood on a Jujutsu High uniform.
    var tie: CGColor? = nil
    var pin: CGColor? = nil
    var shirt = white
    /// Trousers drawn as the legs; nil shows bare legs (or the suit's trousers).
    var trousers: CGColor? = nil
    /// Width factor for the face and body (Kim is a little rounder).
    var build: CGFloat = 1
    var eyeScale: CGFloat = 1
    var blushScale: CGFloat = 1
    var face: Set<FaceDetail> = []
    /// Gojo's blindfold over the eyes (Infinite Void takes it off).
    var blindfold = false
    /// The Cat Knight carries her long sword upright in her front hand (her special moves draw their own).
    var sword = false
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
    // Maomao (The Apothecary Diaries): drawn in code, not cut from the anime.
    Look(id: "maomao",
         hair: rgb(0x173C3A), hairDark: rgb(0x102826), hairLight: rgb(0x47726B),
         iris: rgb(0x6173B5), irisDark: rgb(0x303A79), irisLight: rgb(0xCBD9FF),
         style: .maomao, outfit: .hanfu, sleeve: rgb(0x78AE77), sleeveDark: rgb(0x4A8656),
         shoe: rgb(0x244F4D), sock: rgb(0xF4E7D2), restingLid: 0.08, accent: rgb(0x7B385A)),

    // Misaka Mikoto (A Certain Magical Index): Tokiwadai uniform, short windblown light-brown hair, flower hairpin.
    Look(id: "mikoto",
         hair: rgb(0xC08A5E), hairDark: rgb(0x9A6A46), hairLight: rgb(0xE3B88F),
         iris: rgb(0x8A5A3A), irisDark: rgb(0x4A2E1E), irisLight: rgb(0xE0B896),
         style: .mikoto, outfit: .tokiwadai, sleeve: rgb(0xD9BC8F), sleeveDark: rgb(0xB89B6E),
         shoe: rgb(0x6B3A28), sock: rgb(0x2B3446), accent: rgb(0xC0303E)),

    // Anime series: three characters each for now (Nezuko is above).
    Look(id: "tanjiro",
         hair: rgb(0x5A2A2A), hairDark: rgb(0x3A1A1E), hairLight: rgb(0x9A4A44),
         iris: rgb(0xB0443A), irisDark: rgb(0x5E1E1A), irisLight: rgb(0xF0A090),
         style: .tanjiro, outfit: .haori, sleeve: rgb(0x2E8A5A), sleeveDark: rgb(0x1E6040),
         shoe: rgb(0xC8A060), accent: rgb(0x1E1E24), trousers: rgb(0x22222A)),
    Look(id: "zenitsu",
         hair: rgb(0xF7C93A), hairDark: rgb(0xE88A2A), hairLight: rgb(0xFFF0A0),
         iris: rgb(0xD9A030), irisDark: rgb(0x7A4A10), irisLight: rgb(0xFFE0A0),
         style: .zenitsu, outfit: .haori, sleeve: rgb(0xF4C542), sleeveDark: rgb(0xD9A22E),
         shoe: rgb(0xC8A060), accent: white, trousers: rgb(0x22222A)),
    Look(id: "luffy",
         hair: rgb(0x2A2A30), hairDark: rgb(0x18181C), hairLight: rgb(0x5A5A66),
         iris: rgb(0x3A2A22), irisDark: rgb(0x1A100A), irisLight: rgb(0x7A5A4A),
         style: .luffy, outfit: .vest, sleeve: rgb(0xFFE6D6), sleeveDark: rgb(0xF3C7B4),
         shoe: rgb(0x8A5A3C), sock: rgb(0xFFE6D6), accent: rgb(0xD83A3A)),
    Look(id: "zoro",
         hair: rgb(0x5FB860), hairDark: rgb(0x3A8A44), hairLight: rgb(0xA6E0A0),
         iris: rgb(0x3A3A30), irisDark: rgb(0x18180F), irisLight: rgb(0x8A8A78),
         style: .zoro, outfit: .haramaki, sleeve: rgb(0xF4F4F0), sleeveDark: rgb(0xD8D8D0),
         shoe: rgb(0x22222A), sock: rgb(0x22222A), restingLid: 0.35, accent: rgb(0x3E8A4A), trousers: rgb(0x2A2A30)),
    Look(id: "nami",
         hair: rgb(0xF58A3A), hairDark: rgb(0xD9661E), hairLight: rgb(0xFFC08A),
         iris: rgb(0xA0602A), irisDark: rgb(0x5A3010), irisLight: rgb(0xE8B080),
         style: .nami, outfit: .stripes, sleeve: rgb(0xFFE6D6), sleeveDark: rgb(0xF3C7B4),
         shoe: rgb(0xC8743A), accent: rgb(0x3A7AD9)),
    Look(id: "eren",
         hair: rgb(0x5A3E2E), hairDark: rgb(0x3A2618), hairLight: rgb(0x8A6A52),
         iris: rgb(0x3FAE9A), irisDark: rgb(0x1A5A50), irisLight: rgb(0xA0E8D8),
         style: .eren, outfit: .surveyCorps, sleeve: rgb(0x8A5A3A), sleeveDark: rgb(0x6A4028),
         shoe: rgb(0x4A3020), sock: rgb(0x4A3020), trousers: rgb(0xF0EEE6)),
    Look(id: "mikasa",
         hair: rgb(0x22222A), hairDark: rgb(0x111116), hairLight: rgb(0x55556A),
         iris: rgb(0x3A3A44), irisDark: rgb(0x18181E), irisLight: rgb(0x8A8A9A),
         style: .bob, outfit: .surveyCorps, sleeve: rgb(0x8A5A3A), sleeveDark: rgb(0x6A4028),
         shoe: rgb(0x4A3020), sock: rgb(0x4A3020), restingLid: 0.25, tie: rgb(0xC8323A), trousers: rgb(0xF0EEE6)),
    Look(id: "levi",
         hair: rgb(0x222228), hairDark: rgb(0x111114), hairLight: rgb(0x55555F),
         iris: rgb(0x6A7480), irisDark: rgb(0x2E343C), irisLight: rgb(0xB0B8C4),
         style: .levi, outfit: .surveyCorps, sleeve: rgb(0x8A5A3A), sleeveDark: rgb(0x6A4028),
         shoe: rgb(0x4A3020), sock: rgb(0x4A3020), restingLid: 0.5, tie: rgb(0xF4F4F4), trousers: rgb(0xF0EEE6),
         eyeScale: 0.85),
    Look(id: "yuji",
         hair: rgb(0xF2A0A0), hairDark: rgb(0x6A4A40), hairLight: rgb(0xFFD0D0),
         iris: rgb(0x8A5A3A), irisDark: rgb(0x4A2A18), irisLight: rgb(0xD0A080),
         style: .yuji, outfit: .gakuran, sleeve: rgb(0x2A3050), sleeveDark: rgb(0x1C2038),
         shoe: rgb(0x1E1E24), sock: rgb(0x1E1E24), tie: rgb(0xD83A3A), trousers: rgb(0x1C2038)),
    Look(id: "gojo",
         hair: rgb(0xF4F6FA), hairDark: rgb(0xC8D0E0), hairLight: white,
         iris: rgb(0x5EC8F0), irisDark: rgb(0x1E6A9A), irisLight: rgb(0xCFF0FF),
         style: .gojo, outfit: .gakuran, sleeve: rgb(0x22243A), sleeveDark: rgb(0x16182A),
         shoe: rgb(0x1E1E24), sock: rgb(0x1E1E24), trousers: rgb(0x16182A), blindfold: true),
    Look(id: "megumi",
         hair: rgb(0x24262E), hairDark: rgb(0x121318), hairLight: rgb(0x5A5E70),
         iris: rgb(0x3A5A7A), irisDark: rgb(0x1A2A40), irisLight: rgb(0x9AB8D8),
         style: .megumi, outfit: .gakuran, sleeve: rgb(0x2A3050), sleeveDark: rgb(0x1C2038),
         shoe: rgb(0x1E1E24), sock: rgb(0x1E1E24), restingLid: 0.35, trousers: rgb(0x1C2038)),
    Look(id: "gon",
         hair: rgb(0x24302A), hairDark: rgb(0x101812), hairLight: rgb(0x4E7A5A),
         iris: rgb(0x6A4A2A), irisDark: rgb(0x34200E), irisLight: rgb(0xC0A070),
         style: .gon, outfit: .jacket, sleeve: rgb(0x3E9A4E), sleeveDark: rgb(0x2A7A3A),
         shoe: rgb(0x3E7A3A), sock: rgb(0x3E7A3A)),
    Look(id: "killua",
         hair: rgb(0xEEF0F6), hairDark: rgb(0xC6CAD8), hairLight: white,
         iris: rgb(0x5AA0E8), irisDark: rgb(0x204A8A), irisLight: rgb(0xBBDCFF),
         style: .killua, outfit: .hoodie, sleeve: rgb(0xF0F0F6), sleeveDark: rgb(0xD0D2DE),
         shoe: rgb(0x5A4A7A), accent: rgb(0x6A5AA8)),
    Look(id: "kurapika",
         hair: rgb(0xF6D77A), hairDark: rgb(0xD9B24E), hairLight: rgb(0xFFF0BE),
         iris: rgb(0x6A8AA8), irisDark: rgb(0x2E4A66), irisLight: rgb(0xBCD2E8),
         style: .bob, outfit: .robe, sleeve: rgb(0x2F5FB0), sleeveDark: rgb(0x1F4590),
         shoe: rgb(0x3A3A48)),

    // A fluffy kitten knight (after new-charactor/cat-knight.png): cream fur, light ginger on top of the head,
    // big dark round eyes, steel armor with leather straps, a cream cape, and a long sword always in hand.
    Look(id: "catknight",
         skin: rgb(0xFFF4E8), skinShade: rgb(0xF0DCC4),
         hair: rgb(0xE8BC86), hairDark: rgb(0xD49A5C), hairLight: rgb(0xFFF0D8),
         iris: rgb(0x2A1E18), irisDark: rgb(0x0E0806), irisLight: rgb(0x6A5448),
         style: .catKnight, outfit: .armor, sleeve: rgb(0xB8C0CC), sleeveDark: rgb(0x8A929E),
         shoe: rgb(0x7A828E), sock: rgb(0x9AA2AE), extraBlush: 0.3, trousers: rgb(0xA8B0BC), eyeScale: 1.25, sword: true),

    // Playful political caricatures: same skin, chibi proportions and suit skeleton,
    // told apart by hair and the tie/pin they always wear.
    Look(id: "trump",
         skin: rgb(0xFFDCC0), skinShade: rgb(0xF0BC9C),
         hair: rgb(0xF4D47C), hairDark: rgb(0xCFA94E), hairLight: rgb(0xFFF1BE),
         iris: rgb(0x5B9BE0), irisDark: rgb(0x24508F), irisLight: rgb(0xBFDCFF),
         style: .trumpSwoop, outfit: .suit, sleeve: rgb(0x262C40), sleeveDark: rgb(0x191D2C),
         shoe: rgb(0x1E1E24), sock: rgb(0x191D2C), restingLid: 0.25, tie: rgb(0xD8343A)),
    Look(id: "putin",
         skin: rgb(0xFCE4D8), skinShade: rgb(0xEFC6B4),
         hair: rgb(0xC9B79A), hairDark: rgb(0x9C8B72), hairLight: rgb(0xE6DCCB),
         iris: rgb(0x7FA3BE), irisDark: rgb(0x34546B), irisLight: rgb(0xC8DDEB),
         style: .putinShort, outfit: .suit, sleeve: rgb(0x2C2E35), sleeveDark: rgb(0x1E2025),
         shoe: rgb(0x1E1E24), sock: rgb(0x1E2025), restingLid: 0.35, tie: rgb(0x7A2D6A), shirt: rgb(0xD6E2F2),
         eyeScale: 0.8, blushScale: 0.5, face: [.nose, .eyeBags, .cheekbones]),
    Look(id: "xi",
         hair: rgb(0x2A2A30), hairDark: rgb(0x16161A), hairLight: rgb(0x5C5C68),
         iris: rgb(0x6B4A3A), irisDark: rgb(0x3A2418), irisLight: rgb(0xB08A70),
         style: .xiSlick, outfit: .suit, sleeve: rgb(0x252A36), sleeveDark: rgb(0x191C25),
         shoe: rgb(0x1E1E24), sock: rgb(0x191C25), restingLid: 0.5, tie: rgb(0x4D74C2), pin: rgb(0xD63A3A), build: 1.13,
         eyeScale: 0.75, blushScale: 0.6, face: [.nose, .jowls, .thickBrows]),
    Look(id: "kim",
         hair: rgb(0x222228), hairDark: rgb(0x111114), hairLight: rgb(0x55555F),
         iris: rgb(0x5A3A2A), irisDark: rgb(0x2E1A10), irisLight: rgb(0xA07A60),
         style: .kimSide, outfit: .suit, sleeve: rgb(0x1F1F24), sleeveDark: rgb(0x141418),
         shoe: rgb(0x141418), sock: rgb(0x141418), restingLid: 0.5, tie: rgb(0xCFC7A4), build: 1.14),

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
        // Suits and judo gis come with trousers; everyone else shows bare legs.
        let color = look.trousers
            ?? ([.suit, .judogi].contains(look.outfit) ? (dark ? look.sleeveDark : look.sleeve) : (dark ? look.skinShade : look.skin))
        limb(ctx, from: CGPoint(x: x, y: -20), angle: angle, length: 17, width: 6, color: color) { foot in
            if look.style == .mikoto {
                // Dark knee socks over the lower half of the leg.
                let hip = CGPoint(x: x, y: -20)
                let knee = CGPoint(x: foot.x + (hip.x - foot.x) * 0.5, y: foot.y + (hip.y - foot.y) * 0.5)
                ctx.stroke({ $0.move(to: foot); $0.addLine(to: knee) }, outline, 7.4)
                ctx.stroke({ $0.move(to: foot); $0.addLine(to: knee) }, look.sock, 5.4)
            }
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
            ctx.fill({ $0.addEllipse(in: CGRect(x: hand.x - 3.4, y: hand.y - 3.4, width: 6.8, height: 6.8)) },
                     dark ? look.skinShade : look.skin, outlineWidth: 1.2)
        }
    }

    withHead { drawLongHair(ctx, look, head, swing: pose.hairSwing, sitting: pose.sitting) }
    leg(-5, pose.sitting ? 1.45 : pose.legBack, dark: true)
    arm(-9, pose.armBack, dark: true)
    ctx.saveGState()
    ctx.scaleBy(x: look.build, y: 1)
    drawOutfit(ctx, look)
    ctx.restoreGState()
    leg(5, pose.sitting ? 1.6 : pose.legFront, dark: false)

    withHead {
        drawHairCap(ctx, look, head)
        ctx.fill({ $0.addEllipse(in: CGRect(x: head.x - 27 * look.build, y: head.y - 25, width: 54 * look.build, height: 50)) }, look.skin)
        var facePose = pose
        if look.style == .mikoto { facePose = mikotoFace(pose) }
        if look.style == .maomao && pose.dragged {
            facePose.eyes = .angry; facePose.brows = .angry; facePose.mouth = .pout
            facePose.puffCheek = true; facePose.sweat = false
        }
        drawFace(ctx, head: head, pose: facePose, look: look)
        if look.muzzle { drawMuzzle(ctx, head) }
        if look.extras.contains(.glasses) { drawGlasses(ctx, head) }
        drawBangs(ctx, look, head)
        drawAccessories(ctx, look, head)
        for extra in look.extras where extra != .glasses { drawExtra(ctx, extra, look, head) }
    }

    arm(9, pose.armFront, dark: false)
    // The Cat Knight's long sword, held raised and angled forward so the blade passes beside her face.
    if look.sword, !pose.sitting, !pose.laptop, pose.armFront < 2 {
        let grip = CGPoint(x: 9 + sin(pose.armFront) * 15, y: -44 + cos(pose.armFront) * 15)
        drawSword(ctx, grip: grip, angle: 2.5 - pose.armFront * 0.15, length: 58, hilt: rgb(0x6A4028))
        ctx.fill({ $0.addEllipse(in: CGRect(x: grip.x - 3.4, y: grip.y - 3.4, width: 6.8, height: 6.8)) }, look.skin, outlineWidth: 1.2)
    }
    if pose.laptop { drawLaptop(ctx, look) }
    if look.style == .mikoto { drawMikotoSparks(ctx, pose, head) }
    if pose.sweat && !(look.style == .maomao && pose.dragged) && look.style != .mikoto {
        drawDrop(ctx, at: CGPoint(x: -25, y: head.y - 14), size: 1)
    }
    ctx.restoreGState()
}

// MARK: - Hair

/// Hair that hangs behind the body.
func drawLongHair(_ ctx: CGContext, _ look: Look, _ h: CGPoint, swing: CGFloat, sitting: Bool) {
    let shorten: CGFloat = sitting ? 18 : 0   // hair rests on the floor when sitting
    switch look.style {
    case .nezuko, .bocchi, .nami:
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
    case .anya, .rem, .bob, .spiky, .buns, .trumpSwoop, .putinShort, .xiSlick, .kimSide,
         .tanjiro, .zenitsu, .luffy, .zoro, .eren, .levi, .yuji, .gojo, .megumi, .gon, .killua, .mikoto:
        break
    case .maomao:
        // Two short braided tails, held with dark blue cords and ending in round beads.
        for side: CGFloat in [-1, 1] {
            let top = CGPoint(x: h.x + side * 25, y: h.y + 2)
            let end = CGPoint(x: h.x + side * 31 + swing * 10, y: h.y + 30 - shorten / 2)
            ctx.stroke({ p in p.move(to: top); p.addQuadCurve(to: end, control: CGPoint(x: top.x + side * 10, y: h.y + 18)) }, look.hairDark, 7)
            for k in 0..<3 {
                let t = CGFloat(k) / 3
                let bead = CGPoint(x: top.x + (end.x - top.x) * t, y: top.y + (end.y - top.y) * t)
                let r = 3.8 - CGFloat(k) * 0.45
                ctx.fill({ $0.addEllipse(in: CGRect(x: bead.x - r, y: bead.y - r, width: r * 2, height: r * 2)) }, look.hair, outlineWidth: 0.8)
            }
            ctx.fill({ $0.addEllipse(in: CGRect(x: end.x - 3.2, y: end.y - 3.2, width: 6.4, height: 6.4)) }, rgb(0x4D6AA2), outlineWidth: 0.9)
        }
    case .catKnight:
        // A ginger tail curling up behind her, then the cream cape over it.
        let base = CGPoint(x: h.x - 10, y: h.y + 54)
        let tip = CGPoint(x: h.x - 36 + swing * 20, y: h.y + 26)
        for (color, width) in [(outline, CGFloat(9.4)), (look.hair, CGFloat(7))] {
            ctx.stroke({ $0.move(to: base); $0.addQuadCurve(to: tip, control: CGPoint(x: h.x - 40, y: h.y + 56)) }, color, width)
        }
        ctx.fillEllipse(tip, 3.4, 3.4, look.hairLight)
        let bottom = h.y + 70 - shorten
        ctx.fill({ p in
            p.move(to: CGPoint(x: h.x + 10, y: h.y + 24))
            p.addQuadCurve(to: CGPoint(x: h.x - 50 + swing * 30, y: bottom - 8), control: CGPoint(x: h.x - 38, y: h.y + 30))
            p.addQuadCurve(to: CGPoint(x: h.x - 6 + swing * 10, y: bottom), control: CGPoint(x: h.x - 30, y: bottom + 2))
            p.addLine(to: CGPoint(x: h.x + 2, y: h.y + 40))
            p.closeSubpath()
        }, rgb(0xF2E8D2))
        for k: CGFloat in [0, 1] {
            ctx.stroke({ p in
                p.move(to: CGPoint(x: h.x - 8 - k * 10, y: h.y + 34))
                p.addQuadCurve(to: CGPoint(x: h.x - 22 - k * 14 + swing * 26, y: bottom - 4), control: CGPoint(x: h.x - 22 - k * 12, y: h.y + 50))
            }, rgb(0xD8CBB0), 1.4)
        }
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
    case .nezuko, .bocchi, .ponytail, .luffy, .zoro, .nami, .levi, .maomao:
        ctx.fill({ $0.addEllipse(in: CGRect(x: h.x - 31, y: h.y - 31, width: 62, height: 56)) }, look.hairDark)
    case .catKnight:
        // Small rounded kitten ears set wide apart, then a fluffy rim of fur around the face.
        for side: CGFloat in [-1, 1] {
            ctx.fill({ p in
                p.move(to: CGPoint(x: h.x + side * 30, y: h.y - 8))
                p.addQuadCurve(to: CGPoint(x: h.x + side * 29, y: h.y - 36), control: CGPoint(x: h.x + side * 36, y: h.y - 26))
                p.addQuadCurve(to: CGPoint(x: h.x + side * 10, y: h.y - 28), control: CGPoint(x: h.x + side * 20, y: h.y - 36))
                p.closeSubpath()
            }, look.hair)
            ctx.fill({ p in
                p.move(to: CGPoint(x: h.x + side * 27, y: h.y - 14))
                p.addQuadCurve(to: CGPoint(x: h.x + side * 27, y: h.y - 31), control: CGPoint(x: h.x + side * 31, y: h.y - 24))
                p.addQuadCurve(to: CGPoint(x: h.x + side * 15, y: h.y - 27), control: CGPoint(x: h.x + side * 20, y: h.y - 31))
                p.closeSubpath()
            }, rgb(0xFFC2CF), outlineWidth: 0)
        }
        ctx.fill({ p in
            p.addEllipse(in: CGRect(x: h.x - 31, y: h.y - 29, width: 62, height: 56))
            for k in 0..<12 {
                let a = CGFloat(k) / 12 * 2 * .pi
                p.addEllipse(in: CGRect(x: h.x + cos(a) * 30 - 5, y: h.y - 1 + sin(a) * 27 - 5, width: 10, height: 10))
            }
        }, look.skin, outlineWidth: 0)
        ctx.fill({ $0.addEllipse(in: CGRect(x: h.x - 31, y: h.y - 29, width: 62, height: 56)) }, look.skin, outlineWidth: 1.2)
    case .tanjiro, .zenitsu, .eren, .yuji, .gojo, .megumi, .gon, .killua:
        // Spikes as (angle from straight up toward the facing side, distance from the head center).
        let spikes: [(CGFloat, CGFloat)]
        switch look.style {
        case .tanjiro: spikes = [(-1.9, 36), (-1.4, 38), (-0.9, 37), (-0.4, 36), (0.2, 36), (0.8, 35), (1.4, 35)]
        case .zenitsu: spikes = [(-2, 38), (-1.5, 40), (-1, 39), (-0.5, 38), (0.1, 37), (0.7, 36), (1.3, 35), (1.8, 34)]
        case .eren: spikes = [(-2.4, 36), (-1.8, 37), (-1.2, 36), (-0.6, 35), (0, 35), (0.7, 34), (1.4, 34), (2.1, 35)]
        case .yuji: spikes = [(-1.5, 35), (-1, 37), (-0.5, 38), (0, 37), (0.5, 36), (1, 35)]
        case .gojo: spikes = [(-1.7, 39), (-1.2, 41), (-0.7, 41), (-0.2, 40), (0.3, 39), (0.8, 37), (1.3, 35)]
        case .megumi: spikes = [(-2.1, 39), (-1.6, 42), (-1.1, 41), (-0.6, 41), (-0.1, 40), (0.4, 40), (0.9, 39), (1.4, 37), (1.9, 35)]
        case .gon: spikes = [(-1.6, 39), (-1.1, 43), (-0.6, 45), (-0.15, 45), (0.3, 44), (0.75, 42), (1.2, 38)]
        default: spikes = [(-2.2, 35), (-1.8, 37), (-1.4, 36), (-1, 38), (-0.6, 37), (-0.2, 38), (0.2, 37), (0.6, 36), (1, 36), (1.4, 35), (1.8, 34)]
        }
        ctx.fill({ spikyCap($0, h, spikes) }, look.hairDark)
    case .mikoto:
        // Short, slightly windblown hair with flicks at the sides.
        ctx.fill({ p in
            p.addEllipse(in: CGRect(x: h.x - 31, y: h.y - 31, width: 62, height: 56))
            for side: CGFloat in [-1, 1] {
                p.move(to: CGPoint(x: h.x + side * 27, y: h.y - 4))
                p.addQuadCurve(to: CGPoint(x: h.x + side * 37, y: h.y + 20), control: CGPoint(x: h.x + side * 35, y: h.y + 12))
                p.addLine(to: CGPoint(x: h.x + side * 22, y: h.y + 16))
                p.closeSubpath()
            }
        }, look.hairDark)
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
    case .trumpSwoop:
        ctx.fill({ $0.addEllipse(in: CGRect(x: h.x - 31, y: h.y - 33, width: 62, height: 52)) }, look.hairDark)
    case .putinShort, .xiSlick, .kimSide:
        // Short cuts leave the ears showing.
        let w = 27 * look.build
        for side: CGFloat in [-1, 1] {
            ctx.fill({ $0.addEllipse(in: CGRect(x: h.x + side * w - 5, y: h.y - 5, width: 10, height: 15)) }, look.skin, outlineWidth: 1.4)
            ctx.fillEllipse(CGPoint(x: h.x + side * (w + 1), y: h.y + 2.5), 1.8, 3.5, look.skinShade)
        }
        // Volume behind the head: tall for Kim's flat-top and Xi's combed-back hair, none for Putin's thin crown.
        if look.style != .putinShort {
            let top: CGFloat = look.style == .kimSide ? 36 : 35
            ctx.fill({ $0.addEllipse(in: CGRect(x: h.x - w - 2, y: h.y - top, width: (w + 2) * 2, height: top + 14)) }, look.hairDark)
        }
    }
}

/// A round cap with spikes, going over the top of the head from one cheek to the other.
func spikyCap(_ p: CGMutablePath, _ h: CGPoint, _ spikes: [(CGFloat, CGFloat)]) {
    func at(_ angle: CGFloat, _ distance: CGFloat) -> CGPoint {
        CGPoint(x: h.x + sin(angle) * distance, y: h.y - 3 - cos(angle) * distance)
    }
    p.move(to: CGPoint(x: h.x - 30, y: h.y + 14))
    for (i, (angle, distance)) in spikes.enumerated() {
        p.addLine(to: at(i == 0 ? angle - 0.25 : (angle + spikes[i - 1].0) / 2, 30))
        p.addLine(to: at(angle, distance))
    }
    p.addLine(to: at(spikes[spikes.count - 1].0 + 0.25, 30))
    p.addLine(to: CGPoint(x: h.x + 30, y: h.y + 14))
    p.closeSubpath()
}

/// Fringe over the forehead. Tips are listed right-to-left relative to the head center.
func drawBangs(_ ctx: CGContext, _ look: Look, _ h: CGPoint) {
    let tips: [(CGFloat, CGFloat)]
    switch look.style {
    case .trumpSwoop, .putinShort, .xiSlick, .kimSide:
        return drawLeaderHair(ctx, look, h)
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
    case .maomao:
        tips = [(26, 1), (20, -4), (14, -10), (8, -4), (2, -15), (-4, -7), (-10, -14), (-16, -5), (-22, -9), (-27, 1)]
    case .spiky:
        tips = [(27, 4), (22, -6), (17, -2), (12, -14), (6, -6), (1, -18), (-5, -7), (-11, -15), (-17, -4), (-22, -8), (-27, 4)]
    case .ponytail:
        tips = [(26, 0), (20, -4), (12, -14), (4, -12), (-4, -10), (-12, -6), (-20, 0), (-26, 2)]
    case .tanjiro:
        tips = [(27, 2), (21, -6), (15, 0), (9, -12), (3, -4), (-3, -14), (-9, -4), (-15, -11), (-21, -1), (-27, 2)]
    case .zenitsu, .zoro:
        tips = [(26, -2), (19, -8), (12, -14), (5, -10), (-2, -16), (-9, -10), (-16, -13), (-22, -4), (-26, 0)]
    case .luffy:
        tips = [(26, 0), (20, -6), (14, -2), (8, -12), (2, -5), (-4, -13), (-10, -4), (-16, -10), (-22, -2), (-26, 2)]
    case .nami:
        tips = [(26, 4), (20, -2), (13, -10), (5, -14), (-2, -9), (-9, -5), (-16, -8), (-22, 0), (-26, 4)]
    case .eren:
        tips = [(27, 8), (21, -4), (15, 2), (9, -10), (3, -2), (-3, -12), (-9, -2), (-15, -8), (-21, 4), (-27, 8)]
    case .levi:
        // Parted in the middle, hanging like curtains.
        tips = [(26, 6), (20, 2), (13, -4), (7, -8), (2, -20), (-1, -20), (-6, -8), (-13, -4), (-20, 2), (-26, 6)]
    case .yuji, .megumi:
        tips = [(27, -2), (21, -8), (15, -4), (9, -14), (3, -8), (-3, -16), (-9, -8), (-15, -14), (-21, -4), (-27, 0)]
    case .gojo:
        tips = [(27, 0), (21, -6), (15, 2), (9, -6), (3, 4), (-3, -6), (-9, 2), (-15, -6), (-21, 0), (-27, 2)]
    case .gon:
        tips = [(26, -4), (20, -10), (13, -16), (6, -12), (0, -20), (-6, -14), (-13, -18), (-20, -10), (-26, -4)]
    case .catKnight:
        // Light ginger fur over the top of the head, fading into the cream face below.
        tips = [(27, -6), (22, -12), (16, -16), (9, -18), (4, -16), (0, -19), (-4, -16), (-9, -18), (-16, -16), (-22, -12), (-27, -6)]
    case .mikoto:
        // Uneven fringe with one longer lock swept over the right side of the face.
        tips = [(27, 12), (23, 2), (18, -6), (12, -13), (6, -4), (0, -15), (-6, -5), (-12, -13), (-18, -3), (-24, -9), (-27, 1)]
    case .killua:
        tips = [(27, 4), (22, -4), (17, 2), (12, -8), (7, 0), (2, -10), (-3, -1), (-8, -9), (-13, 0), (-18, -7), (-23, 2), (-27, 4)]
    }
    ctx.fill({ p in
        p.move(to: CGPoint(x: h.x - 30, y: h.y + 6))
        p.addCurve(to: CGPoint(x: h.x + 30, y: h.y + 6),
                   control1: CGPoint(x: h.x - 34, y: h.y - 40), control2: CGPoint(x: h.x + 34, y: h.y - 40))
        for (x, y) in tips { p.addLine(to: CGPoint(x: h.x + x, y: h.y + y)) }
        p.closeSubpath()
    }, look.hair)

    // Side locks framing the cheeks.
    if [.frieren, .nezuko, .bocchi, .nami, .eren, .maomao, .mikoto].contains(look.style) {
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

/// Smooth, combed hair for the political leaders, in place of a spiky anime fringe.
func drawLeaderHair(_ ctx: CGContext, _ look: Look, _ h: CGPoint) {
    func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: h.x + x * look.build, y: h.y + y) }
    let shape = CGMutablePath()
    func fillHair(_ build: (CGMutablePath) -> Void, outline: CGFloat = 1.6) {
        build(shape)
        ctx.fill({ $0.addPath(shape) }, look.hair, outlineWidth: outline)
    }
    /// Comb lines, kept inside the hair.
    func strand(_ points: [CGPoint], _ width: CGFloat = 1.2) {
        ctx.saveGState()
        ctx.addPath(shape); ctx.clip()
        ctx.stroke({ p in
            p.move(to: points[0]); p.addQuadCurve(to: points[2], control: points[1])
        }, look.hairDark, width)
        ctx.restoreGState()
    }
    switch look.style {
    case .trumpSwoop:
        // Swept over from the back into a big golden wave that overhangs the forehead.
        fillHair { p in
            p.move(to: pt(-31, 8))
            p.addCurve(to: pt(-8, -38), control1: pt(-37, -18), control2: pt(-28, -37))
            p.addCurve(to: pt(36, -22), control1: pt(10, -43), control2: pt(32, -37))
            p.addQuadCurve(to: pt(27, -10), control: pt(39, -12))
            p.addLine(to: pt(28, 0))
            p.addLine(to: pt(23, -6))
            p.addQuadCurve(to: pt(-2, -13), control: pt(12, -17))
            p.addQuadCurve(to: pt(-23, 4), control: pt(-17, -12))
            p.addLine(to: pt(-26, 12))
            p.closeSubpath()
        }
        strand([pt(-24, -16), pt(0, -40), pt(30, -27)])
        strand([pt(-27, -2), pt(-12, -30), pt(18, -30)])
        strand([pt(4, -15), pt(20, -24), pt(32, -18)], 1)
        ctx.stroke({ $0.addArc(center: pt(4, -26), radius: 14, startAngle: .pi * 1.15, endAngle: .pi * 1.45, clockwise: false) },
                   look.hairLight, 3)
    case .putinShort:
        // Very thin and deeply receding: short at the sides, a wispy crown the scalp shows through.
        fillHair({ p in
            p.move(to: pt(-27.5, 6))
            p.addQuadCurve(to: pt(-25, -12), control: pt(-28.5, -4))
            p.addCurve(to: pt(0, -24.5), control1: pt(-21, -22), control2: pt(-11, -24.5))
            p.addCurve(to: pt(25, -12), control1: pt(11, -24.5), control2: pt(21, -22))
            p.addQuadCurve(to: pt(27.5, 6), control: pt(28.5, -4))
            p.addLine(to: pt(25, 6))
            p.addQuadCurve(to: pt(22.5, -9), control: pt(23, -2))
            p.addQuadCurve(to: pt(14, -18), control: pt(19, -16))
            p.addQuadCurve(to: pt(5, -20.5), control: pt(10, -18.5))
            p.addQuadCurve(to: pt(-8, -19.5), control: pt(-1, -23))
            p.addQuadCurve(to: pt(-22.5, -9), control: pt(-18, -16))
            p.addQuadCurve(to: pt(-25, 6), control: pt(-23, -2))
            p.closeSubpath()
        }, outline: 0.9)
        for x: CGFloat in [-12, -3, 7, 15] { strand([pt(x, -19), pt(x * 0.7, -22.5), pt(x * 0.4, -24.5)], 0.7) }
        for side: CGFloat in [-1, 1] { strand([pt(side * 24, 3), pt(side * 25.5, -6), pt(side * 23, -14)], 0.7) }
        ctx.stroke({ $0.addArc(center: pt(2, -8), radius: 11, startAngle: .pi * 1.25, endAngle: .pi * 1.55, clockwise: false) },
                   rgb(0xFFFFFF, 0.75), 2.2)   // shine on the bare forehead
    case .xiSlick:
        // Thick black hair swept up and back into a high front, short and neat at the sides, parted on one side.
        fillHair { p in
            p.move(to: pt(-28, 4))
            p.addQuadCurve(to: pt(-29, -16), control: pt(-30, -6))
            p.addCurve(to: pt(-6, -39), control1: pt(-29, -32), control2: pt(-20, -39))
            p.addCurve(to: pt(27, -25), control1: pt(10, -40), control2: pt(25, -36))
            p.addQuadCurve(to: pt(28, -8), control: pt(31, -17))
            p.addQuadCurve(to: pt(25, -6), control: pt(27, -6))
            p.addQuadCurve(to: pt(21, -17), control: pt(23, -12))
            p.addQuadCurve(to: pt(2, -22), control: pt(13, -23.5))
            p.addQuadCurve(to: pt(-14, -19), control: pt(-6, -22))
            p.addQuadCurve(to: pt(-24, -6), control: pt(-21, -15))
            p.addLine(to: pt(-25, 4))
            p.closeSubpath()
        }
        // Comb lines running back from the hairline, and the part.
        strand([pt(17, -21), pt(14, -34), pt(-1, -41)], 1)
        strand([pt(7, -22.5), pt(2, -34), pt(-12, -39)], 1)
        strand([pt(-3, -22), pt(-9, -31), pt(-21, -35)], 1)
        strand([pt(-13, -19.5), pt(-16, -24), pt(-21, -30)], 1.6)
        ctx.stroke({ p in p.move(to: pt(-2, -35)); p.addQuadCurve(to: pt(22, -29), control: pt(12, -38)) }, look.hairLight, 2.6)
    case .kimSide:
        // Tall flat-top over shaved sides.
        fillHair { p in
            p.move(to: pt(-26, -6))
            p.addLine(to: pt(-27, -30))
            p.addQuadCurve(to: pt(28, -36), control: pt(0, -42))
            p.addQuadCurve(to: pt(28, -14), control: pt(32, -28))
            p.addLine(to: pt(22, -11))
            p.addQuadCurve(to: pt(-12, -15), control: pt(6, -17))
            p.addLine(to: pt(-22, -8))
            p.closeSubpath()
        }
        // Stubble where the sides are shaved.
        for side: CGFloat in [-1, 1] {
            ctx.fill({ p in
                p.move(to: pt(side * 27, -12)); p.addLine(to: pt(side * 22, -10))
                p.addQuadCurve(to: pt(side * 25, 4), control: pt(side * 21, -2))
                p.addQuadCurve(to: pt(side * 27, -12), control: pt(side * 28, -4))
            }, rgb(0x6E6266, 0.55), outlineWidth: 0)
        }
        ctx.stroke({ p in p.move(to: pt(-24, -33)); p.addQuadCurve(to: pt(26, -37), control: pt(0, -41)) }, look.hairLight, 2.4)
        strand([pt(-18, -20), pt(0, -28), pt(20, -28)], 1)
    default:
        break
    }
}

func drawAccessories(_ ctx: CGContext, _ look: Look, _ h: CGPoint) {
    switch look.style {
    case .bob, .spiky, .buns, .ponytail:
        break   // agent mascots use `extras` instead (Mikasa and Kurapika need nothing more)
    case .zenitsu, .nami, .eren, .levi, .megumi, .killua, .gon:
        break
    case .catKnight:
        // A faint ginger streak, fluffy cheeks, a pink nose, whiskers and the little pink bow.
        ctx.stroke({ p in p.move(to: CGPoint(x: h.x + 1, y: h.y - 22)); p.addLine(to: CGPoint(x: h.x + 2, y: h.y - 13)) },
                   rgb(0xD49A5C, 0.6), 2)
        for side: CGFloat in [-1, 1] {
            for (dx, dy, r) in [(30.0, 8.0, 5.0), (29.0, 15.0, 4.5), (24.0, 20.0, 4.0)] {
                ctx.fill({ $0.addEllipse(in: CGRect(x: h.x + side * CGFloat(dx) - CGFloat(r), y: h.y + CGFloat(dy) - CGFloat(r),
                                                    width: CGFloat(r) * 2, height: CGFloat(r) * 2)) }, look.skin, outlineWidth: 0)
            }
            for dy: CGFloat in [-2, 2] {
                ctx.stroke({ p in
                    p.move(to: CGPoint(x: h.x + 3 + side * 13, y: h.y + 12 + dy * 0.5))
                    p.addLine(to: CGPoint(x: h.x + 3 + side * 25, y: h.y + 11 + dy * 1.6))
                }, rgb(0x8A6A55, 0.8), 0.9)
            }
        }
        ctx.fill({ p in
            p.move(to: CGPoint(x: h.x + 0.5, y: h.y + 9.5)); p.addLine(to: CGPoint(x: h.x + 5.5, y: h.y + 9.5))
            p.addLine(to: CGPoint(x: h.x + 3, y: h.y + 12.5)); p.closeSubpath()
        }, rgb(0xF58AA6), outlineWidth: 0.8)
        let c = CGPoint(x: h.x + 15, y: h.y - 26)
        ctx.fill({ p in
            p.move(to: c); p.addLine(to: CGPoint(x: c.x - 7, y: c.y - 5)); p.addLine(to: CGPoint(x: c.x - 6, y: c.y + 5)); p.closeSubpath()
            p.move(to: c); p.addLine(to: CGPoint(x: c.x + 6, y: c.y - 6)); p.addLine(to: CGPoint(x: c.x + 7, y: c.y + 3)); p.closeSubpath()
        }, rgb(0xF7A1C4), outlineWidth: 1)
        ctx.fill({ $0.addEllipse(in: CGRect(x: c.x - 2.2, y: c.y - 2.2, width: 4.4, height: 4.4)) }, rgb(0xE07AA6), outlineWidth: 0.8)
    case .trumpSwoop, .putinShort, .xiSlick, .kimSide:
        break   // the leaders' hair is all drawn by drawLeaderHair
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
    case .mikoto:
        // A little flower hairpin above her left ear.
        let c = CGPoint(x: h.x - 17, y: h.y - 14)
        for k in 0..<5 {
            let a = CGFloat(k) / 5 * 2 * .pi - .pi / 2
            ctx.fill({ $0.addEllipse(in: CGRect(x: c.x + cos(a) * 3.6 - 2.3, y: c.y + sin(a) * 3.6 - 2.3, width: 4.6, height: 4.6)) },
                     rgb(0xEAF1F8), outlineWidth: 0.9)
        }
        ctx.fill({ $0.addEllipse(in: CGRect(x: c.x - 1.9, y: c.y - 1.9, width: 3.8, height: 3.8)) }, rgb(0xF2C14E), outlineWidth: 0.7)
    case .maomao:
        // Her soft blue top bow, with thin trailing ribbons.
        let c = CGPoint(x: h.x + 5, y: h.y - 31)
        let blue = rgb(0x5578B5)
        ctx.fill({ p in
            p.move(to: c); p.addLine(to: CGPoint(x: c.x - 13, y: c.y - 8)); p.addLine(to: CGPoint(x: c.x - 10, y: c.y + 6)); p.closeSubpath()
            p.move(to: c); p.addLine(to: CGPoint(x: c.x + 13, y: c.y - 8)); p.addLine(to: CGPoint(x: c.x + 10, y: c.y + 6)); p.closeSubpath()
        }, blue, outlineWidth: 1)
        ctx.fill({ $0.addEllipse(in: CGRect(x: c.x - 3.3, y: c.y - 3.3, width: 6.6, height: 6.6)) }, rgb(0x6E90C8), outlineWidth: 0.8)
        for side: CGFloat in [-1, 1] {
            ctx.stroke({ p in p.move(to: CGPoint(x: c.x + side * 4, y: c.y + 3)); p.addQuadCurve(to: CGPoint(x: c.x + side * 9, y: c.y + 14), control: CGPoint(x: c.x + side * 11, y: c.y + 6)) }, blue, 1.5)
        }
    case .tanjiro:
        // Hanafuda earrings and the scar on the forehead.
        for x: CGFloat in [-27, 28] {
            ctx.stroke({ p in p.move(to: CGPoint(x: h.x + x, y: h.y + 8)); p.addLine(to: CGPoint(x: h.x + x, y: h.y + 11)) }, outline, 1)
            ctx.fill({ $0.addRect(CGRect(x: h.x + x - 3, y: h.y + 11, width: 6, height: 9)) }, white, outlineWidth: 1)
            ctx.fillEllipse(CGPoint(x: h.x + x, y: h.y + 14), 1.8, 1.8, rgb(0xD83A3A))
        }
        ctx.fillEllipse(CGPoint(x: h.x + 14, y: h.y - 6), 3.5, 2.2, rgb(0xB8444A, 0.8))
    case .luffy:
        // Scar under the eye, then the straw hat with its red band.
        let e = CGPoint(x: h.x + eyeOffsets[1].x, y: h.y + eyeOffsets[1].y + 9)
        ctx.stroke({ p in
            p.move(to: CGPoint(x: e.x - 4, y: e.y)); p.addLine(to: CGPoint(x: e.x + 4, y: e.y))
            for dx: CGFloat in [-2, 0.5, 3] { p.move(to: CGPoint(x: e.x + dx, y: e.y - 1.5)); p.addLine(to: CGPoint(x: e.x + dx, y: e.y + 1.5)) }
        }, outline, 0.9)
        let straw = rgb(0xF2CF6A)
        ctx.fill({ $0.addEllipse(in: CGRect(x: h.x - 22, y: h.y - 46, width: 44, height: 30)) }, straw)
        ctx.fill({ $0.addRect(CGRect(x: h.x - 21.5, y: h.y - 27, width: 43, height: 6)) }, rgb(0xD83A3A), outlineWidth: 1.2)
        ctx.fill({ $0.addEllipse(in: CGRect(x: h.x - 40, y: h.y - 26, width: 80, height: 13)) }, straw)
        ctx.stroke({ $0.addEllipse(in: CGRect(x: h.x - 33, y: h.y - 24, width: 66, height: 9)) }, rgb(0xD6A84A), 1)
    case .zoro:
        // Three gold earrings on one ear.
        for y: CGFloat in [6, 10, 14] {
            ctx.fill({ $0.addEllipse(in: CGRect(x: h.x + 26, y: h.y + y, width: 3.4, height: 3.4)) }, rgb(0xE3B341), outlineWidth: 0.8)
        }
    case .yuji:
        // The marks under his eyes.
        for o in eyeOffsets {
            ctx.stroke({ p in
                p.move(to: CGPoint(x: h.x + o.x - 4, y: h.y + o.y + 8)); p.addLine(to: CGPoint(x: h.x + o.x + 3, y: h.y + o.y + 8))
            }, rgb(0x6A3A3A), 1.2)
        }
    case .gojo:
        // Blindfold over the eyes; his brows still show above it.
        guard look.blindfold else { break }
        ctx.fill({ $0.addRoundedRect(in: CGRect(x: h.x - 27, y: h.y - 5, width: 55, height: 14), cornerWidth: 4, cornerHeight: 4) },
                 rgb(0x1E1E24), outlineWidth: 1.2)
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
    case .hanfu:
        // Green wrap jacket over Maomao's long plum skirt.
        ctx.fill({ p in
            p.move(to: CGPoint(x: -11, y: -50)); p.addLine(to: CGPoint(x: 10, y: -50))
            p.addQuadCurve(to: CGPoint(x: 18, y: -29), control: CGPoint(x: 16, y: -40))
            p.addLine(to: CGPoint(x: 13, y: -24)); p.addLine(to: CGPoint(x: -16, y: -24))
            p.addQuadCurve(to: CGPoint(x: -11, y: -50), control: CGPoint(x: -16, y: -40))
            p.closeSubpath()
        }, look.sleeve)
        // Very full pleated skirt, reaching just above the shoes.
        ctx.fill({ p in
            p.move(to: CGPoint(x: -13, y: -27)); p.addLine(to: CGPoint(x: 13, y: -27))
            p.addQuadCurve(to: CGPoint(x: 25, y: -5), control: CGPoint(x: 21, y: -15))
            p.addQuadCurve(to: CGPoint(x: 12, y: -2), control: CGPoint(x: 20, y: -1))
            p.addLine(to: CGPoint(x: -13, y: -2))
            p.addQuadCurve(to: CGPoint(x: -26, y: -6), control: CGPoint(x: -21, y: -1))
            p.addQuadCurve(to: CGPoint(x: -13, y: -27), control: CGPoint(x: -22, y: -16))
            p.closeSubpath()
        }, rgb(0x87415F))
        for x: CGFloat in [-14, -7, 1, 9, 16] {
            ctx.stroke({ p in p.move(to: CGPoint(x: x * 0.72, y: -25)); p.addQuadCurve(to: CGPoint(x: x, y: -5), control: CGPoint(x: x * 1.3, y: -15)) },
                       rgb(0x5B2942, 0.75), 1.2)
        }
        // White crossed collar and the dark plum sash.
        ctx.stroke({ p in
            p.move(to: CGPoint(x: -8, y: -48)); p.addLine(to: CGPoint(x: 2, y: -34)); p.addLine(to: CGPoint(x: 9, y: -48))
        }, rgb(0xF5E7D4), 2.2)
        ctx.fill({ $0.addRect(CGRect(x: -18, y: -28, width: 36, height: 4)) }, look.accent, outlineWidth: 0.7)
    case .tokiwadai:
        // Beige blazer, white shirt, red bow and a short blue plaid skirt.
        let plaid = rgb(0x5A74A0), plaidDark = rgb(0x2E3F66), plaidLight = rgb(0xB9C6E0)
        let skirt = CGMutablePath()
        skirt.move(to: CGPoint(x: -17, y: -26))
        skirt.addQuadCurve(to: CGPoint(x: 17, y: -26), control: CGPoint(x: 0, y: -24))
        skirt.addQuadCurve(to: CGPoint(x: 23, y: -10), control: CGPoint(x: 21, y: -18))
        skirt.addQuadCurve(to: CGPoint(x: 14, y: -9), control: CGPoint(x: 20, y: -7))
        skirt.addQuadCurve(to: CGPoint(x: 5, y: -10), control: CGPoint(x: 9, y: -6))
        skirt.addQuadCurve(to: CGPoint(x: -5, y: -9), control: CGPoint(x: 0, y: -13))
        skirt.addQuadCurve(to: CGPoint(x: -14, y: -10), control: CGPoint(x: -9, y: -6))
        skirt.addQuadCurve(to: CGPoint(x: -23, y: -11), control: CGPoint(x: -20, y: -7))
        skirt.addQuadCurve(to: CGPoint(x: -17, y: -26), control: CGPoint(x: -21, y: -18))
        skirt.closeSubpath()
        ctx.fill({ $0.addPath(skirt) }, plaid)
        ctx.saveGState()
        ctx.addPath(skirt); ctx.clip()
        for x: CGFloat in [-15, -8, -1, 6, 13] {
            ctx.stroke({ p in p.move(to: CGPoint(x: x * 0.7, y: -26)); p.addLine(to: CGPoint(x: x * 1.5, y: -8)) }, plaidDark, 1.2)
        }
        for y: CGFloat in [-21, -15] {
            ctx.stroke({ p in p.move(to: CGPoint(x: -25, y: y)); p.addLine(to: CGPoint(x: 25, y: y)) }, plaidLight, 0.8)
        }
        ctx.restoreGState()
        // Blazer.
        ctx.fill({ p in
            p.move(to: CGPoint(x: -11, y: -50)); p.addLine(to: CGPoint(x: 10, y: -50))
            p.addQuadCurve(to: CGPoint(x: 16, y: -29), control: CGPoint(x: 15, y: -40))
            p.addLine(to: CGPoint(x: 13, y: -23)); p.addLine(to: CGPoint(x: -14, y: -23))
            p.addQuadCurve(to: CGPoint(x: -11, y: -50), control: CGPoint(x: -15, y: -40))
            p.closeSubpath()
        }, look.sleeve)
        ctx.fill({ p in
            p.move(to: CGPoint(x: -6, y: -50)); p.addLine(to: CGPoint(x: 6, y: -50)); p.addLine(to: CGPoint(x: 0.5, y: -35)); p.closeSubpath()
        }, white, outlineWidth: 1)
        for side: CGFloat in [-1, 1] {
            ctx.stroke({ p in p.move(to: CGPoint(x: side * 8, y: -50)); p.addLine(to: CGPoint(x: 0.5 + side * 1.2, y: -33)) }, look.sleeveDark, 1.8)
        }
        ctx.fillEllipse(CGPoint(x: 3, y: -29), 1.1, 1.1, rgb(0xE3B341))
        ctx.fillEllipse(CGPoint(x: 3, y: -25.5), 1.1, 1.1, rgb(0xE3B341))
        // Red bow.
        ctx.fill({ p in
            p.move(to: CGPoint(x: 0.5, y: -42)); p.addLine(to: CGPoint(x: -7, y: -46)); p.addLine(to: CGPoint(x: -6.5, y: -38)); p.closeSubpath()
            p.move(to: CGPoint(x: 0.5, y: -42)); p.addLine(to: CGPoint(x: 8, y: -46)); p.addLine(to: CGPoint(x: 7.5, y: -38)); p.closeSubpath()
        }, look.accent, outlineWidth: 1)
        ctx.fill({ $0.addEllipse(in: CGRect(x: -1.5, y: -44, width: 4, height: 4)) }, rgb(0x9A2430), outlineWidth: 0.8)
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
    case .suit:
        // A straight-cut jacket that stops at the hips, over the trousers drawn as legs.
        let jacket: (CGMutablePath) -> Void = { p in
            p.move(to: CGPoint(x: -10, y: -48)); p.addLine(to: CGPoint(x: 10, y: -48))
            p.addQuadCurve(to: CGPoint(x: 14, y: -19), control: CGPoint(x: 15, y: -38))
            p.addLine(to: CGPoint(x: 3, y: -18)); p.addLine(to: CGPoint(x: 1, y: -21)); p.addLine(to: CGPoint(x: -1, y: -18))
            p.addLine(to: CGPoint(x: -13, y: -19))
            p.addQuadCurve(to: CGPoint(x: -10, y: -48), control: CGPoint(x: -14, y: -38))
        }
        ctx.fill(jacket, look.sleeve)
        ctx.saveGState()
        let clip = CGMutablePath(); jacket(clip)
        ctx.addPath(clip); ctx.clip()
        // Shirt showing in the V of the jacket.
        ctx.fill({ p in
            p.move(to: CGPoint(x: -8, y: -49)); p.addLine(to: CGPoint(x: 10, y: -49))
            p.addLine(to: CGPoint(x: 2, y: -30)); p.addLine(to: CGPoint(x: 0, y: -30)); p.closeSubpath()
        }, look.shirt, outlineWidth: 0)
        if let tie = look.tie {
            // Trump's runs long, past the jacket button.
            let tip: CGFloat = look.style == .trumpSwoop ? -24 : -31
            ctx.fill({ p in
                p.move(to: CGPoint(x: -1.5, y: -46)); p.addLine(to: CGPoint(x: 3.5, y: -46))
                p.addLine(to: CGPoint(x: 2.6, y: -43.5)); p.addLine(to: CGPoint(x: 3.6, y: tip + 3))
                p.addLine(to: CGPoint(x: 1, y: tip)); p.addLine(to: CGPoint(x: -1.6, y: tip + 3))
                p.addLine(to: CGPoint(x: -0.6, y: -43.5)); p.closeSubpath()
            }, tie, outlineWidth: 1)
        }
        // Shirt collar points.
        for side: CGFloat in [-1, 1] {
            ctx.fill({ p in
                p.move(to: CGPoint(x: 1 + side * 1.5, y: -47)); p.addLine(to: CGPoint(x: 1 + side * 8, y: -49))
                p.addLine(to: CGPoint(x: 1 + side * 4.5, y: -42)); p.closeSubpath()
            }, look.shirt, outlineWidth: 0.9)
        }
        // Lapels.
        for side: CGFloat in [-1, 1] {
            ctx.fill({ p in
                p.move(to: CGPoint(x: 1 + side * 10, y: -49)); p.addLine(to: CGPoint(x: 1 + side * 5, y: -42))
                p.addLine(to: CGPoint(x: 1 + side * 8, y: -40)); p.addLine(to: CGPoint(x: 1 + side * 1.2, y: -29))
                p.addLine(to: CGPoint(x: 1 + side * 14, y: -40)); p.closeSubpath()
            }, look.sleeveDark, outlineWidth: 1)
        }
        ctx.stroke({ $0.move(to: CGPoint(x: 1, y: -29)); $0.addLine(to: CGPoint(x: 1, y: -21)) }, look.sleeveDark, 1)
        ctx.restoreGState()
        ctx.fillEllipse(CGPoint(x: 3.5, y: -26), 1.3, 1.3, rgb(0x0E0E12))
        if let pin = look.pin {
            ctx.fill({ $0.addEllipse(in: CGRect(x: -9, y: -41, width: 4.4, height: 4.4)) }, pin, outlineWidth: 0.9)
        }
    case .haori:
        // Haori over the black Demon Slayer uniform: Tanjiro's checks, Zenitsu's white triangles.
        ctx.fill(dressPath, look.sleeve)
        insideDress(ctx) {
            if look.style == .tanjiro {
                ctx.setFillColor(look.accent)
                for row in 0..<6 {
                    for col in 0..<7 where (row + col) % 2 == 0 {
                        ctx.fill(CGRect(x: -21 + CGFloat(col) * 6, y: -50 + CGFloat(row) * 6, width: 6, height: 6))
                    }
                }
            } else {
                for (x, y) in [(-12.0, -24.0), (2.0, -22.0), (10.0, -30.0), (-8.0, -36.0), (6.0, -42.0)] {
                    ctx.fill({ p in
                        p.move(to: CGPoint(x: x - 4, y: y + 3)); p.addLine(to: CGPoint(x: x + 4, y: y + 3)); p.addLine(to: CGPoint(x: x, y: y - 4))
                        p.closeSubpath()
                    }, look.accent, outlineWidth: 0)
                }
            }
            ctx.setFillColor(rgb(0x1E1E28))
            ctx.fill(CGRect(x: -4, y: -50, width: 10, height: 40))
            ctx.setFillColor(white)
            ctx.fill(CGRect(x: -4, y: -31, width: 10, height: 3))
        }
        ctx.stroke({ p in
            p.move(to: CGPoint(x: -4, y: -48)); p.addLine(to: CGPoint(x: -5, y: -17))
            p.move(to: CGPoint(x: 6, y: -48)); p.addLine(to: CGPoint(x: 7, y: -17))
        }, outline, 1)
    case .vest:
        // Blue shorts, yellow sash and an open red vest over a bare chest.
        ctx.fill(dressPath, rgb(0x3B6FB6))
        insideDress(ctx) {
            ctx.setFillColor(look.accent)
            ctx.fill(CGRect(x: -20, y: -50, width: 40, height: 22))
            ctx.fill({ p in
                p.move(to: CGPoint(x: -5, y: -50)); p.addLine(to: CGPoint(x: 7, y: -50))
                p.addLine(to: CGPoint(x: 4, y: -28)); p.addLine(to: CGPoint(x: -2, y: -28)); p.closeSubpath()
            }, look.skin, outlineWidth: 1)
            ctx.setFillColor(rgb(0xF2C14E))
            ctx.fill(CGRect(x: -20, y: -30, width: 40, height: 3))
            ctx.stroke({ p in
                p.move(to: CGPoint(x: -1, y: -42)); p.addLine(to: CGPoint(x: 3, y: -36))
                p.move(to: CGPoint(x: 3, y: -42)); p.addLine(to: CGPoint(x: -1, y: -36))
            }, rgb(0xC8786A), 0.9)
        }
    case .haramaki:
        // White shirt, green belly band and three swords at the hip.
        for (i, handle) in [white, rgb(0x1E1E24), rgb(0xB8323A)].enumerated() {
            let x = -12 - CGFloat(i) * 2.5
            ctx.stroke({ p in p.move(to: CGPoint(x: x, y: -34)); p.addLine(to: CGPoint(x: x - 12, y: -12)) }, outline, 3.6)
            ctx.stroke({ p in p.move(to: CGPoint(x: x, y: -34)); p.addLine(to: CGPoint(x: x - 12, y: -12)) }, handle, 2)
        }
        ctx.fill(dressPath, look.sleeve)
        insideDress(ctx) {
            ctx.setFillColor(look.accent)
            ctx.fill(CGRect(x: -20, y: -35, width: 40, height: 10))
            ctx.setFillColor(look.trousers ?? outline)
            ctx.fill(CGRect(x: -20, y: -25, width: 40, height: 10))
        }
        ctx.stroke({ p in p.move(to: CGPoint(x: -4, y: -48)); p.addLine(to: CGPoint(x: 1, y: -40)); p.addLine(to: CGPoint(x: 6, y: -48)) }, look.sleeveDark, 1.4)
    case .stripes:
        // Striped top and a denim skirt.
        ctx.fill(dressPath, rgb(0x4A72B8))
        insideDress(ctx) {
            ctx.setFillColor(white)
            ctx.fill(CGRect(x: -20, y: -48, width: 40, height: 13))
            ctx.setFillColor(look.accent)
            for y in stride(from: CGFloat(-46), to: -35, by: 4) { ctx.fill(CGRect(x: -20, y: y, width: 40, height: 2)) }
            ctx.stroke({ p in p.move(to: CGPoint(x: -20, y: -34)); p.addLine(to: CGPoint(x: 20, y: -34)) }, rgb(0x6A4A2A), 2)
            ctx.stroke({ p in p.move(to: CGPoint(x: 1, y: -33)); p.addLine(to: CGPoint(x: 1, y: -16)) }, rgb(0x34558E), 1)
        }
        ctx.fill({ $0.addRect(CGRect(x: -9, y: -50, width: 19, height: 3)) }, look.skin, outlineWidth: 0)
    case .surveyCorps:
        // Short brown jacket over a white shirt, the gear harness, the Wings of Freedom, and any neckwear.
        ctx.fill(dressPath, look.shirt)
        insideDress(ctx) {
            ctx.setFillColor(look.sleeve)
            ctx.fill(CGRect(x: -20, y: -50, width: 17, height: 17))
            ctx.fill(CGRect(x: 5, y: -50, width: 15, height: 17))
            ctx.stroke({ p in
                p.move(to: CGPoint(x: -20, y: -33)); p.addLine(to: CGPoint(x: -3, y: -33))
                p.move(to: CGPoint(x: 5, y: -33)); p.addLine(to: CGPoint(x: 20, y: -33))
            }, outline, 1)
            ctx.stroke({ p in
                p.move(to: CGPoint(x: -20, y: -29)); p.addLine(to: CGPoint(x: 20, y: -29))
                p.move(to: CGPoint(x: -6, y: -29)); p.addLine(to: CGPoint(x: -10, y: -17))
                p.move(to: CGPoint(x: 8, y: -29)); p.addLine(to: CGPoint(x: 12, y: -17))
            }, rgb(0x3A2418), 1.6)
        }
        ctx.fillEllipse(CGPoint(x: 10, y: -40), 2, 2, rgb(0x46689E))
        ctx.fillEllipse(CGPoint(x: 9, y: -40), 1.2, 1.6, white)
        if let neck = look.tie {
            if look.style == .levi {
                ctx.fill({ p in
                    p.move(to: CGPoint(x: -4, y: -48)); p.addLine(to: CGPoint(x: 6, y: -48)); p.addLine(to: CGPoint(x: 1, y: -38)); p.closeSubpath()
                }, neck, outlineWidth: 1)
            } else {
                ctx.fill({ $0.addRoundedRect(in: CGRect(x: -10, y: -51, width: 21, height: 6), cornerWidth: 3, cornerHeight: 3) },
                         neck, outlineWidth: 1.1)
                ctx.fill({ $0.addRoundedRect(in: CGRect(x: -12, y: -48, width: 5, height: 14), cornerWidth: 2, cornerHeight: 2) },
                         neck, outlineWidth: 1.1)
            }
        }
    case .gakuran:
        // Jujutsu High uniform: a high collar, gold swirl buttons, and a hood when `tie` is set.
        if let hood = look.tie {
            ctx.fill({ $0.addRoundedRect(in: CGRect(x: -16, y: -53, width: 16, height: 10), cornerWidth: 5, cornerHeight: 5) },
                     hood, outlineWidth: 1.2)
        }
        ctx.fill(dressPath, look.sleeve)
        ctx.stroke({ p in p.move(to: CGPoint(x: 1, y: -46)); p.addLine(to: CGPoint(x: 1, y: -17)) }, look.sleeveDark, 1.2)
        ctx.fill({ $0.addRoundedRect(in: CGRect(x: -9, y: -51, width: 20, height: 6), cornerWidth: 2, cornerHeight: 2) },
                 look.sleeveDark, outlineWidth: 1)
        for y: CGFloat in [-42, -34, -26] {
            ctx.fillEllipse(CGPoint(x: 3, y: y), 1.8, 1.8, look.accent)
        }
    case .jacket:
        // Gon's green jacket and shorts over a black top.
        ctx.fill(dressPath, look.sleeve)
        insideDress(ctx) {
            ctx.setFillColor(look.sleeveDark)
            ctx.fill(CGRect(x: -20, y: -27, width: 40, height: 12))
            ctx.setFillColor(rgb(0x1E1E24))
            ctx.fill(CGRect(x: -3, y: -50, width: 8, height: 22))
        }
        ctx.stroke({ p in
            p.move(to: CGPoint(x: -3, y: -48)); p.addLine(to: CGPoint(x: -3, y: -28))
            p.move(to: CGPoint(x: 5, y: -48)); p.addLine(to: CGPoint(x: 5, y: -28))
        }, outline, 1)
    case .armor:
        // Chain mail under a steel breastplate, a leather belt, pauldrons, and the sword at her hip.
        ctx.stroke({ $0.move(to: CGPoint(x: -12, y: -31)); $0.addLine(to: CGPoint(x: -24, y: -10)) }, outline, 5)
        ctx.stroke({ $0.move(to: CGPoint(x: -12, y: -31)); $0.addLine(to: CGPoint(x: -24, y: -10)) }, rgb(0x6A4028), 3)
        ctx.fillGradient(dressPath, [rgb(0x9AA2AE), rgb(0x6E7682)], from: -48, to: -17)
        insideDress(ctx) {
            for (row, y) in stride(from: CGFloat(-27), to: -17, by: 3).enumerated() {
                for x in stride(from: row % 2 == 0 ? CGFloat(-19) : -17.5, to: 20, by: 3) {
                    ctx.fillEllipse(CGPoint(x: x, y: y), 0.8, 0.8, rgb(0x4E5662))
                }
            }
            ctx.fillGradient({ $0.addRoundedRect(in: CGRect(x: -15, y: -50, width: 32, height: 21), cornerWidth: 7, cornerHeight: 7) },
                             [rgb(0xEEF1F5), rgb(0xA8B0BC)], from: -50, to: -29, outlineWidth: 1.2)
            ctx.stroke({ $0.move(to: CGPoint(x: 1, y: -47)); $0.addLine(to: CGPoint(x: 1, y: -31)) }, white, 1.2)
            ctx.stroke({ $0.move(to: CGPoint(x: -12, y: -50)); $0.addLine(to: CGPoint(x: 14, y: -30)) }, outline, 4.2)
            ctx.stroke({ $0.move(to: CGPoint(x: -12, y: -50)); $0.addLine(to: CGPoint(x: 14, y: -30)) }, rgb(0x7A4A2C), 2.6)
            ctx.setFillColor(rgb(0x6A4028))
            ctx.fill(CGRect(x: -20, y: -30, width: 40, height: 4))
        }
        ctx.fill({ $0.addRect(CGRect(x: -1, y: -30.5, width: 5, height: 5)) }, rgb(0xE3B341), outlineWidth: 0.9)
        ctx.stroke({ $0.move(to: CGPoint(x: -16, y: -34)); $0.addLine(to: CGPoint(x: -9, y: -29)) }, rgb(0xE3B341), 2.4)
        for side: CGFloat in [-1, 1] {
            ctx.fillGradient({ $0.addEllipse(in: CGRect(x: 1 + side * 11 - 7, y: -51, width: 14, height: 10)) },
                             [rgb(0xE6EAF0), rgb(0x9AA2AE)], from: -51, to: -41, outlineWidth: 1.2)
        }
    case .judogi:
        // White judo jacket wrapped left over right, tied with a black belt.
        ctx.fill({ p in
            p.move(to: CGPoint(x: -10, y: -48)); p.addLine(to: CGPoint(x: 10, y: -48))
            p.addQuadCurve(to: CGPoint(x: 14, y: -19), control: CGPoint(x: 15, y: -38))
            p.addLine(to: CGPoint(x: -13, y: -19))
            p.addQuadCurve(to: CGPoint(x: -10, y: -48), control: CGPoint(x: -14, y: -38))
        }, look.sleeve)
        ctx.fill({ p in
            p.move(to: CGPoint(x: -7, y: -48)); p.addLine(to: CGPoint(x: 8, y: -48)); p.addLine(to: CGPoint(x: 1, y: -38)); p.closeSubpath()
        }, look.skin, outlineWidth: 1)
        ctx.stroke({ p in
            p.move(to: CGPoint(x: -9, y: -48)); p.addLine(to: CGPoint(x: 8, y: -27))
            p.move(to: CGPoint(x: 10, y: -48)); p.addLine(to: CGPoint(x: 2, y: -38))
        }, look.sleeveDark, 2.6)
        ctx.fill({ $0.addRect(CGRect(x: -14, y: -29, width: 28, height: 4.5)) }, rgb(0x1E1E22), outlineWidth: 1)
        ctx.fill({ p in
            p.move(to: CGPoint(x: 4, y: -26)); p.addLine(to: CGPoint(x: 1, y: -18)); p.addLine(to: CGPoint(x: 4, y: -18))
            p.addLine(to: CGPoint(x: 6, y: -25)); p.addLine(to: CGPoint(x: 9, y: -18)); p.addLine(to: CGPoint(x: 12, y: -19))
            p.addLine(to: CGPoint(x: 8, y: -26)); p.closeSubpath()
        }, rgb(0x1E1E22), outlineWidth: 1)
    }
}

// MARK: - Misaka Mikoto

/// Tsundere faces, laid over the shared animations: huffy at rest, flustered when happy or picked up.
func mikotoFace(_ pose: Pose) -> Pose {
    var p = pose
    if pose.dragged {
        p.eyes = .wide; p.brows = .angry; p.mouth = .wavy; p.blush = 1; p.sweat = false
        return p
    }
    switch pose.eyes {
    case .happy:
        // "I-I'm not happy or anything!"
        p.brows = .angry; p.mouth = .smirk; p.blush = 1
    case .teary:
        p.blush = 1; p.mouth = .pout
    case .half, .sleepy:
        if !pose.sitting || pose.mouth.isFlat { p.mouth = .pout }
        p.blush = max(p.blush, 0.7)
    case .open:
        if case .smile = pose.mouth { p.mouth = .pout; p.brows = .angry; p.blush = 0.9 }
        else if case .open = pose.mouth { p.blush = 0.8 }
    default:
        p.blush = max(p.blush, 0.9)
    }
    return p
}

extension Mouth {
    var isFlat: Bool { if case .flat = self { return true } else { return false } }
}

/// Little blue sparks crackling around her hair when she is upset.
func drawMikotoSparks(_ ctx: CGContext, _ pose: Pose, _ head: CGPoint) {
    guard pose.puffCheek else { return }
    let seed = Int((pose.bob + 10) * 7) + Int((pose.legFront + 1) * 10)
    for side in [-1, 1] {
        let base = CGPoint(x: head.x + CGFloat(side) * 31, y: head.y - 14 + CGFloat((seed + side) % 5) * 3)
        var pt = base
        let path = CGMutablePath(); path.move(to: pt)
        for k in 0..<4 {
            pt = CGPoint(x: pt.x + CGFloat(side) * 4, y: pt.y + (k % 2 == 0 ? -5 : 5) + CGFloat((seed + k) % 3))
            path.addLine(to: pt)
        }
        ctx.stroke({ $0.addPath(path) }, rgb(0xFFFFFF, 0.95), 3.2)
        ctx.stroke({ $0.addPath(path) }, rgb(0x6FB8FF), 1.6)
    }
}
