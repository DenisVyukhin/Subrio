import SwiftUI
import SwiftData

struct PaymentMethodFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let method: PaymentMethod?

    @State private var name: String
    @State private var lastFour: String
    @State private var tintHex: String
    @State private var status: PaymentStatus
    @State private var isConfirmingDelete = false

    init(method: PaymentMethod?) {
        self.method = method
        _name = State(initialValue: method?.name ?? "")
        _lastFour = State(initialValue: method?.lastFour ?? "")
        _tintHex = State(initialValue: method?.tintHex ?? AppColors.cardPalette[0])
        _status = State(initialValue: method?.status ?? .active)
    }

    private var canSave: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && lastFour.count == 4
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    PaymentMethodPreviewCard(name: name.isEmpty ? L10n.tr("Card name") : name, lastFour: lastFour.count == 4 ? lastFour : "0000", tintHex: tintHex, status: status)
                        .allowsHitTesting(false)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 18) {
                            labeledTextField("Name", text: $name, placeholder: "Card name")
                            labeledTextField("Last 4 digits", text: $lastFour, placeholder: "4242", keyboard: .numberPad)
                                .onChange(of: lastFour) { _, value in
                                    lastFour = String(value.filter(\.isNumber).prefix(4))
                                }
                            picker("Status", selection: $status, values: PaymentStatus.allCases)

                            VStack(alignment: .leading, spacing: 10) {
                                Text(L10n.tr("Color"))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                PaletteSelector(colors: AppColors.cardPalette, selectedHex: $tintHex)
                            }
                        }
                    }

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

                    if method != nil {
                        Button(role: .destructive) {
                            isConfirmingDelete = true
                        } label: {
                            Label(L10n.tr("Delete card"), systemImage: "trash.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .scrollEdgeEffectStyle(.soft, for: .top)
            .navigationTitle(L10n.tr(method == nil ? "Add Card" : "Edit Card"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L10n.tr("Cancel")) { dismiss() }
                }
            }
            .confirmationDialog(L10n.tr("Delete card?"), isPresented: $isConfirmingDelete, titleVisibility: .visible) {
                Button(L10n.tr("Delete"), role: .destructive) {
                    if let method {
                        modelContext.delete(method)
                        try? modelContext.save()
                    }
                    dismiss()
                }
                Button(L10n.tr("Cancel"), role: .cancel) {}
            }
        }
    }

    private func save() {
        if let method {
            method.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            method.lastFour = lastFour
            method.tintHex = tintHex
            method.status = status
        } else {
            modelContext.insert(PaymentMethod(name: name.trimmingCharacters(in: .whitespacesAndNewlines), lastFour: lastFour, tintHex: tintHex, status: status))
        }
        try? modelContext.save()
        HapticService.notify(.success)
        dismiss()
    }

    private func labeledTextField(_ title: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.tr(title))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            TextField(L10n.tr(placeholder), text: text)
                .keyboardType(keyboard)
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
            .pickerStyle(.segmented)
        }
    }
}

private struct PaymentMethodPreviewCard: View {
    let name: String
    let lastFour: String
    let tintHex: String
    let status: PaymentStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .font(.title3)
                Spacer()
                StatusBadge(status: status.rawValue)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(name)
                    .font(.headline)
                Text("•••• \(lastFour)")
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
                        colors: [Color(hex: tintHex), Color(hex: tintHex).opacity(0.62), AppColors.violet.opacity(0.38)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(hex: tintHex).opacity(0.25), radius: 18, y: 10)
        )
    }
}
