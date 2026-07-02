import Foundation

enum SubscriptionCategory: String, CaseIterable, Identifiable {
    case entertainment = "Entertainment"
    case aiTools = "AI Tools"
    case music = "Music"
    case cloud = "Cloud"
    case education = "Education"
    case productivity = "Productivity"
    case finance = "Finance"
    case other = "Other"

    var id: String { rawValue }

    var localizedTitle: String { L10n.tr(rawValue) }

    var icon: String {
        switch self {
        case .entertainment: "play.tv.fill"
        case .aiTools: "sparkles"
        case .music: "music.note"
        case .cloud: "icloud.fill"
        case .education: "graduationcap.fill"
        case .productivity: "checkmark.seal.fill"
        case .finance: "banknote.fill"
        case .other: "square.grid.2x2.fill"
        }
    }
}

enum BillingPeriod: String, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case threeMonths = "3 Months"
    case sixMonths = "6 Months"
    case yearly = "Yearly"
    case custom = "Custom"

    var id: String { rawValue }

    var localizedTitle: String { L10n.tr(rawValue) }

    var monthsMultiplier: Double {
        switch self {
        case .weekly: 52.0 / 12.0
        case .monthly: 1
        case .threeMonths: 1.0 / 3.0
        case .sixMonths: 1.0 / 6.0
        case .yearly: 1.0 / 12.0
        case .custom: 1
        }
    }

    var yearlyMultiplier: Double {
        switch self {
        case .weekly: 52
        case .monthly: 12
        case .threeMonths: 4
        case .sixMonths: 2
        case .yearly: 1
        case .custom: 12
        }
    }

    var nextDateComponent: DateComponents {
        switch self {
        case .weekly: DateComponents(day: 7)
        case .monthly, .custom: DateComponents(month: 1)
        case .threeMonths: DateComponents(month: 3)
        case .sixMonths: DateComponents(month: 6)
        case .yearly: DateComponents(year: 1)
        }
    }
}

enum SubscriptionStatus: String, CaseIterable, Identifiable {
    case active = "Active"
    case inactive = "Inactive"
    case paused = "Paused"

    var id: String { rawValue }

    var localizedTitle: String { L10n.tr(rawValue) }
}

enum PaymentStatus: String, CaseIterable, Identifiable {
    case active = "Active"
    case inactive = "Inactive"

    var id: String { rawValue }

    var localizedTitle: String { L10n.tr(rawValue) }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "English"
    case russian = "Russian"

    var id: String { rawValue }

    var localizedTitle: String { L10n.tr(rawValue) }
}

enum AppThemePreference: String, CaseIterable, Identifiable {
    case dark = "Dark"
    case light = "Light"
    case system = "System"

    var id: String { rawValue }

    var localizedTitle: String { L10n.tr(rawValue) }
}
