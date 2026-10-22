import Foundation

enum Line: CaseIterable {
    case happy, bored, tedious, grumpy, kick, arrange, click, poke, wake, noIcons, fail, done
    // Lines aimed at another character; "%@" is replaced by their short name.
    case greet, greetBack, wakeOther, hit, sorry, pranked, chased, comfort, thanks, together
    // Agent mascots only; "{project}" is replaced by the session's project folder.
    case agentHello, agentWorking, agentDone, agentNeedsYou, agentBye
    // Special moves (see Skill); "{app}" is replaced by the app the user is in.
    case mindRead, mindReadIdle, readFriend, thought, bloodBurst, shrink, grow, flowers, mimicSpot, mimicEaten, mimicOut,
         guitar, guitarDone, cheer, melt, reform, morningStar, oni, oniCalm,
         speech, speechDone, fired, judo, fishing, fishCaught, football, footballDone, panda, pandaBye

    static let agentOnly: Set<Line> = [.agentHello, .agentWorking, .agentDone, .agentNeedsYou, .agentBye]
    /// Special-move lines only some characters have: their own moves, or how they react to someone else's.
    static let skillSpeakers: [Line: Set<String>] = [
        .mindRead: ["anya"], .mindReadIdle: ["anya"], .readFriend: ["anya"],
        .thought: ["nezuko", "frieren", "bocchi", "rem", "trump", "putin", "xi"],
        .bloodBurst: ["nezuko"], .shrink: ["nezuko"], .grow: ["nezuko"],
        .flowers: ["frieren"], .mimicSpot: ["frieren"], .mimicEaten: ["frieren"], .mimicOut: ["frieren"],
        .guitar: ["bocchi"], .guitarDone: ["bocchi"], .melt: ["bocchi"], .reform: ["bocchi"],
        .cheer: ["anya", "nezuko", "frieren", "rem", "trump", "putin", "xi"],
        .morningStar: ["rem"], .oni: ["rem"], .oniCalm: ["rem"],
        .speech: ["trump"], .speechDone: ["trump"], .fired: ["trump"],
        .judo: ["putin"], .fishing: ["putin"], .fishCaught: ["putin"],
        .football: ["xi"], .footballDone: ["xi"], .panda: ["xi"], .pandaBye: ["xi"],
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
        var options = own.lines[kind] ?? []
        if kind == .greet, let partner, let special = own.pairGreet[partner.id] { options = special }
        guard let text = options.randomElement() else { return nil }
        return text.replacingOccurrences(of: "%@", with: partner?.displayName(in: language) ?? "")
            .replacingOccurrences(of: "{project}", with: project.isEmpty ? "project" : project)
            .replacingOccurrences(of: "{app}", with: app)
    }
}
