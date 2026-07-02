import SwiftUI

struct StatusPill: View {
    let status: WorkStatus

    var body: some View {
        Label(status.title, systemImage: status.systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(status.color)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(status.color.opacity(0.12), in: Capsule())
    }
}

struct MetricCard: View {
    let label: String
    let value: String
    let detail: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(Brand.secondary)
                .tracking(0.8)
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(detail)
                .font(.caption)
                .foregroundStyle(Brand.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .executiveCard(cornerRadius: 14)
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String?

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title2.bold())
            if let subtitle {
                Text(subtitle)
                    .foregroundStyle(Brand.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
