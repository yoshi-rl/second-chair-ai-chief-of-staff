import SwiftUI

struct ApprovalDecisionSheet: View {
    let request: ApprovalDecisionRequest
    let item: WorkItem
    let approval: ApprovalRecord
    let store: WorkspaceStore

    @Environment(\.dismiss) private var dismiss
    @State private var rationale = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: request.targetState.systemImage)
                    .font(.title2)
                    .foregroundStyle(request.targetState.color)
                    .frame(width: 38, height: 38)
                    .background(request.targetState.color.opacity(0.10), in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(request.actionTitle)
                        .font(.title2.bold())
                    Text(item.title)
                        .foregroundStyle(Brand.secondary)
                }

                Spacer()
                StatusPill(status: item.status)
            }

            if approval.kind.isProtected {
                Label(
                    "\(approval.kind.title) requires an explicit human decision. Automation cannot approve it.",
                    systemImage: "person.badge.shield.checkmark"
                )
                .font(.callout.weight(.medium))
                .foregroundStyle(Brand.accent)
                .padding(12)
                .background(Brand.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Decision rationale")
                    .font(.headline)

                ZStack(alignment: .topLeading) {
                    if rationale.isEmpty {
                        Text("What informed this decision?")
                            .foregroundStyle(Brand.secondary.opacity(0.75))
                            .padding(.horizontal, 9)
                            .padding(.vertical, 10)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $rationale)
                        .scrollContentBackground(.hidden)
                        .padding(4)
                }
                .frame(minHeight: 110)
                .background(Brand.card, in: RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(errorMessage == nil ? Brand.border : request.targetState.color)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(request.targetState.color)
                } else {
                    Text("Stored locally with the actor, timestamp, action summary, and state transition.")
                        .font(.caption)
                        .foregroundStyle(Brand.secondary)
                }
            }

            HStack {
                Button("Cancel") {
                    store.cancelPendingDecision()
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Record \(request.actionTitle)") {
                    submit()
                }
                .buttonStyle(.borderedProminent)
                .tint(Brand.accent)
                .keyboardShortcut(.defaultAction)
                .disabled(rationale.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 520)
        .background(Brand.background)
    }

    private func submit() {
        do {
            try store.completeDecision(request, rationale: rationale)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
