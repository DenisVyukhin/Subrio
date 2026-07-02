import SwiftUI
import SwiftData

struct SubscriptionFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let subscription: Subscription?
    let paymentMethods: [PaymentMethod]

    @State private var name: String
    @State private var category: SubscriptionCategory
    @State private var price: String
    @State private var currency: String
    @State private var billingPeriod: BillingPeriod
    @State private var nextPaymentDate: Date
    @State private var paymentMethodID: UUID?
    @State private var urlString: String
    @State private var tintHex: String
    @State private var note: String
    @State private var status: SubscriptionStatus

    private let currencies = ["USD", "EUR", "GBP", "RUB"]

    init(subscription: Subscription?, paymentMethods: [PaymentMethod]) {
        self.subscription = subscription
        self.paymentMethods = paymentMethods
        _name = State(initialValue: subscription?.name ?? "")
        _category = State(initialValue: subscription?.category ?? .entertainment)
        _price = State(initialValue: subscription.map { String(format: "%.2f", $0.price) } ?? "")
        _currency = State(initialValue: subscription?.currency ?? "USD")
        _billingPeriod = State(initialValue: subscription?.billingPeriod ?? .monthly)
        _nextPaymentDate = State(initialValue: subscription?.nextPaymentDate ?? Date())
        _paymentMethodID = State(initialValue: subscription?.paymentMethodID ?? paymentMethods.first?.id)
        _urlString = State(initialValue: subscription?.urlString ?? "")
        _tintHex = State(initialValue: subscription?.tintHex ?? AppColors.subscriptionPalette[0])
        _note = State(initialValue: subscription?.note ?? "")
        _status = State(initialValue: subscription?.status ?? .active)
    }

    private var parsedPrice: Double {
        Double(price.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private var canSave: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && parsedPrice > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    formCard
                    saveButton
                }
                .padding(20)
            }
            .scrollEdgeEffectStyle(.soft, for: .top)
            .navigationTitle(L10n.tr(subscription == nil ? "Add Subscription" : "Edit Subscription"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L10n.tr("Cancel")) { dismiss() }
                }
            }
        }
    }

    private var formCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                labeledTextField("Name", text: $name, placeholder: "Service name")

                picker("Category", selection: $category, values: SubscriptionCategory.allCases)

                HStack(spacing: 12) {
                    labeledTextField("Price", text: $price, placeholder: "20.00", keyboard: .decimalPad)
                    picker("Currency", selection: $currency, values: currencies)
                }

                picker("Billing period", selection: $billingPeriod, values: BillingPeriod.allCases)
                DatePicker(L10n.tr("Next payment"), selection: $nextPaymentDate, displayedComponents: .date)

                picker("Payment method", selection: $paymentMethodID, values: paymentMethods)
                picker("Status", selection: $status, values: SubscriptionStatus.allCases)

                labeledTextField("URL", text: $urlString, placeholder: "https://example.com", keyboard: .URL, autocapitalization: .never)

                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n.tr("Color"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    PaletteSelector(colors: AppColors.subscriptionPalette, selectedHex: $tintHex)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n.tr("Note"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    TextEditor(text: $note)
                        .frame(minHeight: 86)
                        .scrollContentBackground(.hidden)
                        .padding(10)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    private var saveButton: some View {
        Button(action: save) {
                    Text(L10n.tr("Save"))
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(canSave ? AppColors.lime : .secondary.opacity(0.2), in: RoundedRectangle(cornerRadius: 18))
                .foregroundStyle(canSave ? .black : .secondary)
        }
        .disabled(canSave == false)
        .buttonStyle(.plain)
    }

    private func save() {
        if let subscription {
            subscription.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            subscription.category = category
            subscription.price = parsedPrice
            subscription.currency = currency
            subscription.billingPeriod = billingPeriod
            subscription.nextPaymentDate = nextPaymentDate
            subscription.paymentMethodID = paymentMethodID
            subscription.urlString = urlString
            subscription.tintHex = tintHex
            subscription.note = note
            subscription.status = status
            subscription.updatedAt = Date()
        } else {
            modelContext.insert(
                Subscription(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    category: category,
                    price: parsedPrice,
                    currency: currency,
                    billingPeriod: billingPeriod,
                    nextPaymentDate: nextPaymentDate,
                    paymentMethodID: paymentMethodID,
                    urlString: urlString,
                    tintHex: tintHex,
                    note: note,
                    status: status
                )
            )
        }

        try? modelContext.save()
        HapticService.notify(.success)
        dismiss()
    }

    private func labeledTextField(
        _ title: String,
        text: Binding<String>,
        placeholder: String,
        keyboard: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.tr(title))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            TextField(L10n.tr(placeholder), text: text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(autocapitalization)
                .textFieldStyle(.plain)
                .padding(13)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private func picker<T: Hashable & Identifiable & RawRepresentable>(_ title: String, selection: Binding<T>, values: [T]) -> some View where T.RawValue == String {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.tr(title))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Picker(L10n.tr(title), selection: selection) {
                ForEach(values) { value in
                    Text(L10n.tr(value.rawValue)).tag(value)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(13)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private func picker(_ title: String, selection: Binding<String>, values: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.tr(title))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Picker(L10n.tr(title), selection: selection) {
                ForEach(values, id: \.self) { value in
                    Text(L10n.tr(value)).tag(value)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(13)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private func picker(_ title: String, selection: Binding<UUID?>, values: [PaymentMethod]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.tr(title))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Picker(L10n.tr(title), selection: selection) {
                Text(L10n.tr("Not selected")).tag(Optional<UUID>.none)
                ForEach(values) { method in
                    Text("\(method.name) • \(method.lastFour)").tag(Optional(method.id))
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(13)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
        }
    }
}
