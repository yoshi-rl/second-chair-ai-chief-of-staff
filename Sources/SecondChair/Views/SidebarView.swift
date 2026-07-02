import SwiftUI

struct SidebarView: View {
    @Binding var selection: AppSection?
    let readyCount: Int

    var body: some View {
        List {
            Section("Workspace") {
                ForEach(AppSection.allCases) { section in
                    Button {
                        selection = section
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: section.systemImage)
                                .foregroundStyle(selection == section ? Brand.accent : Brand.secondary)
                                .frame(width: 16)

                            Text(section.title)
                                .fontWeight(selection == section ? .semibold : .regular)
                                .foregroundStyle(Brand.primary)
                                .lineLimit(1)

                            Spacer()

                            if section == .approvals, readyCount > 0 {
                                Text("\(readyCount)")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 2)
                                    .background(Brand.accent, in: Capsule())
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .listRowBackground(
                        selection == section
                            ? Brand.accent.opacity(0.10)
                            : Color.clear
                    )
                    .accessibilityAddTraits(selection == section ? .isSelected : [])
                }
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 5) {
                Label("Human-guided mode", systemImage: "person.badge.shield.checkmark")
                    .font(.caption.weight(.medium))
                Text("No live actions are enabled.")
                    .font(.caption2)
                    .foregroundStyle(Brand.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}
