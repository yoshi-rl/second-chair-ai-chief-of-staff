import SwiftUI

enum Brand {
    static let background = Color(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 245.0 / 255.0)
    static let card = Color.white
    static let primary = Color(red: 17.0 / 255.0, green: 17.0 / 255.0, blue: 17.0 / 255.0)
    static let accent = Color(red: 31.0 / 255.0, green: 93.0 / 255.0, blue: 78.0 / 255.0)
    static let secondary = Color(red: 100.0 / 255.0, green: 116.0 / 255.0, blue: 139.0 / 255.0)
    static let success = Color(red: 5.0 / 255.0, green: 150.0 / 255.0, blue: 105.0 / 255.0)
    static let border = primary.opacity(0.08)
}

extension WorkStatus {
    var color: Color {
        switch self {
        case .draft: Brand.secondary
        case .ready: Brand.accent
        case .approved: Brand.success
        case .held: Brand.secondary
        }
    }
}

extension View {
    func executiveCard(cornerRadius: CGFloat = 16) -> some View {
        background(Brand.card, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Brand.border)
            }
            .shadow(color: Brand.primary.opacity(0.035), radius: 10, y: 4)
    }
}
