import Foundation

struct CategorySpend: Identifiable {
    let id = UUID()
    let category: SubscriptionCategory
    let amount: Double
}

struct MonthlySpend: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
}

enum AnalyticsService {
    static func activeSubscriptions(_ subscriptions: [Subscription]) -> [Subscription] {
        subscriptions.filter { $0.status == .active }
    }

    static func monthlySpend(_ subscriptions: [Subscription]) -> Double {
        activeSubscriptions(subscriptions).reduce(0) { $0 + $1.monthlyCost }
    }

    static func yearlyForecast(_ subscriptions: [Subscription]) -> Double {
        activeSubscriptions(subscriptions).reduce(0) { $0 + $1.yearlyCost }
    }

    static func currentMonthSpend(_ subscriptions: [Subscription]) -> Double {
        let calendar = Calendar.current
        return activeSubscriptions(subscriptions)
            .filter { calendar.isDate($0.nextPaymentDate, equalTo: Date(), toGranularity: .month) }
            .reduce(0) { $0 + $1.price }
    }

    static func nextPayment(_ subscriptions: [Subscription]) -> Subscription? {
        activeSubscriptions(subscriptions)
            .filter { $0.nextPaymentDate >= Calendar.current.startOfDay(for: Date()) }
            .sorted { $0.nextPaymentDate < $1.nextPaymentDate }
            .first
    }

    static func categorySpend(_ subscriptions: [Subscription]) -> [CategorySpend] {
        let grouped = Dictionary(grouping: activeSubscriptions(subscriptions), by: \.category)
        return grouped.map { CategorySpend(category: $0.key, amount: $0.value.reduce(0) { $0 + $1.monthlyCost }) }
            .sorted { $0.amount > $1.amount }
    }

    static func monthlyProjection(_ subscriptions: [Subscription]) -> [MonthlySpend] {
        let calendar = Calendar.current
        let today = Date()
        let projectionStart = calendar.dateInterval(of: .month, for: today)?.start ?? calendar.startOfDay(for: today)
        guard let projectionEnd = calendar.date(byAdding: .month, value: 12, to: projectionStart) else {
            return []
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let language = AppLanguage(rawValue: UserDefaults.standard.string(forKey: "language") ?? AppLanguage.english.rawValue) ?? .english
        formatter.locale = Locale(identifier: language == .russian ? "ru_RU" : "en_US")

        var monthlyAmounts = Array(repeating: 0.0, count: 12)

        for subscription in activeSubscriptions(subscriptions) {
            var paymentDate = subscription.nextPaymentDate

            while paymentDate < projectionStart {
                guard let nextPaymentDate = calendar.date(byAdding: subscription.billingPeriod.nextDateComponent, to: paymentDate),
                      nextPaymentDate > paymentDate else {
                    break
                }
                paymentDate = nextPaymentDate
            }

            while paymentDate < projectionEnd {
                if let paymentMonthStart = calendar.dateInterval(of: .month, for: paymentDate)?.start,
                   let monthOffset = calendar.dateComponents([.month], from: projectionStart, to: paymentMonthStart).month,
                   monthlyAmounts.indices.contains(monthOffset) {
                    monthlyAmounts[monthOffset] += subscription.price
                }

                guard let nextPaymentDate = calendar.date(byAdding: subscription.billingPeriod.nextDateComponent, to: paymentDate),
                      nextPaymentDate > paymentDate else {
                    break
                }
                paymentDate = nextPaymentDate
            }
        }

        return (0..<12).compactMap { offset in
            guard let date = calendar.date(byAdding: .month, value: offset, to: projectionStart) else { return nil }
            return MonthlySpend(month: formatter.string(from: date), amount: monthlyAmounts[offset])
        }
    }

    static func statusCount(_ subscriptions: [Subscription], status: SubscriptionStatus) -> Int {
        subscriptions.filter { $0.status == status }.count
    }
}
