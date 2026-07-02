import SwiftUI

struct ApprovalQueueView: View {
    enum QueueFilter: String, CaseIterable, Identifiable {
        case review = "Needs Review"
        case held = "On Hold"
        case approved = "Approved"

        var id: String { rawValue }
    }

    let store: WorkspaceStore
    @State private var filter = QueueFilter.review

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(
                    "Approval queue",
                    subtitle: "Every consequential action remains a draft until you approve it."
                )

                Picker("Queue", selection: $filter) {
                    ForEach(QueueFilter.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 460)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            if filteredItems.isEmpty {
                ContentUnavailableView(
                    emptyTitle,
                    systemImage: "checkmark.seal",
                    description: Text(emptyDescription)
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(filteredItems) { item in
                            ApprovalCard(item: item, store: store)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: 900)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .background(Brand.background)
    }

    private var filteredItems: [WorkItem] {
        switch filter {
        case .review: store.readyItems
        case .held: store.heldItems
        case .approved: store.approvedItems
        }
    }

    private var emptyTitle: String {
        switch filter {
        case .review: "You’re caught up"
        case .held: "Nothing is on hold"
        case .approved: "No approvals yet"
        }
    }

    private var emptyDescription: String {
        switch filter {
        case .review: "New prepared work will appear here for review."
        case .held: "Items you pause will stay here until you return them to review."
        case .approved: "Approved drafts are recorded here in the local workspace."
        }
    }
}

private struct ApprovalCard: View {
    let item: WorkItem
    let store: WorkspaceStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Label(item.workstream.title, systemImage: item.workstream.systemImage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Brand.secondary)

                Spacer()
                StatusPill(status: item.status)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(item.title)
                    .font(.title3.bold())
                Text(item.summary)
                    .foregroundStyle(Brand.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack {
                Label("\(item.impact.title) impact", systemImage: "gauge.with.dots.needle.50percent")
                Text("•")
                Label(item.source, systemImage: "shippingbox")

                Spacer()

                if item.status == .ready {
                    Button("Hold") {
                        store.hold(item.id)
                    }

                    Button("Approve") {
                        store.approve(item.id)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Brand.accent)
                } else {
                    Button("Return to Review") {
                        store.returnToReview(item.id)
                    }
                }
            }
            .font(.caption)
        }
        .padding(18)
        .executiveCard()
        .contextMenu {
            if item.status == .ready {
                Button("Approve") { store.approve(item.id) }
                Button("Hold") { store.hold(item.id) }
            } else {
                Button("Return to Review") { store.returnToReview(item.id) }
            }
        }
    }
}
