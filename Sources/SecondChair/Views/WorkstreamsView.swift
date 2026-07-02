import SwiftUI

struct WorkstreamsView: View {
    let store: WorkspaceStore
    private let columns = [GridItem(.adaptive(minimum: 260), spacing: 16)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SectionHeader(
                    "Workstreams",
                    subtitle: "The coordination layer across the business, grouped by responsibility."
                )

                LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                    ForEach(Workstream.allCases) { workstream in
                        WorkstreamCard(
                            workstream: workstream,
                            items: store.items.filter { $0.workstream == workstream }
                        )
                    }
                }
            }
            .padding(28)
            .frame(maxWidth: 1040)
            .frame(maxWidth: .infinity)
        }
        .background(Brand.background)
    }
}

private struct WorkstreamCard: View {
    let workstream: Workstream
    let items: [WorkItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: workstream.systemImage)
                    .font(.title2)
                    .foregroundStyle(Brand.accent)
                    .frame(width: 34, height: 34)
                    .background(Brand.accent.opacity(0.09), in: RoundedRectangle(cornerRadius: 9))

                VStack(alignment: .leading, spacing: 2) {
                    Text(workstream.title)
                        .font(.headline)
                    Text("\(items.count) active item\(items.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(Brand.secondary)
                }

                Spacer()
            }

            if items.isEmpty {
                Text("No prepared work yet.")
                    .font(.callout)
                    .foregroundStyle(Brand.secondary)
            } else {
                ForEach(items) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(item.status.color)
                            .frame(width: 7, height: 7)
                            .padding(.top, 6)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.callout.weight(.medium))
                                .lineLimit(1)
                            Text(item.status.title)
                                .font(.caption)
                                .foregroundStyle(Brand.secondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 155, alignment: .topLeading)
        .padding(18)
        .executiveCard()
    }
}
