import Foundation
import Observation

@MainActor
@Observable
final class WorkspaceStore {
    var items: [WorkItem] {
        didSet { persist(items, key: Self.itemStorageKey) }
    }

    var briefRecords: [BriefRecord] {
        didSet { persist(briefRecords, key: Self.briefStorageKey) }
    }

    var approvalRecords: [ApprovalRecord] {
        didSet { persist(approvalRecords, key: Self.approvalStorageKey) }
    }

    var decisionEvents: [ApprovalDecisionEvent] {
        didSet { persist(decisionEvents, key: Self.decisionStorageKey) }
    }

    var pendingDecision: ApprovalDecisionRequest?

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let clock: () -> Date

    private static let itemStorageKey = "second-chair.workspace-items.v1"
    private static let briefStorageKey = "second-chair.brief-records.v1"
    private static let approvalStorageKey = "second-chair.approval-records.v1"
    private static let decisionStorageKey = "second-chair.decision-events.v1"

    init(
        defaults: UserDefaults = .standard,
        clock: @escaping () -> Date = Date.init
    ) {
        self.defaults = defaults
        self.clock = clock

        let loadedItems = Self.decode(
            [WorkItem].self,
            defaults: defaults,
            key: Self.itemStorageKey
        ) ?? WorkItem.samples
        let timestamp = clock()

        items = loadedItems
        approvalRecords = Self.decode(
            [ApprovalRecord].self,
            defaults: defaults,
            key: Self.approvalStorageKey
        ) ?? Self.makeApprovalRecords(from: loadedItems, timestamp: timestamp)
        briefRecords = Self.decode(
            [BriefRecord].self,
            defaults: defaults,
            key: Self.briefStorageKey
        ) ?? [Self.makeBriefRecord(from: loadedItems, version: 1, timestamp: timestamp)]
        decisionEvents = Self.decode(
            [ApprovalDecisionEvent].self,
            defaults: defaults,
            key: Self.decisionStorageKey
        ) ?? []

        synchronizeItemsFromApprovalRecords()
    }

    var readyItems: [WorkItem] {
        items.filter { $0.status == .ready }
    }

    var heldItems: [WorkItem] {
        items.filter { $0.status == .held }
    }

    var approvedItems: [WorkItem] {
        items.filter { $0.status == .approved }
    }

    var rejectedItems: [WorkItem] {
        items.filter { $0.status == .rejected }
    }

    var pendingApprovalRecords: [ApprovalRecord] {
        approvalRecords.filter { ![.approved, .rejected].contains($0.state) }
    }

    var latestBrief: BriefRecord? {
        briefRecords.max { $0.version < $1.version }
    }

    func approvalRecord(for workItemID: WorkItem.ID) -> ApprovalRecord? {
        approvalRecords.first { $0.workItemID == workItemID }
    }

    func requestDecision(_ workItemID: WorkItem.ID, targetState: WorkStatus) {
        guard approvalRecord(for: workItemID) != nil else { return }
        pendingDecision = ApprovalDecisionRequest(
            workItemID: workItemID,
            targetState: targetState
        )
    }

    func requestNextApprovalDecision() {
        guard let next = readyItems.first else { return }
        requestDecision(next.id, targetState: .approved)
    }

    func cancelPendingDecision() {
        pendingDecision = nil
    }

    @discardableResult
    func completeDecision(
        _ request: ApprovalDecisionRequest,
        rationale: String,
        actor: String = "Human operator"
    ) throws -> ApprovalDecisionEvent {
        let event = try recordDecision(
            workItemID: request.workItemID,
            targetState: request.targetState,
            rationale: rationale,
            actor: actor,
            origin: .human
        )
        pendingDecision = nil
        return event
    }

