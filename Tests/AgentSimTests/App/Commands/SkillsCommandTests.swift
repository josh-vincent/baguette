import Testing
import Foundation
import ArgumentParser
@testable import AgentSim

@Suite("SkillsCommand")
struct SkillsCommandTests {

    @Test func `skills lists curated agent-sim skills with names + descriptions`() {
        let lines = SkillsCommand.renderList(skills: SkillsCommand.curated)
        #expect(lines.contains { $0.contains("agent-sim-review-workflow") })
        #expect(lines.contains { $0.contains("agent-sim-implement-feature") })
        // Every row should carry a one-line description (a colon separates
        // the name from the blurb) so the operator can grep it.
        #expect(lines.allSatisfy { $0.contains(":") })
    }

    @Test func `skills --json emits a parseable array of {name, description, hint}`() throws {
        let data = try SkillsCommand.renderJSON(skills: SkillsCommand.curated)
        let arr = try JSONDecoder().decode([SkillEntry].self, from: data)
        #expect(arr.count >= 2)
        let names = Set(arr.map(\.name))
        #expect(names.contains("agent-sim-review-workflow"))
        #expect(names.contains("agent-sim-implement-feature"))
        #expect(arr.allSatisfy { !$0.description.isEmpty })
    }

    @Test func `skills subcommand parses --json and is registered on the root`() throws {
        let cmd = try SkillsCommand.parse(["--json"])
        #expect(cmd.json == true)
        #expect(SkillsCommand.configuration.commandName == "skills")

        let names = AgentSim.configuration.subcommands.map { $0.configuration.commandName }
        #expect(names.contains("skills"))
    }
}
