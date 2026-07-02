import SwiftUI

struct AuditHistoryView: View {
    let store: WorkspaceStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SectionHeader(
                    "Audit history",
                    subtitle: "Append-only local evidence for every recorded human decision."
                )

                HStack(spacing: 14) {
                    MetricCard(
                        label: "Decision events",
                        value: "\(store.decisionEvents.count)",
                        detail: "Timestamped and retained",
                        color: Brand.accent
                    )
                    MetricCard(
                        label: "Brief versions",
                        value: "\(store.briefRecords.count)",
                        detail: "Source context preserved",
                        color: Brand.primary
                    )
                    MetricCard(
                        label: "Auto approvals",
                        value: "0",
                        detail: "Explicitly blocked",
                        color: Brand.success
                    )
                }

                if store.decisionEvents.isEmpty {
                    ContentUnavailableView(
                        "No decisions recorded",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Approve, hold, reject, or return an item to create the first audit event.")
                    )
                    .frame(maxWidth: .infinity, minHeight: 280)
                } else {
                    SectionHeader(
                        "Decision log",
                        subtitle: "Newest events appear first. Existing events cannot be edited from the app."
                    )

                    LazyVStack(spacing: 12) {
                        ForEach(Array(store.decisionEvents.reversed())) { event in
                            DecisionEventCard(event: event)
                        }
                    }
                }

                SectionHeader(
                    "Brief record versions",
                    subtitle: "Each version keeps its timestamp and source context."
                )

                LazyVStack(spacing: 10) {
                    ForEach(store.briefRecords.sorted(by: { $0.version > $1.version })) { brief in
                        BriefVersionRow(brief: brief)
                    }
                }
            }
            .padding(28)
            .frame(maxWidth: 980)
            .frame(maxWidth: .infinity)
        }
        .background(Brand.background)
    }
}

private struct DecisionEventCard: View {
    let event: ApprovalDecisionEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(event.actionSummary)
                        .font(.headline)
                    Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(Brand.secondary)
                }

                Spacer()

                Label(event.approvalKind.title, systemImage: event.approvalKind.systemImage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(event.approvalKind.isProtected ? Brand.accent : Brand.secondary)
            }

            HStack(spacing: 9) {
                StatusPill(status: event.priorState)
                Image(systemName: "arrow.right")
                    .foregroundStyle(Brand.secondary)
                StatusPill(status: event.nextState)
            }

            Text(event.rationale)
                .fixedSize(horizontal: false, vertical: true)

            Label(event.actor, systemImage: "person.crop.circle")
                .font(.caption)
                .foregroundStyle(Brand.secondary)
        }
        .padding(18)
        .executiveCard()
    }
}

private struct BriefVersionRow: View {
    let brief: BriefRecord

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text("v\(brief.version)")
                .font(.caption.bold().monospacedDigit())
                .foregroundStyle(Brand.accent)
                .frame(width: 36, height: 28)
                .background(Brand.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(brief.title)
                    .font(.headline)
                Text(brief.summary)
                    .foregroundStyle(Brand.secondary)
                Text("\(brief.createdAt.formatted(date: .abbreviated, time: .shortened)) • \(brief.sourceContext.count) sources")
                    .font(.caption)
                    .foregroundStyle(Brand.secondary)
            }

            Spacer()
        }
        .padding(16)
        .executiveCard(cornerRadius: 12)
    }
}
