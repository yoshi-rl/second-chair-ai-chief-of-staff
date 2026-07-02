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
                        store.requestNextApprovalDecision()
                    }
                    .disabled(store.readyItems.isEmpty)

                    Button("Save Brief Version") {
                        store.saveBriefVersion()
                    }

                    Divider()

                    Button("Restore Sample Workspace") {
                        store.resetSampleData()
                    }
                } label: {
                    Label("Workspace actions", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(item: pendingDecision) { request in
            if let item = store.items.first(where: { $0.id == request.workItemID }),
               let approval = store.approvalRecord(for: request.workItemID) {
                ApprovalDecisionSheet(
                    request: request,
                    item: item,
                    approval: approval,
                    store: store
                )
            }
        }
    }

    private var pendingDecision: Binding<ApprovalDecisionRequest?> {
        Binding(
            get: { store.pendingDecision },
            set: { value in
                if value == nil {
                    store.cancelPendingDecision()
                }
            }
        )
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
        case .history:
            AuditHistoryView(store: store)
        case .connectors:
            ConnectorsView()
        }
    }
}
