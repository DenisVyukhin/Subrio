import SwiftUI
import UIKit

struct LiquidGlassNavigationItem: Hashable {
    let section: AppSection
    let title: String
    let systemImage: String
    let accessibilityTitle: String
}

struct LiquidGlassNavigationControl: UIViewRepresentable {
    let items: [LiquidGlassNavigationItem]

    @Binding var selectedSection: AppSection

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> LiquidGlassNavigationView {
        let control = LiquidGlassSegmentedControl(items: placeholderImages)
        control.showsLargeContentViewer = false
        control.selectedSegmentIndex = selectedIndex
        control.selectedSegmentTintColor = segmentTintColor(for: control.traitCollection)
        control.activeTintColor = UIColor(red: 0.5, green: 1, blue: 0, alpha: 1)
        control.inactiveTintColor = .secondaryLabel
        control.addTarget(context.coordinator, action: #selector(Coordinator.sectionSelected(_:)), for: .valueChanged)
        control.onReselect = { _ in }

        configureSegments(on: control)

        return LiquidGlassNavigationView(segmentedControl: control)
    }

    func updateUIView(_ uiView: LiquidGlassNavigationView, context: Context) {
        context.coordinator.parent = self

        let control = uiView.segmentedControl
        control.selectedSegmentTintColor = segmentTintColor(for: uiView.traitCollection)

        if items != context.coordinator.previousItems {
            context.coordinator.previousItems = items
            rebuildSegments(on: control)
        }

        if control.selectedSegmentIndex != selectedIndex {
            control.selectedSegmentIndex = selectedIndex
        }
    }

    private var selectedIndex: Int {
        items.firstIndex { $0.section == selectedSection } ?? 0
    }

    private var placeholderImages: [UIImage] {
        items.map { _ in UIImage(systemName: "circle") ?? UIImage() }
    }

    private func rebuildSegments(on control: LiquidGlassSegmentedControl) {
        control.removeAllSegments()
        for index in items.indices {
            control.insertSegment(with: placeholderImages[index], at: control.numberOfSegments, animated: false)
        }
        configureSegments(on: control)
    }

    private func configureSegments(on control: LiquidGlassSegmentedControl) {
        for (index, item) in items.enumerated() {
            control.setTitle(item.accessibilityTitle, forSegmentAt: index)
        }

        let baseViews = items.map { LiquidGlassNavigationItemView(title: $0.title, symbolName: $0.systemImage) }
        let accentViews = items.map { LiquidGlassNavigationItemView(title: $0.title, symbolName: $0.systemImage) }
        control.configureContentViews(baseViews, accentViews: accentViews)

        for index in items.indices {
            control.setWidth(0, forSegmentAt: index)
        }
    }

    private func segmentTintColor(for traitCollection: UITraitCollection) -> UIColor {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            .label.withAlphaComponent(0.15)
        default:
            .label.withAlphaComponent(0.08)
        }
    }

    @MainActor
    final class Coordinator: NSObject {
        var parent: LiquidGlassNavigationControl
        var previousItems: [LiquidGlassNavigationItem]

        init(parent: LiquidGlassNavigationControl) {
            self.parent = parent
            self.previousItems = parent.items
        }

        @objc func sectionSelected(_ control: UISegmentedControl) {
            let index = control.selectedSegmentIndex
            guard parent.items.indices.contains(index) else { return }
            parent.selectedSection = parent.items[index].section
        }
    }
}

final class LiquidGlassNavigationView: UIView {
    let containerEffectView: UIVisualEffectView
    let segmentedGlassView: UIVisualEffectView
    let segmentedControl: LiquidGlassSegmentedControl

    private let contentPadding: CGFloat = 2

