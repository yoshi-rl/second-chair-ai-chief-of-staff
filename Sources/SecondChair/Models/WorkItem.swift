import Foundation

enum Workstream: String, CaseIterable, Codable, Identifiable {
    case leadGeneration
    case sales
    case marketing
    case operations
    case finance
    case people

    var id: String { rawValue }

    var title: String {
        switch self {
        case .leadGeneration: "Lead Generation"
        case .sales: "Sales"
        case .marketing: "Marketing"
        case .operations: "Operations"
        case .finance: "Finance"
        case .people: "People"
        }
    }

    var systemImage: String {
        switch self {
        case .leadGeneration: "scope"
        case .sales: "chart.line.uptrend.xyaxis"
        case .marketing: "megaphone"
        case .operations: "gearshape.2"
        case .finance: "dollarsign.circle"
        case .people: "person.2"
        }
    }
}

enum WorkStatus: String, Codable {
    case draft
    case ready
    case approved
    case held
    case rejected

    var title: String {
        switch self {
        case .draft: "Drafting"
        case .ready: "Ready for review"
        case .approved: "Approved"
        case .held: "On hold"
        case .rejected: "Rejected"
        }
    }

    var systemImage: String {
        switch self {
        case .draft: "pencil.line"
        case .ready: "eye"
        case .approved: "checkmark.circle.fill"
        case .held: "pause.circle.fill"
        case .rejected: "xmark.circle.fill"
        }
    }
}

enum ImpactLevel: String, Codable {
    case low
    case medium
    case high

    var title: String { rawValue.capitalized }
}

struct WorkItem: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let summary: String
    let workstream: Workstream
    var status: WorkStatus
    let impact: ImpactLevel
    let scheduledTime: String
    let source: String
}

extension WorkItem {
    static let samples: [WorkItem] = [
        WorkItem(
            id: UUID(uuidString: "3D56D7CF-E3FD-4866-BB73-0785A4749B31")!,
            title: "Lead-gen research",
            summary: "Twelve target accounts were enriched and scored. Four match the pilot profile and are queued for your review.",
            workstream: .leadGeneration,
            status: .ready,
            impact: .medium,
            scheduledTime: "8:30",
            source: "Sandbox research"
        ),
        WorkItem(
            id: UUID(uuidString: "9A5C7954-A8DA-475E-9429-8D87CF811A60")!,
            title: "Sales follow-through",
            summary: "Proposal gaps and next steps are drafted for the three opportunities with activity this week.",
            workstream: .sales,
            status: .ready,
            impact: .high,
            scheduledTime: "9:30",
            source: "Sample CRM"
        ),
        WorkItem(
            id: UUID(uuidString: "F37D0F71-142E-41EC-9E0F-927A9B988206")!,
            title: "Marketing launch prep",
            summary: "Campaign themes, proof points, and a two-week draft sequence are ready. Nothing has been published.",
            workstream: .marketing,
            status: .ready,
            impact: .medium,
            scheduledTime: "11:15",
            source: "Meta + Google sandbox"
        ),
        WorkItem(
            id: UUID(uuidString: "4FEE2EA8-404E-40CB-B581-2AD68F671CAF")!,
            title: "Weekly operating recap",
            summary: "Owners, numbers, decisions, and blockers have been consolidated into the executive brief.",
            workstream: .operations,
            status: .ready,
            impact: .low,
            scheduledTime: "14:00",
            source: "Local sample data"
        ),
        WorkItem(
            id: UUID(uuidString: "F36CF35A-90C7-4E74-B411-09AA2CB7ED0A")!,
            title: "Invoice exception scan",
            summary: "Two invoices need an owner before the month-end review. A private draft is being prepared.",
            workstream: .finance,
            status: .draft,
            impact: .high,
            scheduledTime: "15:30",
            source: "Finance roadmap demo"
        ),
        WorkItem(
            id: UUID(uuidString: "69C9E832-4D07-40A5-A617-A094689E577E")!,
            title: "Hiring scorecard refresh",
            summary: "The interview loop and scorecard questions are aligned for the next candidate conversation.",
            workstream: .people,
            status: .held,
            impact: .medium,
            scheduledTime: "Tomorrow",
            source: "Local sample data"
        ),
    ]
}
