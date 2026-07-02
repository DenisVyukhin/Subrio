import SwiftUI

struct SettingsView: View {
    @AppStorage("language") private var language = AppLanguage.english.rawValue
    @AppStorage("themePreference") private var themePreference = AppThemePreference.dark.rawValue
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("reminderDays") private var reminderDays = 3

    var body: some View {
        NavigationStack {
            StickyBlurHeader {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 6)
            } content: {
                VStack(alignment: .leading, spacing: 18) {
                    preferencesCard
                    notificationCard
                    authCard
                    aboutCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 118)
            }
            .navigationBarHidden(true)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.tr("Settings"))
                .font(.largeTitle.weight(.bold))
            Text(L10n.tr("Personalize the local experience."))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var preferencesCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                SectionTitle(title: "Interface")
                Picker(L10n.tr("Language"), selection: $language) {
                    ForEach(AppLanguage.allCases) { item in
                        Text(item.localizedTitle).tag(item.rawValue)
                    }
                }
                .pickerStyle(.menu)

                Picker(L10n.tr("Theme"), selection: $themePreference) {
                    ForEach(AppThemePreference.allCases) { item in
                        Text(item.localizedTitle).tag(item.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var notificationCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                SectionTitle(title: "Notifications")
                Toggle(L10n.tr("Local reminders"), isOn: $notificationsEnabled)
                    .tint(AppColors.lime)

                Picker(L10n.tr("Remind before"), selection: $reminderDays) {
                    Text(L10n.tr("1 day")).tag(1)
                    Text(L10n.tr("3 days")).tag(3)
                    Text(L10n.tr("7 days")).tag(7)
                }
                .pickerStyle(.segmented)
                .disabled(notificationsEnabled == false)
            }
        }
    }

    private var authCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "Account")
                authRow("Continue with Apple", icon: "apple.logo")
                authRow("Continue with Google", icon: "g.circle.fill")
            }
        }
    }

    private var aboutCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(title: "About")
                Text("Subrio")
                    .font(.headline)
                Text(L10n.tr("Portfolio-ready subscription tracker. All data is stored locally on device."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(L10n.tr("Version 1.0"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func authRow(_ title: String, icon: String) -> some View {
        Button {
            HapticService.impact(.light)
        } label: {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                Text(L10n.tr(title))
                    .font(.headline)
                Spacer()
                Text(L10n.tr("Local"))
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppColors.violet.opacity(0.16), in: Capsule())
                    .foregroundStyle(AppColors.violet)
            }
            .padding(14)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
