import SwiftUI

struct ContentView: View {
    let store: WorkspaceStore
    @SceneStorage("second-chair.selected-section") private var selectedSection = AppSection.today.rawValue

    private var selection: Binding<AppSection?> {
        Binding(
            get: { AppSection(rawValue: selectedSection) ?? .today },
            set: { selectedSection = ($0 ?? .today).rawValue }
        )
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: selection, readyCount: store.readyItems.count)
                .navigationSplitViewColumnWidth(min: 190, ideal: 220, max: 260)
        } detail: {
            detail
                .navigationTitle(currentSection.title)
                .background(Brand.background)
        }
        .navigationSplitViewStyle(.balanced)
        .tint(Brand.accent)
        .foregroundStyle(Brand.primary)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Approve Next Ready Item") {
                        store.approveNext()
                    }
                    .disabled(store.readyItems.isEmpty)

                    Divider()

                    Button("Restore Sample Workspace") {
                        store.resetSampleData()
                    }
                } label: {
                    Label("Workspace actions", systemImage: "ellipsis.circle")
                }
            }
        }
    }

    private var currentSection: AppSection {
        AppSection(rawValue: selectedSection) ?? .today
    }

    @ViewBuilder
    private var detail: some View {
        switch currentSection {
        case .today:
            TodayView(store: store)
        case .approvals:
            ApprovalQueueView(store: store)
        case .workstreams:
            WorkstreamsView(store: store)
        case .brief:
            ExecutiveBriefView(store: store)
        case .connectors:
            ConnectorsView()
        }
    }
}
