import SwiftUI
import SwiftData

struct PaymentMethodsView: View {
    let paymentMethods: [PaymentMethod]

    @State private var isShowingForm = false
    @State private var editingMethod: PaymentMethod?

    var body: some View {
        NavigationStack {
            StickyBlurHeader {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 6)
            } content: {
                VStack(alignment: .leading, spacing: 18) {
                    if paymentMethods.isEmpty {
                        GlassCard {
                            EmptyStateView(icon: "creditcard.fill", title: "No cards yet", message: "Create local virtual payment methods for organizing subscriptions.")
                        }
                    } else {
                        ForEach(paymentMethods) { method in
                            Button {
                                editingMethod = method
                            } label: {
                                PaymentMethodCard(method: method)
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
                PaymentMethodFormView(method: nil)
            }
            .sheet(item: $editingMethod) { method in
                PaymentMethodFormView(method: method)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.tr("Payment Methods"))
                    .font(.largeTitle.weight(.bold))
                Text(L10n.tr("Local cards for smarter tracking."))
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
}
