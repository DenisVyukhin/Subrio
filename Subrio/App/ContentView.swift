import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Subscription.nextPaymentDate) private var subscriptions: [Subscription]
    @Query(sort: \PaymentMethod.createdAt) private var paymentMethods: [PaymentMethod]

    @AppStorage("themePreference") private var themePreference = AppThemePreference.dark.rawValue
    @AppStorage("language") private var language = AppLanguage.english.rawValue
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("reminderDays") private var reminderDays = 3

    @State private var selectedSection: AppSection = .overview

    private var preferredScheme: ColorScheme? {
        switch AppThemePreference(rawValue: themePreference) ?? .dark {
        case .dark: .dark
        case .light: .light
        case .system: nil
        }
    }

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: language) ?? .english
    }

    private var appLocale: Locale {
        selectedLanguage == .russian ? Locale(identifier: "ru_RU") : Locale(identifier: "en_US")
    }

    private var notificationSignature: String {
        subscriptions
            .map { "\($0.id.uuidString)|\($0.statusRaw)|\($0.nextPaymentDate.timeIntervalSince1970)|\($0.price)" }
            .joined(separator: ";")
    }

    var body: some View {
        ZStack {
            RootBackground()

            pages
        }
        .id(language)
        .safeAreaInset(edge: .bottom) {
            FloatingNavigation(selectedSection: $selectedSection)
                .padding(.bottom, 8)
        }
        .preferredColorScheme(preferredScheme)
        .environment(\.locale, appLocale)
        .task {
            LegacyDemoDataCleaner.removeIfNeeded(context: modelContext)
            NotificationService.shared.reschedule(subscriptions: subscriptions, enabled: notificationsEnabled, reminderDays: reminderDays)
        }
        .onChange(of: notificationsEnabled) { _, newValue in
            NotificationService.shared.reschedule(subscriptions: subscriptions, enabled: newValue, reminderDays: reminderDays)
        }
        .onChange(of: reminderDays) { _, newValue in
            NotificationService.shared.reschedule(subscriptions: subscriptions, enabled: notificationsEnabled, reminderDays: newValue)
        }
        .onChange(of: notificationSignature) { _, _ in
            NotificationService.shared.reschedule(subscriptions: subscriptions, enabled: notificationsEnabled, reminderDays: reminderDays)
        }
        .onChange(of: language) { _, _ in
            NotificationService.shared.reschedule(subscriptions: subscriptions, enabled: notificationsEnabled, reminderDays: reminderDays)
        }
    }

    @ViewBuilder
    private var pages: some View {
        ZStack {
            page(.overview) {
                OverviewView(subscriptions: subscriptions, paymentMethods: paymentMethods) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedSection = .subscriptions
                    }
                }
            }
            page(.subscriptions) {
                SubscriptionsView(subscriptions: subscriptions, paymentMethods: paymentMethods)
            }
            page(.analytics) {
                AnalyticsView(subscriptions: subscriptions)
            }
            page(.paymentMethods) {
                PaymentMethodsView(paymentMethods: paymentMethods)
            }
            page(.settings) {
                SettingsView()
            }
        }
    }

    private func page<Content: View>(_ section: AppSection, @ViewBuilder content: () -> Content) -> some View {
        content()
            .opacity(selectedSection == section ? 1 : 0)
            .allowsHitTesting(selectedSection == section)
            .accessibilityHidden(selectedSection != section)
            .animation(.easeInOut(duration: 0.2), value: selectedSection)
    }

}

private struct RootBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            (colorScheme == .dark ? AppColors.darkBackground : AppColors.lightBackground)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    AppColors.lime.opacity(colorScheme == .dark ? 0.14 : 0.08),
                    .clear,
                    AppColors.violet.opacity(colorScheme == .dark ? 0.16 : 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Subscription.self, PaymentMethod.self], inMemory: true)
}
