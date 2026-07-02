import Foundation
import Testing
@testable import SecondChair

@MainActor
@Suite(.serialized)
struct WorkspaceStoreTests {
    private let fixedDate = Date(timeIntervalSince1970: 1_782_950_400)

    @Test
    func humanDecisionPersistsApprovalAndAuditEvent() throws {
        let fixture = makeFixture()
        defer { fixture.cleanup() }
        let item = try #require(fixture.store.readyItems.first)

        let event = try fixture.store.recordDecision(
            workItemID: item.id,
            targetState: .approved,
            rationale: "Proposal terms and owner are confirmed."
        )

        #expect(event.timestamp == fixedDate)
        #expect(event.actionSummary == item.title)
        #expect(event.rationale == "Proposal terms and owner are confirmed.")
        #expect(fixture.store.approvalRecord(for: item.id)?.state == .approved)
        #expect(fixture.store.decisionEvents.count == 1)

        let restoredStore = WorkspaceStore(
            defaults: fixture.defaults,
            clock: { fixedDate }
        )
        #expect(restoredStore.approvalRecord(for: item.id)?.state == .approved)
        #expect(restoredStore.decisionEvents == [event])
    }

    @Test
    func pendingApprovalsAndCompletedDecisionsPersistSeparately() throws {
        let fixture = makeFixture()
        defer { fixture.cleanup() }
        let approvalCount = fixture.store.approvalRecords.count
        let item = try #require(fixture.store.readyItems.first)

        #expect(fixture.store.decisionEvents.isEmpty)
        try fixture.store.recordDecision(
            workItemID: item.id,
            targetState: .held,
            rationale: "Waiting for an owner."
        )

        #expect(fixture.store.approvalRecords.count == approvalCount)
        #expect(fixture.store.decisionEvents.count == 1)
        #expect(fixture.store.pendingApprovalRecords.contains(where: { $0.workItemID == item.id }))
    }

    @Test
    func decisionHistoryIsAppendOnlyAcrossTransitions() throws {
        let fixture = makeFixture()
        defer { fixture.cleanup() }
        let item = try #require(fixture.store.readyItems.first)

        let held = try fixture.store.recordDecision(
            workItemID: item.id,
            targetState: .held,
            rationale: "Need finance confirmation."
        )
        let returned = try fixture.store.recordDecision(
            workItemID: item.id,
            targetState: .ready,
            rationale: "Finance confirmation received."
        )

        #expect(fixture.store.decisionEvents == [held, returned])
        #expect(held.priorState == .ready)
        #expect(held.nextState == .held)
        #expect(returned.priorState == .held)
        #expect(returned.nextState == .ready)
    }

    @Test
    func rationaleIsRequiredBeforeStateChanges() throws {
        let fixture = makeFixture()
        defer { fixture.cleanup() }
        let item = try #require(fixture.store.readyItems.first)

        #expect(throws: WorkspaceDecisionError.rationaleRequired) {
            try fixture.store.recordDecision(
                workItemID: item.id,
                targetState: .approved,
                rationale: "   "
            )
        }
        #expect(fixture.store.approvalRecord(for: item.id)?.state == .ready)
        #expect(fixture.store.decisionEvents.isEmpty)
    }

    @Test
    func rejectedActionsRemainAuditable() throws {
        let fixture = makeFixture()
        defer { fixture.cleanup() }
        let item = try #require(fixture.store.readyItems.first)

        try fixture.store.recordDecision(
            workItemID: item.id,
            targetState: .rejected,
            rationale: "The target profile is out of scope."
        )

        #expect(fixture.store.rejectedItems.map(\.id).contains(item.id))
        #expect(fixture.store.decisionEvents.last?.nextState == .rejected)
        #expect(fixture.store.decisionEvents.last?.rationale == "The target profile is out of scope.")
    }

    @Test
    func manusAndConnectorActionsCannotAutoApprove() throws {
        let fixture = makeFixture()
        defer { fixture.cleanup() }
        let manus = try #require(
            fixture.store.approvalRecords.first(where: { $0.kind == .manusWaiting })
        )
        let connector = try #require(
            fixture.store.approvalRecords.first(where: { $0.kind == .connectorAction })
        )

        #expect(!fixture.store.attemptAutomatedApproval(manus.workItemID))
        #expect(!fixture.store.attemptAutomatedApproval(connector.workItemID))
        #expect(fixture.store.approvalRecord(for: manus.workItemID)?.state == manus.state)
        #expect(fixture.store.approvalRecord(for: connector.workItemID)?.state == connector.state)
        #expect(fixture.store.decisionEvents.isEmpty)
    }

    @Test
    func briefVersionsPersistTimestampAndSourceContext() throws {
        let fixture = makeFixture()
        defer { fixture.cleanup() }
        let firstBrief = try #require(fixture.store.latestBrief)

        #expect(firstBrief.version == 1)
        #expect(firstBrief.createdAt == fixedDate)
        #expect(!firstBrief.sourceContext.isEmpty)

        let secondBrief = fixture.store.saveBriefVersion()
        #expect(secondBrief.version == 2)

        let restoredStore = WorkspaceStore(
            defaults: fixture.defaults,
            clock: { fixedDate }
        )
        #expect(restoredStore.briefRecords.count == 2)
        #expect(restoredStore.latestBrief == secondBrief)
    }

    @Test
    func resetRestoresSampleRecordsWithoutErasingAuditHistory() throws {
        let fixture = makeFixture()
        defer { fixture.cleanup() }
        let item = try #require(fixture.store.readyItems.first)

        try fixture.store.recordDecision(
            workItemID: item.id,
            targetState: .held,
            rationale: "Waiting for review."
        )
        fixture.store.resetSampleData()

        #expect(fixture.store.items == WorkItem.samples)
        #expect(fixture.store.decisionEvents.count == 1)
        #expect(fixture.store.briefRecords.count == 1)
        #expect(fixture.store.approvalRecords.count == WorkItem.samples.count)
    }

    private func makeFixture() -> TestFixture {
        let suiteName = "SecondChairTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let store = WorkspaceStore(
            defaults: defaults,
            clock: { fixedDate }
        )
        return TestFixture(
            store: store,
            defaults: defaults,
            suiteName: suiteName
        )
    }
}

@MainActor
private struct TestFixture {
    let store: WorkspaceStore
    let defaults: UserDefaults
    let suiteName: String

    func cleanup() {
        defaults.removePersistentDomain(forName: suiteName)
    }
}
