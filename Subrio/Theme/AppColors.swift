import SwiftUI

enum AppColors {
    static let lime = Color(hex: "#7FFF00")
    static let violet = Color(hex: "#8B00FF")
    static let darkBackground = Color(hex: "#050607")
    static let darkPanel = Color(hex: "#111318")
    static let darkPanelElevated = Color(hex: "#181B22")
    static let lightBackground = Color(hex: "#F5F7F2")
    static let lightPanel = Color.white

    static let subscriptionPalette = [
        "#7FA8A6", "#9B8AC3", "#C28F8F", "#8FAE7F",
        "#7F91B8", "#B9A26F", "#A8839F", "#6FA39B"
    ]

    static let cardPalette = [
        "#2E5E64", "#513B78", "#70533A", "#466B55",
        "#334E7A", "#6F5F35", "#6B3D5F", "#3E6267"
    ]
}

extension Color {
    init(hex: String) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        sanitized = sanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255
        let green = Double((rgb >> 8) & 0xFF) / 255
        let blue = Double(rgb & 0xFF) / 255

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}
