import SwiftUI

// MARK: - Model

/// One page of a `ParallaxCarousel`. The "photo" is a mesh gradient with a
/// large SF Symbol, so the snippet needs no image assets.
public struct ParallaxCarouselSlide: Identifiable, Hashable {
    public let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    /// 9 colors for a 3×3 mesh gradient.
    let colors: [Color]

    public init(title: String, subtitle: String, systemImage: String, colors: [Color]) {
        precondition(colors.count == 9, "ParallaxCarouselSlide needs 9 colors (3×3 mesh).")
        self.id = title
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.colors = colors
    }
}

// MARK: - Parallax Carousel

/// A snapping, horizontally paging carousel. Neighbors shrink, swing back in
/// 3D and dim, while each card's artwork drifts slower than the card itself
/// for a parallax "window" effect. The page indicator stretches continuously
/// with the scroll position, not just on page change.
public struct ParallaxCarousel: View {
    let slides: [ParallaxCarouselSlide]
    var cardHeight: CGFloat
    var peek: CGFloat
    var spacing: CGFloat
    var parallax: CGFloat
    var maxRotation: Double

    @State private var currentID: String?
    /// Scroll progress lives in a reference type that only the indicator reads,
    /// so scrolling never re-evaluates the cards themselves.
    @State private var tracker = ParallaxCarouselTracker()

    public init(
        slides: [ParallaxCarouselSlide],
        cardHeight: CGFloat = 440,
        peek: CGFloat = 40,
        spacing: CGFloat = 14,
        parallax: CGFloat = 90,
        maxRotation: Double = 16
    ) {
        self.slides = slides
        self.cardHeight = cardHeight
        self.peek = peek
        self.spacing = spacing
        self.parallax = parallax
        self.maxRotation = maxRotation
    }