    init(segmentedControl: LiquidGlassSegmentedControl) {
        self.segmentedControl = segmentedControl

        let containerEffect = UIGlassContainerEffect()
        containerEffect.spacing = 0
        containerEffectView = UIVisualEffectView(effect: containerEffect)

        let segmentedGlassEffect = UIGlassEffect()
        segmentedGlassEffect.isInteractive = true
        segmentedGlassView = UIVisualEffectView(effect: segmentedGlassEffect)

        super.init(frame: .zero)

        isOpaque = false
        backgroundColor = .clear
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        segmentedGlassView.cornerConfiguration = .capsule()
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        let effect = UIGlassEffect()
        effect.isInteractive = true
        segmentedGlassView.effect = effect
    }

    private func setupViews() {
        addSubview(containerEffectView)
        containerEffectView.translatesAutoresizingMaskIntoConstraints = false
        containerEffectView.contentView.addSubview(segmentedGlassView)
        segmentedGlassView.translatesAutoresizingMaskIntoConstraints = false
        segmentedGlassView.contentView.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerEffectView.topAnchor.constraint(equalTo: topAnchor),
            containerEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),

            segmentedGlassView.leadingAnchor.constraint(equalTo: containerEffectView.contentView.leadingAnchor),
            segmentedGlassView.trailingAnchor.constraint(equalTo: containerEffectView.contentView.trailingAnchor),
            segmentedGlassView.topAnchor.constraint(equalTo: containerEffectView.contentView.topAnchor),
            segmentedGlassView.bottomAnchor.constraint(equalTo: containerEffectView.contentView.bottomAnchor),

            segmentedControl.leadingAnchor.constraint(equalTo: segmentedGlassView.contentView.leadingAnchor, constant: contentPadding),
            segmentedControl.trailingAnchor.constraint(equalTo: segmentedGlassView.contentView.trailingAnchor, constant: -contentPadding),
            segmentedControl.topAnchor.constraint(equalTo: segmentedGlassView.contentView.topAnchor, constant: contentPadding),
            segmentedControl.bottomAnchor.constraint(equalTo: segmentedGlassView.contentView.bottomAnchor, constant: -contentPadding - 1)
        ])
    }
}

/// Adapted from ryanashcraft/FabBar's TabBarSegmentedControl.
final class LiquidGlassSegmentedControl: UISegmentedControl {
    private var originalIndex: Int?

    private static let injectedViewTag = 7_777
    private static let accentViewTag = 7_778
    private static let stableFrameThreshold = 3

    private var contentViews: [LiquidGlassNavigationItemView] = []
    private var accentContentViews: [LiquidGlassNavigationItemView] = []

    private var displayLink: CADisplayLink?
    private var displayLinkProxy: LiquidGlassDisplayLinkProxy?
    private var lastIndicatorRect: CGRect = .zero
    private var stableFrameCount: Int = 0
    private var didUseIndicatorFallback = false
    private weak var cachedIndicatorView: UIView?

    var activeTintColor: UIColor = .tintColor {
        didSet { updateContentViewColors() }
    }

    var inactiveTintColor: UIColor = .label {
        didSet { updateContentViewColors() }
    }

    var onReselect: ((Int) -> Void)?

