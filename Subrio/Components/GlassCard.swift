import SwiftUI

struct GlassCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let padding: CGFloat
    let content: Content

    init(padding: CGFloat = 18, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(colorScheme == .dark ? AppColors.darkPanel.opacity(0.9) : AppColors.lightPanel.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(.white.opacity(colorScheme == .dark ? 0.08 : 0.5), lineWidth: 1)
                    )
                    .shadow(color: AppColors.lime.opacity(colorScheme == .dark ? 0.08 : 0.04), radius: 22, y: 10)
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.38 : 0.08), radius: 18, y: 12)
            )
    }
}

struct SectionTitle: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(L10n.tr(title))
                .font(.headline)
            Spacer()
            if let actionTitle, let action {
                Button(L10n.tr(actionTitle), action: action)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.lime)
            }
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(AppColors.violet, AppColors.lime)
                .symbolRenderingMode(.palette)
            Text(L10n.tr(title))
                .font(.headline)
            Text(L10n.tr(message))
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }
}

struct StatusBadge: View {
    let status: String

    var color: Color {
        switch status {
        case SubscriptionStatus.active.rawValue, PaymentStatus.active.rawValue: AppColors.lime
        case SubscriptionStatus.paused.rawValue: .orange
        default: .secondary
        }
    }

    var body: some View {
        Text(L10n.tr(status))
            .font(.caption.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.16), in: Capsule())
            .foregroundStyle(color)
    }
}

struct PaletteSelector: View {
    let colors: [String]
    @Binding var selectedHex: String

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6), spacing: 10) {
            ForEach(colors, id: \.self) { hex in
                Button {
                    selectedHex = hex
                    HapticService.impact(.light)
                } label: {
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 34, height: 34)
                        .overlay(
                            Circle()
                                .stroke(selectedHex == hex ? AppColors.lime : .white.opacity(0.18), lineWidth: selectedHex == hex ? 3 : 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