    public var body: some View {
        VStack(spacing: 22) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: spacing) {
                    ForEach(slides) { slide in
                        card(slide)
                            .containerRelativeFrame(.horizontal)
                            .visualEffect { [spacing, maxRotation] content, proxy in
                                let phase = parallaxPhase(proxy, spacing: spacing)
                                return content
                                    .scaleEffect(1 - abs(phase) * 0.12)
                                    .rotation3DEffect(
                                        .degrees(phase * -maxRotation),
                                        axis: (x: 0, y: 1, z: 0),
                                        perspective: 0.55
                                    )
                                    .opacity(1 - abs(phase) * 0.35)
                            }
                            .id(slide.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .safeAreaPadding(.horizontal, peek)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $currentID)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                // containerSize already excludes the peek insets, so it equals one card's width.
                let pageWidth = geometry.containerSize.width
                guard pageWidth > 0 else { return 0 }
                return (geometry.contentOffset.x + geometry.contentInsets.leading) / (pageWidth + spacing)
            } action: { _, value in
                tracker.progress = value
            }
            .frame(height: cardHeight)

            ParallaxCarouselIndicator(slides: slides, tracker: tracker, currentID: $currentID)
        }
        .onAppear { if currentID == nil { currentID = slides.first?.id } }
        .sensoryFeedback(.selection, trigger: currentID)
    }

    // MARK: Card

    private func card(_ slide: ParallaxCarouselSlide) -> some View {
        let shape = RoundedRectangle(cornerRadius: 32, style: .continuous)

        return ZStack(alignment: .bottomLeading) {
            // Inner "photo" layer. It hangs off a card-sized host as an overlay, so it can be
            // wider than the card (overscan for the parallax travel) without changing layout,
            // and the host's scroll phase stays exactly 0 at rest.
            Color.clear
                .overlay {
                    ZStack {
                        MeshGradient(
                            width: 3, height: 3,
                            points: [[0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.55, 0.45], [1, 0.5], [0, 1], [0.5, 1], [1, 1]],
                            colors: slide.colors
                        )
                        Image(systemName: slide.systemImage)
                            .font(.system(size: 150, weight: .bold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white.opacity(0.92))
                            .shadow(color: .white.opacity(0.45), radius: 40)
                            .offset(y: -50)
                    }
                    .compositingGroup()
                    .padding(.horizontal, -parallax)
                }
                .scaleEffect(1.08)
                .visualEffect { [spacing, parallax] content, proxy in
                    content.offset(x: parallaxPhase(proxy, spacing: spacing) * -parallax)
                }

            LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .center, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 4) {
                Text(slide.title)
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                Text(slide.subtitle)
                    .font(.subheadline.weight(.medium))
                    .opacity(0.85)
            }
            .foregroundStyle(.white)
            .padding(24)
            // Card-sized host, so the phase is measured from the card's center.
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            // Text drifts the other way, so it separates from the artwork.
            .visualEffect { [spacing, parallax] content, proxy in
                let phase = parallaxPhase(proxy, spacing: spacing)
                return content
                    .offset(x: phase * parallax * 0.5)
                    .opacity(1 - abs(phase) * 0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .clipShape(shape)
        .overlay(shape.strokeBorder(.white.opacity(0.18), lineWidth: 1))
        .compositingGroup()
        .shadow(color: .black.opacity(0.2), radius: 18, y: 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(slide.title). \(slide.subtitle)")
    }
}

// MARK: - Phase

/// How many pages a card-sized view sits from the center of the carousel
/// (0 = centered, ±1 = one page over). Read from live geometry on every frame,
/// so it always settles at exactly 0 — unlike `scrollTransition`, which can
/// stay stuck mid-transition after a snap.
nonisolated private func parallaxPhase(_ proxy: GeometryProxy, spacing: CGFloat) -> Double {
    let frame = proxy.frame(in: .scrollView(axis: .horizontal))
    guard let bounds = proxy.bounds(of: .scrollView(axis: .horizontal)), frame.width > 0 else { return 0 }
    let raw = (frame.midX - bounds.width / 2) / (frame.width + spacing)
    let phase = Double(min(max(raw, -1), 1))
    return abs(phase) < 0.002 ? 0 : phase
}

// MARK: - Indicator

@Observable
private final class ParallaxCarouselTracker {
    var progress: CGFloat = 0
}

/// Stretches continuously with the scroll position, not just on page change.
private struct ParallaxCarouselIndicator: View {
    let slides: [ParallaxCarouselSlide]
    let tracker: ParallaxCarouselTracker
    @Binding var currentID: String?

    var body: some View {
        HStack(spacing: 7) {
            ForEach(Array(slides.enumerated()), id: \.element.id) { index, slide in
                let closeness = max(0, 1 - abs(tracker.progress - CGFloat(index)))
                Capsule()
                    .fill(Color(.label).opacity(0.22 + 0.78 * closeness))
                    .frame(width: 8 + 22 * closeness, height: 8)
                    .contentShape(Rectangle().inset(by: -6))
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { currentID = slide.id }
                    }
                    .accessibilityLabel("Page \(index + 1) of \(slides.count)")
                    .accessibilityAddTraits(currentID == slide.id ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(.regularMaterial, in: Capsule())
    }
}

// MARK: - Sample Data

public extension ParallaxCarouselSlide {
    static let samples: [ParallaxCarouselSlide] = [
        .init(title: "Northern Lights", subtitle: "Tromsø, Norway", systemImage: "sparkles", colors: [
            Color(red: 0.05, green: 0.1, blue: 0.3), Color(red: 0.1, green: 0.5, blue: 0.5), Color(red: 0.05, green: 0.15, blue: 0.35),
            Color(red: 0.1, green: 0.7, blue: 0.5), Color(red: 0.3, green: 0.9, blue: 0.6), Color(red: 0.4, green: 0.3, blue: 0.8),
            Color(red: 0.05, green: 0.1, blue: 0.25), Color(red: 0.1, green: 0.3, blue: 0.4), Color(red: 0.2, green: 0.1, blue: 0.4),
        ]),
        .init(title: "Desert Bloom", subtitle: "Atacama, Chile", systemImage: "sun.horizon.fill", colors: [
            Color(red: 1.0, green: 0.75, blue: 0.4), Color(red: 1.0, green: 0.55, blue: 0.35), Color(red: 0.95, green: 0.4, blue: 0.4),
            Color(red: 1.0, green: 0.6, blue: 0.3), Color(red: 0.95, green: 0.45, blue: 0.5), Color(red: 0.7, green: 0.3, blue: 0.55),
            Color(red: 0.8, green: 0.35, blue: 0.3), Color(red: 0.6, green: 0.25, blue: 0.45), Color(red: 0.35, green: 0.15, blue: 0.4),
        ]),
        .init(title: "Deep Blue", subtitle: "Raja Ampat, Indonesia", systemImage: "fish.fill", colors: [
            Color(red: 0.3, green: 0.8, blue: 0.95), Color(red: 0.2, green: 0.6, blue: 0.9), Color(red: 0.15, green: 0.75, blue: 0.8),
            Color(red: 0.1, green: 0.45, blue: 0.8), Color(red: 0.1, green: 0.55, blue: 0.85), Color(red: 0.1, green: 0.35, blue: 0.7),
            Color(red: 0.05, green: 0.15, blue: 0.45), Color(red: 0.05, green: 0.25, blue: 0.55), Color(red: 0.05, green: 0.1, blue: 0.35),
        ]),
        .init(title: "Alpine Dawn", subtitle: "Dolomites, Italy", systemImage: "mountain.2.fill", colors: [
            Color(red: 0.95, green: 0.7, blue: 0.8), Color(red: 0.85, green: 0.6, blue: 0.9), Color(red: 0.6, green: 0.6, blue: 0.95),
            Color(red: 0.9, green: 0.55, blue: 0.65), Color(red: 0.65, green: 0.5, blue: 0.85), Color(red: 0.4, green: 0.45, blue: 0.8),
            Color(red: 0.35, green: 0.3, blue: 0.55), Color(red: 0.25, green: 0.25, blue: 0.5), Color(red: 0.15, green: 0.15, blue: 0.35),
        ]),
        .init(title: "Rainforest", subtitle: "Monteverde, Costa Rica", systemImage: "leaf.fill", colors: [
            Color(red: 0.6, green: 0.9, blue: 0.5), Color(red: 0.3, green: 0.75, blue: 0.4), Color(red: 0.5, green: 0.85, blue: 0.6),
            Color(red: 0.15, green: 0.55, blue: 0.35), Color(red: 0.2, green: 0.65, blue: 0.4), Color(red: 0.1, green: 0.45, blue: 0.4),
            Color(red: 0.05, green: 0.25, blue: 0.2), Color(red: 0.1, green: 0.35, blue: 0.25), Color(red: 0.05, green: 0.2, blue: 0.2),
        ]),
    ]
}

// MARK: - Preview

#Preview("Parallax Carousel") {
    VStack(alignment: .leading, spacing: 20) {
        Text("Explore")
            .font(.largeTitle.bold())
            .padding(.horizontal, 20)
        ParallaxCarousel(slides: ParallaxCarouselSlide.samples)
        Spacer()
    }
    .padding(.top, 20)
}
