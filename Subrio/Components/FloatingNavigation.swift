import SwiftUI

struct FloatingNavigation: View {
    @Binding var selectedSection: AppSection

    private let visibleSections: [AppSection] = [.overview, .subscriptions, .analytics, .paymentMethods]
    private let maxNavigationWidth: CGFloat = 352
    private let islandHeight: CGFloat = 62

    var body: some View {
        GeometryReader { outerProxy in
            let navigationWidth = min(maxNavigationWidth, outerProxy.size.width - 28)

            HStack {
                Spacer(minLength: 0)

                LiquidGlassNavigationControl(
                    items: navigationItems,
                    selectedSection: $selectedSection
                )
                .frame(width: navigationWidth, height: islandHeight)

                Spacer(minLength: 0)
            }
        }
        .frame(height: islandHeight)
        .onChange(of: selectedSection) { _, _ in
            HapticService.impact(.light)
        }
    }

    private var navigationItems: [LiquidGlassNavigationItem] {
        visibleSections.map {
            LiquidGlassNavigationItem(
                section: $0,
                title: $0.localizedNavigationTitle,
                systemImage: $0.icon,
                accessibilityTitle: $0.localizedTitle
            )
        } + [
            LiquidGlassNavigationItem(
                section: .settings,
                title: selectedSection == .settings ? AppSection.settings.localizedNavigationTitle : L10n.tr("More"),
                systemImage: selectedSection == .settings ? AppSection.settings.icon : "ellipsis",
                accessibilityTitle: AppSection.settings.localizedTitle
            )
        ]
    }
}
