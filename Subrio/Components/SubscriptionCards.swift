import SwiftUI

struct SubscriptionRowCard: View {
    let subscription: Subscription
    let paymentMethod: PaymentMethod?

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(hex: subscription.tintHex))
                .frame(width: 54, height: 54)
                .overlay(
                    Image(systemName: subscription.category.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text(subscription.name)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Text(CurrencyFormatter.money(subscription.price, currency: subscription.currency))
                        .font(.headline.weight(.bold))
                }

                HStack(spacing: 8) {
                    Text(subscription.category.localizedTitle)
                    Text("•")
                    Text(subscription.billingPeriod.localizedTitle)
                    Text("•")
                    Text(subscription.nextPaymentDate.shortDisplay)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

                HStack {
                    StatusBadge(status: subscription.statusRaw)
                    if let paymentMethod {
                        Label(paymentMethod.name, systemImage: "creditcard.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.thinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(hex: subscription.tintHex).opacity(0.28), lineWidth: 1))
        )
    }
}

struct PaymentMethodCard: View {
    let method: PaymentMethod

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .font(.title3)
                Spacer()
                StatusBadge(status: method.statusRaw)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(method.name)
                    .font(.headline)
                Text("•••• \(method.lastFour)")
                    .font(.title2.weight(.bold))
                    .monospacedDigit()
            }
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: method.tintHex), Color(hex: method.tintHex).opacity(0.62), AppColors.violet.opacity(0.38)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(hex: method.tintHex).opacity(0.25), radius: 18, y: 10)
        )
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let accent: Color
    var subtitle: String?

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 38, height: 38)
                        .background(accent.opacity(0.16), in: Circle())
                        .foregroundStyle(accent)
                    Spacer()
                }
                Text(L10n.tr(title))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 36, alignment: .topLeading)
                Text(value)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                if let subtitle {
                    Text(L10n.tr(subtitle))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