    @discardableResult
    func recordDecision(
        workItemID: WorkItem.ID,
        targetState: WorkStatus,
        rationale: String,
        actor: String = "Human operator",
        origin: DecisionOrigin = .human
    ) throws -> ApprovalDecisionEvent {
        guard let approvalIndex = approvalRecords.firstIndex(where: {
            $0.workItemID == workItemID
        }) else {
            throw WorkspaceDecisionError.approvalNotFound
        }

        let approval = approvalRecords[approvalIndex]
        if origin == .automation,
           approval.requiresExplicitHumanApproval || approval.kind.isProtected {
            throw WorkspaceDecisionError.automationBlocked
        }

        let cleanedRationale = rationale.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedRationale.isEmpty else {
            throw WorkspaceDecisionError.rationaleRequired
        }

        let allowedTargets: Set<WorkStatus> = [.ready, .approved, .held, .rejected]
        guard allowedTargets.contains(targetState), approval.state != targetState else {
            throw WorkspaceDecisionError.invalidTransition
        }

        let timestamp = clock()
        let event = ApprovalDecisionEvent(
            id: UUID(),
            approvalID: approval.id,
            workItemID: workItemID,
            timestamp: timestamp,
            actor: actor,
            actionSummary: approval.actionSummary,
            priorState: approval.state,
            nextState: targetState,
            rationale: cleanedRationale,
            origin: origin,
            approvalKind: approval.kind
        )

        approvalRecords[approvalIndex].state = targetState
        approvalRecords[approvalIndex].updatedAt = timestamp

        if let itemIndex = items.firstIndex(where: { $0.id == workItemID }) {
            items[itemIndex].status = targetState
        }

        decisionEvents.append(event)
        return event
    }

    func attemptAutomatedApproval(_ workItemID: WorkItem.ID) -> Bool {
        do {
            try recordDecision(
                workItemID: workItemID,
                targetState: .approved,
                rationale: "Automated approval attempt",
                actor: "Automation",
                origin: .automation
            )
            return true
        } catch {
            return false
        }
    }

    @discardableResult
    func saveBriefVersion() -> BriefRecord {
        let nextVersion = (briefRecords.map(\.version).max() ?? 0) + 1
        let record = Self.makeBriefRecord(
            from: items,
            version: nextVersion,
            timestamp: clock()
        )
        briefRecords.append(record)
        return record
    }

    func resetSampleData() {
        let timestamp = clock()
        items = WorkItem.samples
        approvalRecords = Self.makeApprovalRecords(
            from: WorkItem.samples,
            timestamp: timestamp
        )
        briefRecords = [
            Self.makeBriefRecord(
                from: WorkItem.samples,
                version: 1,
                timestamp: timestamp
            ),
        ]
        pendingDecision = nil
    }

    private func synchronizeItemsFromApprovalRecords() {
        var synchronizedItems = items
        for index in synchronizedItems.indices {
            guard let record = approvalRecord(for: synchronizedItems[index].id) else {
                continue
            }
            synchronizedItems[index].status = record.state
        }
        items = synchronizedItems
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        guard let encoded = try? JSONEncoder().encode(value) else { return }
        defaults.set(encoded, forKey: key)
    }

    private static func decode<T: Decodable>(
        _ type: T.Type,
        defaults: UserDefaults,
        key: String
    ) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private static func makeApprovalRecords(
        from items: [WorkItem],
        timestamp: Date
    ) -> [ApprovalRecord] {
        items.map { item in
            ApprovalRecord(
                id: item.id,
                workItemID: item.id,
                actionSummary: item.title,
                workstream: item.workstream,
                sourceContext: item.source,
                kind: approvalKind(for: item.id),
                createdAt: timestamp,
                updatedAt: timestamp,
                state: item.status,
                requiresExplicitHumanApproval: true
            )
        }
    }

    private static func makeBriefRecord(
        from items: [WorkItem],
        version: Int,
        timestamp: Date
    ) -> BriefRecord {
        let readyCount = items.filter { $0.status == .ready }.count
        let exceptionCount = items.filter {
            [.draft, .held, .rejected].contains($0.status)
        }.count

        return BriefRecord(
            id: UUID(),
            version: version,
            title: "Second Chair operating brief",
            summary: "\(readyCount) items need review; \(exceptionCount) exceptions remain visible.",
            createdAt: timestamp,
            sourceContext: Array(Set(items.map(\.source))).sorted(),
            workItemIDs: items.map(\.id)
        )
    }

    private static func approvalKind(for workItemID: WorkItem.ID) -> ApprovalKind {
        switch workItemID.uuidString {
        case "3D56D7CF-E3FD-4866-BB73-0785A4749B31":
            .manusWaiting
        case "F37D0F71-142E-41EC-9E0F-927A9B988206",
             "F36CF35A-90C7-4E74-B411-09AA2CB7ED0A":
            .connectorAction
        default:
            .standard
        }
    }
}
