import SwiftUI

struct OverviewView: View {
    let subscriptions: [Subscription]
    let paymentMethods: [PaymentMethod]
    let showSubscriptions: () -> Void

    private var monthlySpend: Double { AnalyticsService.monthlySpend(subscriptions) }
    private var currentMonthSpend: Double { AnalyticsService.currentMonthSpend(subscriptions) }
    private var yearlyForecast: Double { AnalyticsService.yearlyForecast(subscriptions) }
    private var nextPayment: Subscription? { AnalyticsService.nextPayment(subscriptions) }
    private var activeCount: Int { AnalyticsService.activeSubscriptions(subscriptions).count }

    var body: some View {
        NavigationStack {
            StickyBlurHeader {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 6)
            } content: {
                VStack(alignment: .leading, spacing: 20) {
                    heroCard

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        MetricCard(title: "Average monthly", value: CurrencyFormatter.money(monthlySpend), icon: "calendar", accent: AppColors.violet)
                        MetricCard(title: "Year forecast", value: CurrencyFormatter.money(yearlyForecast), icon: "chart.line.uptrend.xyaxis", accent: AppColors.lime)
                        MetricCard(title: "Active subscriptions", value: "\(activeCount)", icon: "rectangle.stack.fill", accent: .cyan)
                        MetricCard(title: "Payment methods", value: "\(paymentMethods.count)", icon: "creditcard.fill", accent: .orange)
                    }

                    upcomingPayment
                    recentSubscriptions
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 118)
            }
            .navigationBarHidden(true)
        }
    }

    private var header: some View {
        Text("Subrio")
            .font(.system(size: 34, weight: .bold, design: .rounded))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var heroCard: some View {
        GlassCard(padding: 22) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Label(L10n.tr("Current month"), systemImage: "bolt.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.lime)
                    Spacer()
                    Text(Date().monthYearDisplay)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Text(CurrencyFormatter.money(currentMonthSpend))
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .monospacedDigit()

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.tr("Monthly baseline"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(CurrencyFormatter.money(monthlySpend))
                            .font(.headline)
                    }
                    Spacer()
                    Button(action: showSubscriptions) {
                        Label(L10n.tr("Manage"), systemImage: "slider.horizontal.3")
                            .font(.subheadline.weight(.bold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(AppColors.lime, in: Capsule())
                            .foregroundStyle(.black)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var upcomingPayment: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Next Payment")
            if let nextPayment {
                GlassCard {
                    HStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(hex: nextPayment.tintHex))
                            .frame(width: 62, height: 62)
                            .overlay(Image(systemName: nextPayment.category.icon).font(.title2).foregroundStyle(.white))
                        VStack(alignment: .leading, spacing: 6) {
                            Text(nextPayment.name)
                                .font(.headline)
                            Text("\(nextPayment.nextPaymentDate.shortDisplay) • \(max(0, nextPayment.nextPaymentDate.daysUntil())) \(L10n.tr("days"))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(CurrencyFormatter.money(nextPayment.price, currency: nextPayment.currency))
                            .font(.title3.weight(.bold))
                    }
                }
            } else {
                GlassCard {
                    EmptyStateView(icon: "checkmark.seal.fill", title: "No upcoming payments", message: "Active subscriptions with future payment dates will appear here.")
                }
            }
        }
    }

    private var recentSubscriptions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Subscriptions", actionTitle: "View all", action: showSubscriptions)
            if subscriptions.isEmpty {
                GlassCard {
                    EmptyStateView(icon: "plus.circle.fill", title: "Start with your first subscription", message: "Add a service, choose a payment method and Subrio will calculate your spend.")
                }
            } else {
                ForEach(Array(subscriptions.prefix(3))) { subscription in
                    SubscriptionRowCard(subscription: subscription, paymentMethod: paymentMethods.first { $0.id == subscription.paymentMethodID })
                }
            }
        }
    }
}
