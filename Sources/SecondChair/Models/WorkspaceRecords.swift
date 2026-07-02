import Foundation

enum ApprovalKind: String, Codable, CaseIterable {
    case standard
    case manusWaiting
    case connectorAction

    var title: String {
        switch self {
        case .standard: "Prepared work"
        case .manusWaiting: "Manus waiting"
        case .connectorAction: "Connector action"
        }
    }

    var systemImage: String {
        switch self {
        case .standard: "doc.badge.ellipsis"
        case .manusWaiting: "hourglass"
        case .connectorAction: "link.badge.plus"
        }
    }

    var isProtected: Bool {
        self != .standard
    }
}

struct BriefRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let version: Int
    let title: String
    let summary: String
    let createdAt: Date
    let sourceContext: [String]
    let workItemIDs: [WorkItem.ID]
}

struct ApprovalRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let workItemID: WorkItem.ID
    let actionSummary: String
    let workstream: Workstream
    let sourceContext: String
    let kind: ApprovalKind
    let createdAt: Date
    var updatedAt: Date
    var state: WorkStatus
    let requiresExplicitHumanApproval: Bool
}

enum DecisionOrigin: String, Codable {
    case human
    case automation
}

struct ApprovalDecisionEvent: Identifiable, Codable, Hashable {
    let id: UUID
    let approvalID: ApprovalRecord.ID
    let workItemID: WorkItem.ID
    let timestamp: Date
    let actor: String
    let actionSummary: String
    let priorState: WorkStatus
    let nextState: WorkStatus
    let rationale: String
    let origin: DecisionOrigin
    let approvalKind: ApprovalKind
}

struct ApprovalDecisionRequest: Identifiable, Hashable {
    let id = UUID()
    let workItemID: WorkItem.ID
    let targetState: WorkStatus

    var actionTitle: String {
        switch targetState {
        case .approved: "Approve"
        case .held: "Place on Hold"
        case .ready: "Return to Review"
        case .rejected: "Reject"
        case .draft: "Return to Draft"
        }
    }
}

enum WorkspaceDecisionError: Error, Equatable, LocalizedError {
    case approvalNotFound
    case rationaleRequired
    case invalidTransition
    case automationBlocked

    var errorDescription: String? {
        switch self {
        case .approvalNotFound: "The approval record could not be found."
        case .rationaleRequired: "Add a short rationale before recording this decision."
        case .invalidTransition: "That approval-state transition is not available."
        case .automationBlocked: "This action requires an explicit human decision and cannot be auto-approved."
        }
    }
}
