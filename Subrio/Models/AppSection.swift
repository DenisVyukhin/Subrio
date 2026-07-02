import Foundation

enum AppSection: String, CaseIterable, Identifiable {
    case overview
    case subscriptions
    case analytics
    case paymentMethods
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: "Overview"
        case .subscriptions: "Subscriptions"
        case .analytics: "Analytics"
        case .paymentMethods: "Payment Methods"
        case .settings: "Settings"
        }
    }

    var localizedTitle: String {
        L10n.tr(title)
    }

    var localizedNavigationTitle: String {
        switch self {
        case .overview: L10n.tr("Home")
        case .subscriptions: L10n.tr("Subs")
        case .analytics: L10n.tr("Stats")
        case .paymentMethods: L10n.tr("Cards")
        case .settings: L10n.tr("Settings")
        }
    }

    var icon: String {
        switch self {
        case .overview: "house.fill"
        case .subscriptions: "rectangle.stack.fill"
        case .analytics: "chart.line.uptrend.xyaxis"
        case .paymentMethods: "creditcard.fill"
        case .settings: "gearshape.fill"
        }
    }
}
