import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestAuthorizationIfNeeded() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    func reschedule(subscriptions: [Subscription], enabled: Bool, reminderDays: Int) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        guard enabled else { return }
        requestAuthorizationIfNeeded()

        for subscription in subscriptions where subscription.status == .active {
            let reminderDate = Calendar.current.date(byAdding: .day, value: -reminderDays, to: subscription.nextPaymentDate) ?? subscription.nextPaymentDate
            guard reminderDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = "\(subscription.name): \(L10n.tr("Next payment"))"
            content.body = "\(CurrencyFormatter.money(subscription.price, currency: subscription.currency)) • \(subscription.nextPaymentDate.shortDisplay)"
            content.sound = .default

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: subscription.id.uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
}
