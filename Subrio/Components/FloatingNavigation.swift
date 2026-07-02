import SwiftUI

struct FloatingNavigation: View {
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var selectionNamespace

    @Binding var selectedSection: AppSection

    private let visibleSections: [AppSection] = [.overview, .subscriptions, .analytics, .paymentMethods]
    private let itemSpacing: CGFloat = 2
    private let contentPadding: CGFloat = 6
    private let maxNavigationWidth: CGFloat = 352

    var body: some View {
        GeometryReader { outerProxy in
            let navigationWidth = min(maxNavigationWidth, outerProxy.size.width - 28)
            let itemWidth = itemWidth(containerWidth: navigationWidth)

            HStack {
                Spacer(minLength: 0)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(colorScheme == .dark ? AppColors.darkPanel.opacity(0.96) : Color.white.opacity(0.86))
                        .frame(width: navigationWidth, height: 62)

                    HStack(spacing: itemSpacing) {
                        ForEach(visibleSections) { section in
                            Button {
                                select(section)
                            } label: {
                                itemLabel(
                                    icon: section.icon,
                                    title: section.localizedNavigationTitle,
                                    isSelected: selectedSection == section,
                                    width: itemWidth
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(section.localizedTitle)
                        }

                        Menu {
                            Button {
                                select(.settings)
                            } label: {
                                Label(AppSection.settings.localizedTitle, systemImage: AppSection.settings.icon)
                            }
                        } label: {
                            itemLabel(
                                icon: selectedSection == .settings ? AppSection.settings.icon : "ellipsis",
                                title: selectedSection == .settings ? AppSection.settings.localizedNavigationTitle : L10n.tr("More"),
                                isSelected: selectedSection == .settings,
                                width: itemWidth
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(L10n.tr("More"))
                    }
                    .padding(contentPadding)
                    .animation(.snappy(duration: 0.24, extraBounce: 0.035), value: selectedSection)
                }
                .frame(width: navigationWidth, height: 62)
                .glassEffect(
                    .regular
                        .tint((colorScheme == .dark ? Color.black : Color.white).opacity(colorScheme == .dark ? 0.34 : 0.48))
                        .interactive(),
                    in: Capsule()
                )
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(colorScheme == .dark ? 0.10 : 0.58), lineWidth: 1)
                )
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.26 : 0.14), radius: 18, y: 8)

                Spacer(minLength: 0)
            }
        }
        .frame(height: 62)
        .onChange(of: selectedSection) { _, _ in
            HapticService.impact(.light)
        }
    }

    private func itemLabel(icon: String, title: String, isSelected: Bool, width: CGFloat) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 15.5, weight: .semibold))
                .frame(height: 17)
            Text(title)
                .font(.system(size: 8.8, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .allowsTightening(true)
        }
        .frame(width: width, height: 50)
        .foregroundStyle(isSelected ? AppColors.lime : .secondary)
        .background {
            if isSelected {
                selectedCapsule()
                    .matchedGeometryEffect(id: "navigationSelection", in: selectionNamespace)
            }
        }
        .contentShape(Capsule())
    }

    private func selectedCapsule() -> some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .overlay(
                Capsule()
                    .stroke(.white.opacity(colorScheme == .dark ? 0.18 : 0.68), lineWidth: 1)
            )
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.10 : 0.06), radius: 14, y: 5)
    }

    private func itemWidth(containerWidth: CGFloat) -> CGFloat {
        let itemCount = CGFloat(visibleSections.count + 1)
        let totalSpacing = itemSpacing * CGFloat(max(0, Int(itemCount) - 1))
        let availableWidth = containerWidth - contentPadding * 2 - totalSpacing
        return max(54, availableWidth / itemCount)
    }

    private func select(_ section: AppSection) {
        guard selectedSection != section else { return }
        selectedSection = section
    }
}
