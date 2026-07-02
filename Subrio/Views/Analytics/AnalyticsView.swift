import SwiftUI

struct AnalyticsView: View {
    let subscriptions: [Subscription]

    private var monthlySpend: Double { AnalyticsService.monthlySpend(subscriptions) }
    private var yearlyForecast: Double { AnalyticsService.yearlyForecast(subscriptions) }
    private var categorySpend: [CategorySpend] { AnalyticsService.categorySpend(subscriptions) }
    private var projection: [MonthlySpend] { AnalyticsService.monthlyProjection(subscriptions) }
    private var maxProjection: Double { projection.map(\.amount).max() ?? 0 }

    var body: some View {
        NavigationStack {
            StickyBlurHeader {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 6)
            } content: {
                VStack(alignment: .leading, spacing: 18) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        MetricCard(title: "Active total", value: CurrencyFormatter.money(monthlySpend), icon: "sum", accent: AppColors.lime, subtitle: "per month")
                        MetricCard(title: "Forecast", value: CurrencyFormatter.money(yearlyForecast), icon: "chart.xyaxis.line", accent: AppColors.violet, subtitle: "next 12 months")
                    }

                    projectionCard
                    categoriesCard
                    expensiveCard
                    statusCard
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
            Text(L10n.tr("Analytics"))
                .font(.largeTitle.weight(.bold))
            Text(L10n.tr("A clean view of recurring spend."))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var projectionCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionTitle(title: "Monthly Projection")
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(projection) { month in
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(LinearGradient(colors: [AppColors.lime, AppColors.violet], startPoint: .top, endPoint: .bottom))
                                .frame(height: projectionBarHeight(for: month.amount))
                            Text(month.month)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .rotationEffect(.degrees(-35))
                                .frame(height: 24)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 176, alignment: .bottom)
            }
        }
    }

    private var categoriesCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionTitle(title: "Categories")
                if categorySpend.isEmpty {
                    EmptyStateView(icon: "chart.pie.fill", title: "No active spend", message: "Active subscriptions will form category distribution.")
                } else {
                    ForEach(categorySpend) { item in
                        progressRow(
                            title: item.category.rawValue,
                            icon: item.category.icon,
                            value: item.amount,
                            maxValue: categorySpend.first?.amount ?? item.amount,
                            color: color(for: item.category)
                        )
                    }
                }
            }
        }
    }

    private var expensiveCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionTitle(title: "Most Expensive")
                let top = AnalyticsService.activeSubscriptions(subscriptions).sorted { $0.monthlyCost > $1.monthlyCost }.prefix(4)
                if top.isEmpty {
                    EmptyStateView(icon: "creditcard.trianglebadge.exclamationmark", title: "No active subscriptions", message: "Turn on a subscription to see spend leaders.")
                } else {
                    ForEach(Array(top)) { subscription in
                        HStack {
                            Label(subscription.name, systemImage: subscription.category.icon)
                            Spacer()
                            Text(CurrencyFormatter.money(subscription.monthlyCost, currency: subscription.currency))
                                .fontWeight(.bold)
                        }
                        .font(.subheadline)
                    }
                }
            }
        }
    }

    private var statusCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionTitle(title: "Status")
                HStack(spacing: 12) {
                    statusPill(.active, color: AppColors.lime)
                    statusPill(.paused, color: .orange)
                    statusPill(.inactive, color: .secondary)
                }
            }
        }
    }

    private func progressRow(title: String, icon: String, value: Double, maxValue: Double, color: Color) -> some View {
        VStack(spacing: 8) {
            HStack {
                Label(L10n.tr(title), systemImage: icon)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(CurrencyFormatter.money(value))
                    .font(.subheadline.weight(.bold))
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.08))
                    Capsule().fill(color).frame(width: proxy.size.width * CGFloat(maxValue == 0 ? 0 : value / maxValue))
                }
            }
            .frame(height: 8)
        }
    }

    private func projectionBarHeight(for amount: Double) -> CGFloat {
        guard amount > 0, maxProjection > 0 else { return 1 }
        return max(1, CGFloat(amount / maxProjection) * 132)
    }

    private func statusPill(_ status: SubscriptionStatus, color: Color) -> some View {
        VStack(spacing: 8) {
            Text("\(AnalyticsService.statusCount(subscriptions, status: status))")
                .font(.title2.weight(.bold))
            Text(status.localizedTitle)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.13), in: RoundedRectangle(cornerRadius: 18))
    }

    private func color(for category: SubscriptionCategory) -> Color {
        switch category {
        case .entertainment: .pink
        case .aiTools: AppColors.violet
        case .music: .green
        case .cloud: .cyan
        case .education: .blue
        case .productivity: AppColors.lime
        case .finance: .orange
        case .other: .secondary
        }
    }
}
