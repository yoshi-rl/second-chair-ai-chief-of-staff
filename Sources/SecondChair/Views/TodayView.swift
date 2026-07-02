import SwiftUI

struct TodayView: View {
    let store: WorkspaceStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero

                HStack(spacing: 14) {
                    MetricCard(
                        label: "Time-back target",
                        value: "10–15h",
                        detail: "Validation target per week",
                        color: Brand.accent
                    )
                    MetricCard(
                        label: "Ready",
                        value: "\(store.readyItems.count)",
                        detail: "Drafts waiting for you",
                        color: Brand.primary
                    )
                    MetricCard(
                        label: "Live actions",
                        value: "0",
                        detail: "Nothing moves without approval",
                        color: Brand.success
                    )
                }

                SectionHeader(
                    "Today’s operating rhythm",
                    subtitle: "Prepared work stays in review until you decide."
                )

                VStack(spacing: 0) {
                    ForEach(Array(store.items.prefix(5).enumerated()), id: \.element.id) { index, item in
                        timelineRow(item)
                        if index < min(store.items.count, 5) - 1 {
                            Divider()
                                .padding(.leading, 70)
                        }
                    }
                }
                .executiveCard()
            }
            .padding(28)
            .frame(maxWidth: 1040)
            .frame(maxWidth: .infinity)
        }
        .background(Brand.background)
    }

    private var hero: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text(Date.now, format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Brand.secondary)
                    .textCase(.uppercase)
                    .tracking(1)

                Text("Get your week back.")
                    .font(.system(size: 38, weight: .bold, design: .rounded))

                Text("Second Chair has assembled the work that needs judgment today. Review the drafts, hold what is uncertain, and approve only what is ready.")
                    .font(.title3)
                    .foregroundStyle(Brand.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 680, alignment: .leading)
            }

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 8) {
                StatusPill(status: store.readyItems.isEmpty ? .approved : .ready)
                Text("Local workspace")
                    .font(.caption)
                    .foregroundStyle(Brand.secondary)
            }
        }
        .padding(24)
        .executiveCard(cornerRadius: 18)
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Brand.accent)
                .frame(width: 4)
                .padding(.vertical, 20)
        }
    }

    private func timelineRow(_ item: WorkItem) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(item.scheduledTime)
                .font(.callout.monospacedDigit())
                .foregroundStyle(Brand.secondary)
                .frame(width: 50, alignment: .leading)

            Image(systemName: item.workstream.systemImage)
                .foregroundStyle(item.status.color)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(item.summary)
                    .font(.callout)
                    .foregroundStyle(Brand.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 12)
            StatusPill(status: item.status)
        }
        .padding(16)
    }
}
