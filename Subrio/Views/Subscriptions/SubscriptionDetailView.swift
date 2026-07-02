import SwiftUI
import SwiftData

struct SubscriptionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let subscription: Subscription
    let paymentMethods: [PaymentMethod]

    @State private var isShowingEdit = false
    @State private var isConfirmingDelete = false

    private var paymentMethod: PaymentMethod? {
        paymentMethods.first { $0.id == subscription.paymentMethodID }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    GlassCard(padding: 22) {
                        VStack(alignment: .leading, spacing: 18) {
                            HStack(alignment: .top) {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(Color(hex: subscription.tintHex))
                                    .frame(width: 76, height: 76)
                                    .overlay(Image(systemName: subscription.category.icon).font(.title).foregroundStyle(.white))
                                Spacer()
                                StatusBadge(status: subscription.statusRaw)
                            }

                            Text(subscription.name)
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                            Text(CurrencyFormatter.money(subscription.price, currency: subscription.currency))
                                .font(.title.weight(.bold))
                                .foregroundStyle(AppColors.lime)
                        }
                    }

                    detailRows
                    actions
                }
                .padding(20)
            }
            .scrollEdgeEffectStyle(.soft, for: .top)
            .navigationTitle(L10n.tr("Details"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.tr("Edit")) { isShowingEdit = true }
                }
            }
            .sheet(isPresented: $isShowingEdit) {
                SubscriptionFormView(subscription: subscription, paymentMethods: paymentMethods)
            }
            .confirmationDialog(L10n.tr("Delete subscription?"), isPresented: $isConfirmingDelete, titleVisibility: .visible) {
                Button(L10n.tr("Delete"), role: .destructive) {
                    modelContext.delete(subscription)
                    try? modelContext.save()
                    HapticService.notify(.success)
                    dismiss()
                }
                Button(L10n.tr("Cancel"), role: .cancel) {}
            }
        }
    }

    private var detailRows: some View {
        GlassCard {
            VStack(spacing: 14) {
                detailRow("Category", subscription.category.localizedTitle, "folder.fill")
                detailRow("Billing period", subscription.billingPeriod.localizedTitle, "calendar.badge.clock")
                detailRow("Next payment", subscription.nextPaymentDate.shortDisplay, "bell.fill")
                detailRow("Payment method", paymentMethod?.name ?? L10n.tr("Not selected"), "creditcard.fill")
                if subscription.urlString.isEmpty == false {
                    detailRow("URL", subscription.urlString, "link")
                }
                if subscription.note.isEmpty == false {
                    detailRow("Note", subscription.note, "note.text")
                }
            }
        }
    }

    private func detailRow(_ title: String, _ value: String, _ icon: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.violet)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.tr(title))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .textSelection(.enabled)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                subscription.status = subscription.status == .active ? .paused : .active
                subscription.updatedAt = Date()
                try? modelContext.save()
                HapticService.impact(.medium)
            } label: {
                Label(L10n.tr(subscription.status == .active ? "Pause subscription" : "Make active"), systemImage: "pause.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
            }

            Button(role: .destructive) {
                isConfirmingDelete = true
            } label: {
                Label(L10n.tr("Delete subscription"), systemImage: "trash.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
            }
        }
        .font(.headline)
        .buttonStyle(.plain)
    }
}
