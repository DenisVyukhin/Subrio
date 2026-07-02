import SwiftUI
import UIKit
import CoreImage.CIFilterBuiltins
import QuartzCore

// Adapted from ProgressiveBlurHeader by Dominik Martin (MIT)
// and VariableBlur by Nikita Starshinov / contributors (MIT).

enum VariableBlurDirection: Equatable {
    case blurredTopClearBottom
    case blurredBottomClearTop
}

struct VariableBlurView: UIViewRepresentable {
    var maxBlurRadius: CGFloat
    var direction: VariableBlurDirection
    var startOffset: CGFloat

    init(
        maxBlurRadius: CGFloat = 20,
        direction: VariableBlurDirection = .blurredTopClearBottom,
        startOffset: CGFloat = 0
    ) {
        self.maxBlurRadius = maxBlurRadius
        self.direction = direction
        self.startOffset = startOffset
    }

    func makeUIView(context: Context) -> VariableBlurUIView {
        VariableBlurUIView(maxBlurRadius: maxBlurRadius, direction: direction, startOffset: startOffset)
    }

    func updateUIView(_ uiView: VariableBlurUIView, context: Context) {
        uiView.configure(maxBlurRadius: maxBlurRadius, direction: direction, startOffset: startOffset)
    }
}

final class VariableBlurUIView: UIVisualEffectView {
    private var currentRadius: CGFloat = 0
    private var currentDirection: VariableBlurDirection = .blurredTopClearBottom
    private var currentStartOffset: CGFloat = 0

    init(maxBlurRadius: CGFloat, direction: VariableBlurDirection, startOffset: CGFloat) {
        super.init(effect: UIBlurEffect(style: .regular))
        configure(maxBlurRadius: maxBlurRadius, direction: direction, startOffset: startOffset)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(maxBlurRadius: CGFloat, direction: VariableBlurDirection, startOffset: CGFloat) {
        guard maxBlurRadius != currentRadius || direction != currentDirection || startOffset != currentStartOffset else {
            return
        }

        currentRadius = maxBlurRadius
        currentDirection = direction
        currentStartOffset = startOffset

        let className = String("retliFAC".reversed())
        guard let filterClass = NSClassFromString(className) as? NSObject.Type else {
            return
        }

        let selectorName = String(":epyThtiWretlif".reversed())
        guard let filter = filterClass
            .perform(NSSelectorFromString(selectorName), with: "variableBlur")
            .takeUnretainedValue() as? NSObject else {
            return
        }

        filter.setValue(maxBlurRadius, forKey: "inputRadius")
        filter.setValue(makeGradientImage(startOffset: startOffset, direction: direction), forKey: "inputMaskImage")
        filter.setValue(true, forKey: "inputNormalizeEdges")

        subviews.first?.layer.filters = [filter]

        for subview in subviews.dropFirst() {
            subview.alpha = 0
        }
    }

    override func didMoveToWindow() {
        guard let window, let backdropLayer = subviews.first?.layer else { return }
        backdropLayer.setValue(window.traitCollection.displayScale, forKey: "scale")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Calling super can re-enable default UIVisualEffectView tint subviews.
    }

    private func makeGradientImage(
        width: CGFloat = 100,
        height: CGFloat = 100,
        startOffset: CGFloat,
        direction: VariableBlurDirection
    ) -> CGImage {
        let filter = CIFilter.linearGradient()
        filter.color0 = CIColor.black
        filter.color1 = CIColor.clear
        filter.point0 = CGPoint(x: 0, y: height)
        filter.point1 = CGPoint(x: 0, y: startOffset * height)

        if case .blurredBottomClearTop = direction {
            filter.point0.y = 0
            filter.point1.y = height - filter.point1.y
        }

        return CIContext().createCGImage(
            filter.outputImage!,
            from: CGRect(x: 0, y: 0, width: width, height: height)
        )!
    }
}

private struct HeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct StickyBlurHeader<Header: View, Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    private let maxBlurRadius: CGFloat
    private let fadeExtension: CGFloat
    private let contentTopSpacing: CGFloat
    private let tintOpacityTop: Double
    private let tintOpacityMiddle: Double
    private let header: () -> Header
    private let content: () -> Content

    @State private var headerHeight: CGFloat = 76

    init(
        maxBlurRadius: CGFloat = 5,
        fadeExtension: CGFloat = 28,
        contentTopSpacing: CGFloat = 24,
        tintOpacityTop: Double = 0.7,
        tintOpacityMiddle: Double = 0.5,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.maxBlurRadius = maxBlurRadius
        self.fadeExtension = fadeExtension
        self.contentTopSpacing = contentTopSpacing
        self.tintOpacityTop = tintOpacityTop
        self.tintOpacityMiddle = tintOpacityMiddle
        self.header = header
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            let totalHeight = proxy.safeAreaInsets.top + headerHeight + fadeExtension

            ZStack(alignment: .top) {
                ScrollView {
                    content()
                }
                .scrollIndicators(.hidden)
                .scrollEdgeEffectStyle(.soft, for: .top)
                .safeAreaInset(edge: .top, spacing: 0) {
                    Color.clear.frame(height: headerHeight + contentTopSpacing)
                }

                VariableBlurView(
                    maxBlurRadius: maxBlurRadius,
                    direction: .blurredTopClearBottom
                )
                .overlay {
                    LinearGradient(
                        stops: [
                            .init(color: fadeTint.opacity(tintOpacityTop), location: 0),
                            .init(color: fadeTint.opacity(tintOpacityMiddle), location: min(0.82, 90 / totalHeight)),
                            .init(color: fadeTint.opacity(0), location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .frame(height: totalHeight)
                .ignoresSafeArea(edges: .top)
                .allowsHitTesting(false)

                header()
                    .overlay {
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: HeaderHeightKey.self,
                                value: geo.size.height
                            )
                        }
                    }
            }
            .onPreferenceChange(HeaderHeightKey.self) { headerHeight = $0 }
        }
    }

    private var fadeTint: Color {
        colorScheme == .dark ? .black : .white
    }
}
