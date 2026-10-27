import Foundation

enum Line: CaseIterable {
    case happy, bored, tedious, grumpy, kick, arrange, click, poke, wake, noIcons, fail, done
    // Browser window antics; every character says the generic ones in `genericLines`.
    case prankStart, prankPanic, prankInnocent
    // Lines aimed at another character; "%@" is replaced by their short name.
    case greet, greetBack, wakeOther, hit, sorry, pranked, chased, comfort, thanks, together
    // Agent mascots only; "{project}" is replaced by the session's project folder.
    case agentHello, agentWorking, agentDone, agentNeedsYou, agentBye
    // Special moves (see Skill); "{app}" is replaced by the app the user is in.
    case mindRead, mindReadIdle, readFriend, thought, bloodBurst, shrink, grow, flowers, mimicSpot, mimicEaten, mimicOut,
         guitar, guitarDone, cheer, melt, reform, morningStar, oni, oniCalm,
         wall, wallBuilt, tariff, judo, bear, parade, paradeOrder, aiRobot, aiRobotDone, applause, missile, boom,
         waterBreathing, hinokami, thunderclap, clingCry, gomuPistol, gear5, threeSword, getLost, lostAgain,
         climaTact, berries, titanShift, tatakae, odmGear, scarf, spinSlash, cleaning, divergentFist, sukuna,
         infiniteVoid, hollowPurple, divineDogs, rabbitEscape, jajanken, fishing, fishCaught, godspeed, chocolate,
         chainJail, scarletEyes, knightOath, shieldBash

    static let agentOnly: Set<Line> = [.agentHello, .agentWorking, .agentDone, .agentNeedsYou, .agentBye]
    /// Special-move lines only some characters have: their own moves, or how they react to someone else's.
    static let skillSpeakers: [Line: Set<String>] = [
        .mindRead: ["anya"], .mindReadIdle: ["anya"], .readFriend: ["anya"],
        .thought: ["nezuko", "frieren", "bocchi", "rem"],
        .bloodBurst: ["nezuko"], .shrink: ["nezuko"], .grow: ["nezuko"],
        .flowers: ["frieren"], .mimicSpot: ["frieren"], .mimicEaten: ["frieren"], .mimicOut: ["frieren"],
        .guitar: ["bocchi"], .guitarDone: ["bocchi"], .melt: ["bocchi"], .reform: ["bocchi"],
        .cheer: ["anya", "nezuko", "frieren", "rem", "trump", "putin", "xi", "kim"],
        .morningStar: ["rem"], .oni: ["rem"], .oniCalm: ["rem"],
        .wall: ["trump"], .wallBuilt: ["trump"], .tariff: ["trump"],
        .judo: ["putin"], .bear: ["putin"],
        .parade: ["xi"], .paradeOrder: ["xi"], .aiRobot: ["xi"], .aiRobotDone: ["xi"],
        .applause: ["kim"], .missile: ["kim"], .boom: ["kim"],
        .waterBreathing: ["tanjiro"], .hinokami: ["tanjiro"], .thunderclap: ["zenitsu"], .clingCry: ["zenitsu"],
        .gomuPistol: ["luffy"], .gear5: ["luffy"], .threeSword: ["zoro"], .getLost: ["zoro"], .lostAgain: ["zoro"],
        .climaTact: ["nami"], .berries: ["nami"], .titanShift: ["eren"], .tatakae: ["eren"],
        .odmGear: ["mikasa"], .scarf: ["mikasa"], .spinSlash: ["levi"], .cleaning: ["levi"],
        .divergentFist: ["yuji"], .sukuna: ["yuji"], .infiniteVoid: ["gojo"], .hollowPurple: ["gojo"],
        .divineDogs: ["megumi"], .rabbitEscape: ["megumi"], .jajanken: ["gon"], .fishing: ["gon"], .fishCaught: ["gon"],
        .godspeed: ["killua"], .chocolate: ["killua"], .chainJail: ["kurapika"], .scarletEyes: ["kurapika"],
        .knightOath: ["catknight"], .shieldBash: ["catknight"],
    ]
}

enum Language: String, CaseIterable {
    case vi, en, ja

    var title: String {
        switch self {
        case .vi: return "Tiếng Việt"
        case .en: return "English"
        case .ja: return "日本語"
        }
    }

    private static let key = "language"

    static var current: Language {
        get { UserDefaults.standard.string(forKey: key).flatMap(Language.init) ?? .vi }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: key) }
    }
}

/// Everything one character says in one language.
struct Lines {
    let shortName: String
    let lines: [Line: [String]]
    /// Special greetings for a specific friend, keyed by their id.
    var pairGreet: [String: [String]] = [:]
}

let dialogue: [Language: [String: Lines]] = [
    .vi: vietnameseLines,
    .en: englishLines,
    .ja: japaneseLines,
]

let skillNames: [Language: [Skill: String]] = [
    .vi: vietnameseSkillNames,
    .en: englishSkillNames,
    .ja: japaneseSkillNames,
]

extension Character {
    func displayName(in language: Language) -> String {
        fixedName ?? dialogue[language]?[id]?.shortName ?? name
    }

    /// A random line of `kind` in the current language; "%@" becomes the partner's name in that language.
    func line(_ kind: Line, to partner: Character? = nil, project: String = "", app: String = "") -> String? {
        let language = Language.current
        guard let own = dialogue[language]?[dialogueID ?? id] else { return nil }
        var options = own.lines[kind] ?? genericLines[language]?[kind] ?? []
        if kind == .greet, let partner, let special = own.pairGreet[partner.id] { options = special }
        guard let text = options.randomElement() else { return nil }
        return text.replacingOccurrences(of: "%@", with: partner?.displayName(in: language) ?? "")
            .replacingOccurrences(of: "{project}", with: project.isEmpty ? "project" : project)
            .replacingOccurrences(of: "{app}", with: app)
    }
}

/// What every character says for lines that aren't written per character.
let genericLines: [Language: [Line: [String]]] = [
    .vi: [.prankStart: ["Hí hí, chỗ này trông ngứa mắt...", "Thử chỉnh chỗ này xem~", "Để mình trang trí chỗ này nhé!"],
          .prankPanic: ["Á! Bị phát hiện rồi?!", "Hả?! Nó tự biến đổi đó!", "Chết, mọi người nhìn kìa!"],
          .prankInnocent: ["Mình có làm gì đâu~", "Hôm nay trời đẹp nhỉ... (huýt sáo)", "Không phải mình đâu nha."]],
    .en: [.prankStart: ["Hehe, this bit looks itchy...", "Let's tweak this~", "Time to decorate this spot!"],
          .prankPanic: ["Eek! Caught?!", "Huh?! It changed by itself!", "Oh no, everyone's looking!"],
          .prankInnocent: ["I didn't do anything~", "Nice weather today... (whistles)", "It wasn't me."]],
    .ja: [.prankStart: ["ふふ、ここ気になるなぁ…", "ここ、ちょっといじっちゃお〜", "ここをデコっちゃうね！"],
          .prankPanic: ["わっ！ばれた！？", "え！？勝手に変わったよ！", "どうしよう、みんな見てる！"],
          .prankInnocent: ["私は何もしてないよ〜", "今日はいい天気だね…（口笛）", "私じゃないからね。"]],
]
