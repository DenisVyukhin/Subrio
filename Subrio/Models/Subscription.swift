import Foundation
import SwiftData

@Model
final class Subscription {
    @Attribute(.unique) var id: UUID
    var name: String
    var categoryRaw: String
    var price: Double
    var currency: String
    var billingPeriodRaw: String
    var nextPaymentDate: Date
    var paymentMethodID: UUID?
    var urlString: String
    var tintHex: String
    var note: String
    var statusRaw: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        category: SubscriptionCategory,
        price: Double,
        currency: String = "USD",
        billingPeriod: BillingPeriod,
        nextPaymentDate: Date,
        paymentMethodID: UUID?,
        urlString: String = "",
        tintHex: String,
        note: String = "",
        status: SubscriptionStatus = .active
    ) {
        self.id = id
        self.name = name
        self.categoryRaw = category.rawValue
        self.price = price
        self.currency = currency
        self.billingPeriodRaw = billingPeriod.rawValue
        self.nextPaymentDate = nextPaymentDate
        self.paymentMethodID = paymentMethodID
        self.urlString = urlString
        self.tintHex = tintHex
        self.note = note
        self.statusRaw = status.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var category: SubscriptionCategory {
        get { SubscriptionCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var billingPeriod: BillingPeriod {
        get { BillingPeriod(rawValue: billingPeriodRaw) ?? .monthly }
        set { billingPeriodRaw = newValue.rawValue }
    }

    var status: SubscriptionStatus {
        get { SubscriptionStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    var monthlyCost: Double {
        status == .active ? price * billingPeriod.monthsMultiplier : 0
    }

    var yearlyCost: Double {
        status == .active ? price * billingPeriod.yearlyMultiplier : 0
    }
}
