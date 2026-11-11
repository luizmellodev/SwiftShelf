import SwiftUI

// MARK: - Segment Model

public struct ElasticSegment: Hashable {
    public let title: String
    public let systemImage: String?

    public init(_ title: String, systemImage: String? = nil) {
        self.title = title
        self.systemImage = systemImage
    }
}

// MARK: - Elastic Segmented Control

/// A segmented control whose pill *stretches* toward the new segment:
/// the leading edge races ahead on a fast spring while the trailing edge
/// catches up on a slower one, like a drop of liquid.
///
/// The labels are drawn twice — once under the pill and once on top, masked
/// by the pill — so the text color flips exactly at the pill's edge.
/// You can tap a segment or scrub across the control with your finger.
public struct ElasticSegmentedControl: View {
    @Binding var selection: Int
    let segments: [ElasticSegment]
    var tint: Color
    var selectedForeground: Color
    var height: CGFloat

    @State private var frames: [Int: CGRect] = [:]
    @State private var leading: CGFloat = 0
    @State private var trailing: CGFloat = 0

    private let space = "elastic-segmented-control"

    public init(
        selection: Binding<Int>,
        segments: [ElasticSegment],
        tint: Color = .primary,
        selectedForeground: Color = Color(.systemBackground),
        height: CGFloat = 46
    ) {
        self._selection = selection
        self.segments = segments
        self.tint = tint
        self.selectedForeground = selectedForeground
        self.height = height
    }

    private var pillHeight: CGFloat { height - 8 }
    private var pillWidth: CGFloat { max(trailing - leading, 0) }

    public var body: some View {
        ZStack(alignment: .leading) {
            labels(highlighted: false)

            Capsule()
                .fill(tint)
                .frame(width: pillWidth, height: pillHeight)
                .offset(x: leading)
                .shadow(color: tint.opacity(0.25), radius: 8, y: 3)

            labels(highlighted: true)
                .mask(alignment: .leading) {
                    Capsule()
                        .frame(width: pillWidth, height: pillHeight)
                        .offset(x: leading)
                }
                .allowsHitTesting(false)
        }
        .coordinateSpace(.named(space))
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in select(atX: value.location.x) }
        )
        .padding(4)
        .background(Color(.tertiarySystemFill), in: Capsule())
        .onChange(of: selection) { _, newValue in move(to: newValue) }
        .sensoryFeedback(.selection, trigger: selection)
    }

    // MARK: Labels

    private func labels(highlighted: Bool) -> some View {
        HStack(spacing: 0) {
            ForEach(segments.indices, id: \.self) { index in
                let segment = segments[index]
                HStack(spacing: 6) {
                    if let systemImage = segment.systemImage {
                        Image(systemName: systemImage)
                            .font(.system(size: 15, weight: .semibold))
                    }
                    Text(segment.title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                }
                .foregroundStyle(highlighted ? selectedForeground : Color.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: pillHeight)
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(space)) } action: { rect in
                    guard !highlighted else { return }
                    frames[index] = rect
                    if index == selection { snap(to: rect) }
                }
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(index == selection ? [.isButton, .isSelected] : .isButton)
                .accessibilityHidden(highlighted)
            }
        }
    }

    // MARK: Motion

    private func select(atX x: CGFloat) {
        guard let hit = frames.first(where: { $0.value.minX...$0.value.maxX ~= x })?.key,
              hit != selection else { return }
        selection = hit
    }

    private func snap(to rect: CGRect) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            leading = rect.minX
            trailing = rect.maxX
        }
    }

    private func move(to index: Int) {
        guard let target = frames[index] else { return }
        let movingRight = target.midX > (leading + trailing) / 2

        let fast = Animation.spring(response: 0.24, dampingFraction: 0.78)
        let slow = Animation.spring(response: 0.48, dampingFraction: 0.72)

        withAnimation(movingRight ? fast : slow) { trailing = target.maxX }
        withAnimation(movingRight ? slow : fast) { leading = target.minX }
    }
}

// MARK: - Preview

#Preview("Elastic Segmented Control") {
    @Previewable @State var filter = 0
    @Previewable @State var tab = 1

    VStack(spacing: 32) {
        ElasticSegmentedControl(
            selection: $filter,
            segments: [.init("Popular"), .init("New"), .init("Following")]
        )

        ElasticSegmentedControl(
            selection: $tab,
            segments: [
                .init("Home", systemImage: "house.fill"),
                .init("Explore", systemImage: "safari.fill"),
                .init("Saved", systemImage: "bookmark.fill"),
            ],
            tint: .indigo,
            selectedForeground: .white,
            height: 52
        )
    }
    .padding(24)
}