    override init(items: [Any]?) {
        super.init(items: items)
        accessibilityTraits = .tabBar
        isOpaque = false
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        displayLink?.isPaused = false
        stableFrameCount = 0
        hideSegmentBackgrounds()
        hideDefaultLabels()
        injectContentViewsIfNeeded()
        updateContentViewColors()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            stopDisplayLink()
        } else {
            startDisplayLink()
        }
    }

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        hideLabelsRecursively(in: subview)
    }

    func configureContentViews(_ baseViews: [LiquidGlassNavigationItemView], accentViews: [LiquidGlassNavigationItemView]) {
        cachedIndicatorView = nil

        for segmentView in findSegmentViews() {
            segmentView.viewWithTag(Self.injectedViewTag)?.removeFromSuperview()
            segmentView.viewWithTag(Self.accentViewTag)?.removeFromSuperview()
        }

        contentViews = baseViews
        accentContentViews = accentViews
        setNeedsLayout()
    }

    private func injectContentViewsIfNeeded() {
        let segmentViews = findSegmentViews()
        guard segmentViews.count == contentViews.count,
              segmentViews.count == accentContentViews.count else { return }

        for (index, segmentView) in segmentViews.enumerated() {
            if segmentView.viewWithTag(Self.injectedViewTag) == nil {
                let contentView = contentViews[index]
                contentView.tag = Self.injectedViewTag
                contentView.translatesAutoresizingMaskIntoConstraints = false
                segmentView.addSubview(contentView)

                NSLayoutConstraint.activate([
                    contentView.centerXAnchor.constraint(equalTo: segmentView.centerXAnchor),
                    contentView.centerYAnchor.constraint(equalTo: segmentView.centerYAnchor),
                    contentView.widthAnchor.constraint(equalToConstant: contentView.intrinsicContentSize.width),
                    contentView.heightAnchor.constraint(equalToConstant: contentView.intrinsicContentSize.height)
                ])
            }

            if segmentView.viewWithTag(Self.accentViewTag) == nil {
                let accentView = accentContentViews[index]
                accentView.tag = Self.accentViewTag
                accentView.translatesAutoresizingMaskIntoConstraints = false
                segmentView.addSubview(accentView)

                NSLayoutConstraint.activate([
                    accentView.centerXAnchor.constraint(equalTo: segmentView.centerXAnchor),
                    accentView.centerYAnchor.constraint(equalTo: segmentView.centerYAnchor),
                    accentView.widthAnchor.constraint(equalToConstant: accentView.intrinsicContentSize.width),
                    accentView.heightAnchor.constraint(equalToConstant: accentView.intrinsicContentSize.height)
                ])

                let maskLayer = CAShapeLayer()
                maskLayer.path = UIBezierPath(rect: .zero).cgPath
                accentView.layer.mask = maskLayer
            }
        }
    }

    private func updateContentViewColors() {
        for contentView in contentViews {
            contentView.tintColor = inactiveTintColor
        }
        for accentView in accentContentViews {
            accentView.tintColor = activeTintColor
        }
    }

    private func findSegmentViews() -> [UIView] {
        var segments: [UIView] = []
        findSegments(in: self, results: &segments)
        return segments.sorted { $0.frame.origin.x < $1.frame.origin.x }
    }

    private func findSegments(in view: UIView, results: inout [UIView]) {
        for subview in view.subviews {
            if String(describing: type(of: subview)) == "UISegment" {
                results.append(subview)
            } else {
                findSegments(in: subview, results: &results)
            }
        }
    }

    private func hideDefaultLabels() {
        hideLabelsRecursively(in: self)
    }

    private func hideLabelsRecursively(in view: UIView) {
        if let label = view as? UILabel,
           label.superview?.tag != Self.injectedViewTag,
           label.superview?.tag != Self.accentViewTag {
            label.isHidden = true
        }

        for subview in view.subviews {
            hideLabelsRecursively(in: subview)
        }
    }

    private func hideSegmentBackgrounds() {
        for subview in subviews where subview is UIImageView {
            subview.alpha = 0
        }
    }

    private func startDisplayLink() {
        guard displayLink == nil else { return }
        let proxy = LiquidGlassDisplayLinkProxy(control: self)
        displayLinkProxy = proxy
        displayLink = CADisplayLink(target: proxy, selector: #selector(LiquidGlassDisplayLinkProxy.handleDisplayLink))
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
        displayLinkProxy = nil
    }

    private func findIndicatorView() -> UIView? {
        if let found = findDescendant(named: "_UILiquidLensView") {
            return found
        }

        let segments = findSegmentViews()
        guard let segmentsContainer = segments.first?.superview,
              let wrapper = segmentsContainer.superview else { return nil }

        return wrapper.subviews.first { sibling in
            sibling !== segmentsContainer && !sibling.subviews.isEmpty
        }
    }

    private func findDescendant(named className: String) -> UIView? {
        func search(in view: UIView) -> UIView? {
            for subview in view.subviews {
                if String(describing: type(of: subview)) == className {
                    return subview
                }
                if let found = search(in: subview) {
                    return found
                }
            }
            return nil
        }

        return search(in: self)
    }

    private func currentIndicatorRect() -> CGRect {
        if cachedIndicatorView == nil {
            cachedIndicatorView = findIndicatorView()
        }

        if let indicatorView = cachedIndicatorView {
            let presentationLayer = indicatorView.layer.presentation() ?? indicatorView.layer
            let selfPresentationLayer = layer.presentation() ?? layer
            return selfPresentationLayer.convert(presentationLayer.bounds, from: presentationLayer)
        }

        didUseIndicatorFallback = true

        let segments = findSegmentViews()
        if selectedSegmentIndex >= 0, selectedSegmentIndex < segments.count {
            return segments[selectedSegmentIndex].frame
        }

        return .zero
    }

    fileprivate func updateAccentMasks() {
        let indicatorRect = currentIndicatorRect()

        if indicatorRect == lastIndicatorRect {
            stableFrameCount += 1
            if stableFrameCount >= Self.stableFrameThreshold {
                displayLink?.isPaused = true
                return
            }
        } else {
            stableFrameCount = 0
            lastIndicatorRect = indicatorRect
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        for (index, accentView) in accentContentViews.enumerated() {
            let baseView = contentViews[index]
            updateMasks(base: baseView, accent: accentView, indicatorRect: indicatorRect)
        }

        CATransaction.commit()
    }

    private func updateMasks(
        base baseView: LiquidGlassNavigationItemView,
        accent accentView: LiquidGlassNavigationItemView,
        indicatorRect: CGRect
    ) {
        let accentPresentationLayer = accentView.layer.presentation() ?? accentView.layer
        let selfPresentationLayer = layer.presentation() ?? layer
        let viewRectInControl = selfPresentationLayer.convert(accentPresentationLayer.bounds, from: accentPresentationLayer)

        let localIndicator = CGRect(
            x: indicatorRect.origin.x - viewRectInControl.origin.x,
            y: indicatorRect.origin.y - viewRectInControl.origin.y,
            width: indicatorRect.width,
            height: indicatorRect.height
        )
        let capsulePath = UIBezierPath(roundedRect: localIndicator, cornerRadius: indicatorRect.height / 2)

        let accentMask = accentView.layer.mask as? CAShapeLayer ?? {
            let mask = CAShapeLayer()
            accentView.layer.mask = mask
            return mask
        }()
        accentMask.path = capsulePath.cgPath

        if indicatorRect.intersects(viewRectInControl) {
            let baseMask = baseView.layer.mask as? CAShapeLayer ?? {
                let mask = CAShapeLayer()
                baseView.layer.mask = mask
                return mask
            }()
            let basePath = UIBezierPath(rect: baseView.bounds)
            basePath.append(capsulePath)
            baseMask.fillRule = .evenOdd
            baseMask.path = basePath.cgPath
        } else {
            baseView.layer.mask = nil
        }
    }

    private func segmentIndex(at point: CGPoint) -> Int {
        guard numberOfSegments > 0 else { return 0 }
        let segmentWidth = bounds.width / CGFloat(numberOfSegments)
        return min(max(Int(point.x / segmentWidth), 0), numberOfSegments - 1)
    }

    private var shouldMoveIndicatorOnTouchDown: Bool {
        !traitCollection.preferredContentSizeCategory.isAccessibilityCategory
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            super.touchesBegan(touches, with: event)
            return
        }

        let newIndex = segmentIndex(at: touch.location(in: self))
        displayLink?.isPaused = false
        stableFrameCount = 0

        if shouldMoveIndicatorOnTouchDown {
            originalIndex = selectedSegmentIndex
            selectedSegmentIndex = newIndex
        }

        super.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            super.touchesMoved(touches, with: event)
            return
        }

        let newIndex = segmentIndex(at: touch.location(in: self))
        displayLink?.isPaused = false
        stableFrameCount = 0

        if shouldMoveIndicatorOnTouchDown && selectedSegmentIndex != newIndex {
            selectedSegmentIndex = newIndex
        }

        super.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        displayLink?.isPaused = false
        stableFrameCount = 0

        if shouldMoveIndicatorOnTouchDown, let originalIndex {
            if selectedSegmentIndex != originalIndex {
                sendActions(for: .valueChanged)
            } else {
                onReselect?(selectedSegmentIndex)
            }
        }

        self.originalIndex = nil
        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        displayLink?.isPaused = false
        stableFrameCount = 0

        if shouldMoveIndicatorOnTouchDown, let originalIndex {
            selectedSegmentIndex = originalIndex
        }

        self.originalIndex = nil
        super.touchesCancelled(touches, with: event)
    }
}

