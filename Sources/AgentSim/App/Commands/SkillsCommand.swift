import ArgumentParser
import Foundation

/// `agent-sim skills` — list the Claude Code skills paired with this CLI.
///
/// agent-sim is most useful when driven from Claude Code; the skill
/// markdown files in `~/.claude/skills/` and `<repo>/.claude/skills/`
/// teach the model the right workflow. This subcommand surfaces them so
/// a fresh operator (or `agent-sim --help` grepper) can discover what to
/// load and how to invoke it without hunting through directories.
///
/// Static list: skills are markdown documents loaded by Claude Code at
/// startup, not by agent-sim itself, so there's no scan-the-disk magic
/// — we hard-code the curated set and where to find each one. Adding a
/// new skill = adding a row to `curated`.
struct SkillsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "skills",
        abstract: "List Claude Code skills paired with agent-sim and where to find them"
    )

    @Flag(name: .long, help: "Emit JSON instead of plain text")
    var json: Bool = false

    func run() async throws {
        if json {
            let data = try Self.renderJSON(skills: Self.curated)
            print(String(decoding: data, as: UTF8.self))
        } else {
            for line in Self.renderList(skills: Self.curated) {
                print(line)
            }
            print("")
            print("Invoke any of these in Claude Code via /<skill-name>, e.g. /agent-sim-review-workflow.")
            print("The published skill at skills/agent-sim/ also lives in the repo for offline reference.")
        }
    }

    /// Curated registry. Order matters — most-likely-first.
    static let curated: [SkillEntry] = [
        SkillEntry(
            name: "agent-sim-review-workflow",
            description: "Drive the operator → agent review loop: claim a task, locate matching app code, modify it, capture an after-state, submit a result for verification.",
            hint: "Use when an operator has queued review tasks at /reviews and you want an agent to work through them.",
            location: "~/.claude/skills/agent-sim-review-workflow/SKILL.md"
        ),
        SkillEntry(
            name: "agent-sim-implement-feature",
            description: "TDD recipe for adding gestures, routes, CLI subcommands, or stream formats across Domain / Infrastructure / App + Resources/Web.",
            hint: "Use when adding a new feature that touches agent-sim itself (not the app under test).",
            location: "<repo>/.claude/skills/agent-sim-implement-feature/SKILL.md"
        ),
        SkillEntry(
            name: "agent-sim",
            description: "Canonical published skill: CLI reference + wire-protocol reference for driving simulators programmatically.",
            hint: "Use when you need to look up an exact CLI flag, gesture envelope, or HTTP route shape.",
            location: "<repo>/skills/agent-sim/SKILL.md"
        ),
    ]

    static func renderList(skills: [SkillEntry]) -> [String] {
        skills.map { "\($0.name): \($0.description)" }
    }

    static func renderJSON(skills: [SkillEntry]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(skills)
    }
}

struct SkillEntry: Codable, Equatable, Sendable {
    let name: String
    let description: String
    let hint: String
    let location: String
}
