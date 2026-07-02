import SwiftUI

struct ExecutiveBriefView: View {
    let store: WorkspaceStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .top) {
                    SectionHeader(
                        "Executive brief",
                        subtitle: "A compact view of decisions, exceptions, and the next operating moves."
                    )
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        if let brief = store.latestBrief {
                            Text("VERSION \(brief.version)")
                                .font(.caption2.bold())
                                .tracking(1)
                                .foregroundStyle(Brand.accent)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 5)
                                .background(Brand.accent.opacity(0.09), in: Capsule())
                            Text(brief.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(Brand.secondary)
                        }

                        Button("Save Version") {
                            store.saveBriefVersion()
                        }
                    }
                }

                if let brief = store.latestBrief {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(brief.summary)
                            .font(.headline)
                        Label(
                            brief.sourceContext.joined(separator: " • "),
                            systemImage: "shippingbox"
                        )
                        .font(.caption)
                        .foregroundStyle(Brand.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .executiveCard(cornerRadius: 12)
                }

                BriefSection(
                    title: "Decisions needed",
                    systemImage: "hand.raised",
                    color: Brand.accent,
                    items: decisionItems
                )

                BriefSection(
                    title: "Watchlist",
                    systemImage: "eye",
                    color: .secondary,
                    items: watchlistItems
                )

                BriefSection(
                    title: "Next moves",
                    systemImage: "arrow.right.circle",
                    color: Brand.accent,
                    items: [
                        "Review the four prepared drafts before any external action is considered.",
                        "Assign owners to the two invoice exceptions before month end.",
                        "Keep live connectors disabled until approval rules are configured.",
                    ]
                )

                Text("Second Chair is currently a local workflow prototype. It does not send messages, launch ads, update marketplaces, move money, or mutate live CRM data.")
                    .font(.caption)
                    .foregroundStyle(Brand.secondary)
                    .padding(.top, 4)
            }
            .padding(28)
            .frame(maxWidth: 880)
            .frame(maxWidth: .infinity)
        }
        .background(Brand.background)
    }

    private var decisionItems: [String] {
        let highImpact = store.readyItems.filter { $0.impact == .high }
        if highImpact.isEmpty {
            return ["No high-impact items are waiting for approval."]
        }
        return highImpact.map { "\($0.title): \($0.summary)" }
    }

    private var watchlistItems: [String] {
        let watched = store.items.filter { $0.status == .held || $0.status == .draft }
        if watched.isEmpty {
            return ["No held or in-progress items require attention."]
        }
        return watched.map { "\($0.title) — \($0.status.title.lowercased())." }
    }
}

private struct BriefSection: View {
    let title: String
    let systemImage: String
    let color: Color
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(color)

            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "arrow.turn.down.right")
                        .foregroundStyle(.tertiary)
                        .padding(.top, 2)
                    Text(item)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .executiveCard()
    }
}