@MainActor
private final class LiquidGlassDisplayLinkProxy: NSObject {
    weak var control: LiquidGlassSegmentedControl?

    init(control: LiquidGlassSegmentedControl) {
        self.control = control
    }

    @objc func handleDisplayLink(_ link: CADisplayLink) {
        guard let control else {
            link.invalidate()
            return
        }

        control.updateAccentMasks()
    }
}

/// Adapted from ryanashcraft/FabBar's TabItemContentView.
@objc(SubrioLiquidGlassNavigationItemView)
final class LiquidGlassNavigationItemView: UIView {
    private var symbolName: String = ""
    private var title: String = ""

    private let font = UIFont.systemFont(ofSize: 8.8, weight: .semibold)
    private let imageAreaHeight: CGFloat = 27

    init(title: String, symbolName: String) {
        self.title = title
        self.symbolName = symbolName
        super.init(frame: .zero)
        isOpaque = false
        isUserInteractionEnabled = false
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        self.symbolName = coder.decodeObject(forKey: "symbolName") as? String ?? ""
        self.title = coder.decodeObject(forKey: "title") as? String ?? ""
        super.init(coder: coder)
        isHidden = true
    }

    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(symbolName, forKey: "symbolName")
        coder.encode(title, forKey: "title")
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        setNeedsDisplay()
    }

    override var intrinsicContentSize: CGSize {
        let textSize = (title as NSString).size(withAttributes: [.font: font])
        let icon = loadIcon()
        let contentWidth = max(icon?.size.width ?? 0, textSize.width)
        let height = imageAreaHeight + textSize.height
        return CGSize(width: contentWidth, height: height)
    }

    override func draw(_ rect: CGRect) {
        let tintColor = tintColor ?? .label
        let icon = loadIcon()
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: tintColor
        ]
        let textSize = (title as NSString).size(withAttributes: textAttributes)
        let contentNudgeUp: CGFloat = 1
        let iconTextGap: CGFloat = 1

        if let icon {
            let imageSize = icon.size
            let imageX = (bounds.width - imageSize.width) / 2
            let imageY = (imageAreaHeight - imageSize.height) / 2 - contentNudgeUp
            let imageRect = CGRect(x: imageX, y: imageY, width: imageSize.width, height: imageSize.height)

            tintColor.setFill()
            icon.withRenderingMode(.alwaysTemplate).draw(in: imageRect)
        }

        let textX = (bounds.width - textSize.width) / 2
        let textPoint = CGPoint(x: textX, y: imageAreaHeight - contentNudgeUp + iconTextGap)
        (title as NSString).draw(at: textPoint, withAttributes: textAttributes)
    }

    private func loadIcon() -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 15.5, weight: .semibold, scale: .medium)
        return UIImage(systemName: symbolName, withConfiguration: config)
    }
}
