import SwiftUI
import SwiftData

struct SubscriptionsView: View {
    let subscriptions: [Subscription]
    let paymentMethods: [PaymentMethod]

    @State private var searchText = ""
    @State private var isShowingForm = false
    @State private var selectedSubscription: Subscription?

    private var filteredSubscriptions: [Subscription] {
        guard searchText.isEmpty == false else { return subscriptions }
        return subscriptions.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
            $0.status.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            StickyBlurHeader {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 6)
            } content: {
                VStack(alignment: .leading, spacing: 18) {
                    searchField

                    if filteredSubscriptions.isEmpty {
                        GlassCard {
                            EmptyStateView(
                                icon: searchText.isEmpty ? "rectangle.stack.badge.plus" : "magnifyingglass",
                                title: searchText.isEmpty ? "No subscriptions yet" : "Nothing found",
                                message: searchText.isEmpty ? "Add your first subscription and it will appear here." : "Try a different service name, category or status."
                            )
                        }
                    } else {
                        ForEach(filteredSubscriptions) { subscription in
                            Button {
                                selectedSubscription = subscription
                            } label: {
                                SubscriptionRowCard(subscription: subscription, paymentMethod: paymentMethods.first { $0.id == subscription.paymentMethodID })
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 118)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingForm) {
                SubscriptionFormView(subscription: nil, paymentMethods: paymentMethods)
            }
            .sheet(item: $selectedSubscription) { subscription in
                SubscriptionDetailView(subscription: subscription, paymentMethods: paymentMethods)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.tr("Subscriptions"))
                    .font(.largeTitle.weight(.bold))
                Text("\(subscriptions.count) \(L10n.tr("services tracked"))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                isShowingForm = true
                HapticService.impact(.medium)
            } label: {
                Image(systemName: "plus")
                    .font(.headline.weight(.bold))
                    .frame(width: 46, height: 46)
                    .background(AppColors.lime, in: Circle())
                    .foregroundStyle(.black)
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(L10n.tr("Search subscriptions"), text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if searchText.isEmpty == false {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
