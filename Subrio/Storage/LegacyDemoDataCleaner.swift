import Foundation
import SwiftData

enum LegacyDemoDataCleaner {
    @MainActor
    static func removeIfNeeded(context: ModelContext) {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: "didSeedDemoData"),
              defaults.bool(forKey: "didRemoveLegacyDemoData") == false
        else { return }

        let demoSubscriptionNames: Set<String> = [
            "ChatGPT",
            "Netflix",
            "Spotify",
            "iCloud+",
            "YouTube Premium"
        ]
        let demoCardNames: Set<String> = [
            "Apple Card",
            "Travel Visa"
        ]

        do {
            let subscriptions = try context.fetch(FetchDescriptor<Subscription>())
            for subscription in subscriptions where demoSubscriptionNames.contains(subscription.name) {
                context.delete(subscription)
            }

            let paymentMethods = try context.fetch(FetchDescriptor<PaymentMethod>())
            for paymentMethod in paymentMethods where demoCardNames.contains(paymentMethod.name) {
                context.delete(paymentMethod)
            }

            try context.save()
            defaults.set(true, forKey: "didRemoveLegacyDemoData")
            defaults.removeObject(forKey: "didSeedDemoData")
        } catch {
            assertionFailure("Failed to remove legacy demo data: \(error)")
        }
    }
}
