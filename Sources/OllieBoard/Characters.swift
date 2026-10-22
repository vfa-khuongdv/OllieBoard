import Foundation

enum Behavior: CaseIterable {
    case wander, kick, arrange, bored, sleep, grumpy, happy, social, skill
}

/// Special moves from each character's story, used now and then or picked from the right-click menu.
enum Skill: String {
    case mindRead, readFriend       // Anya
    case bloodBurst, resize         // Nezuko
    case flowerField, mimic         // Frieren
    case guitarSolo, melt           // Bocchi
    case morningStar, oniForm       // Rem

    var title: String { skillNames[Language.current]?[self] ?? rawValue }
}

/// Personality only; what each character says lives in the Dialogue+<Language> files.
struct Character {
    let id: String
    let name: String
    let anime: String
    let walkSpeed: Double
    let weights: [Behavior: Double]
    /// Animation used when the character is upset (Bocchi sulks instead of stomping).
    let grumpyAnim: Anim
    /// Runs away from the mouse cursor.
    let shy: Bool
    /// Likes waking up sleeping friends.
    let prankster: Bool
    /// Agent mascots: a shared dialogue table and a fixed display name.
    var dialogueID: String? = nil
    var fixedName: String? = nil
    var skills: [Skill] = []
    /// Sprite sheet name when it differs from `id` (agent mascots borrow a character's look).
    var sprite: String? = nil
}

extension AgentKind {
    /// The mascot for one running session of this agent, drawn with `look`'s sprite sheet.
    func character(pid: Int32, look: Character) -> Character {
        Character(id: "agent-\(pid)", name: title, anime: "AI agent", walkSpeed: 95,
                  weights: [.wander: 3, .kick: 1, .arrange: 0.5, .bored: 1, .sleep: 0.5, .grumpy: 0.3, .happy: 1.5, .social: 1.5],
                  grumpyAnim: .grumpy, shy: false, prankster: false,
                  dialogueID: "agent", fixedName: title, sprite: look.id)
    }
}

let allCharacters: [Character] = [
    Character(
        id: "anya", name: "Anya Forger", anime: "Spy x Family", walkSpeed: 95,
        weights: [.wander: 3, .kick: 3, .arrange: 1, .bored: 1.5, .sleep: 1, .grumpy: 1, .happy: 2, .social: 2.5, .skill: 1.2],
        grumpyAnim: .grumpy, shy: false, prankster: true, skills: [.mindRead, .readFriend]),
    Character(
        id: "nezuko", name: "Nezuko Kamado", anime: "Kimetsu no Yaiba", walkSpeed: 100,
        weights: [.wander: 3, .kick: 2, .arrange: 1, .bored: 1, .sleep: 2.5, .grumpy: 0.5, .happy: 2, .social: 2, .skill: 1],
        grumpyAnim: .grumpy, shy: false, prankster: false, skills: [.bloodBurst, .resize]),
    Character(
        id: "frieren", name: "Frieren", anime: "Sousou no Frieren", walkSpeed: 70,
        weights: [.wander: 2, .kick: 1, .arrange: 0.7, .bored: 3, .sleep: 3, .grumpy: 0.5, .happy: 0.5, .social: 0.8, .skill: 1.2],
        grumpyAnim: .grumpy, shy: false, prankster: false, skills: [.flowerField, .mimic]),
    Character(
        id: "bocchi", name: "Hitori Gotoh", anime: "Bocchi the Rock!", walkSpeed: 85,
        weights: [.wander: 2, .kick: 0.7, .arrange: 1, .bored: 2, .sleep: 1, .grumpy: 1, .happy: 0.7, .social: 0.3, .skill: 1],
        grumpyAnim: .sad, shy: true, prankster: false, skills: [.guitarSolo, .melt]),
    Character(
        id: "rem", name: "Rem", anime: "Re:Zero", walkSpeed: 105,
        weights: [.wander: 2, .kick: 1, .arrange: 4, .bored: 1, .sleep: 0.5, .grumpy: 1, .happy: 1.5, .social: 1.5, .skill: 1],
        grumpyAnim: .grumpy, shy: false, prankster: false, skills: [.morningStar, .oniForm]),
]
