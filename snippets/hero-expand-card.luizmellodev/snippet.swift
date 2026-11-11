import SwiftUI

// MARK: - Model

/// One story in a `HeroExpandCardFeed`. Artwork is a mesh gradient plus an
/// SF Symbol, so the snippet needs no image assets.
public struct HeroExpandCardItem: Identifiable {
    public let id: String
    let eyebrow: String
    let title: String
    let subtitle: String
    let systemImage: String
    /// 9 colors for a 3×3 mesh gradient.
    let colors: [Color]
    let paragraphs: [String]

    public init(
        eyebrow: String,
        title: String,
        subtitle: String,
        systemImage: String,
        colors: [Color],
        paragraphs: [String]
    ) {
        precondition(colors.count == 9, "HeroExpandCardItem needs 9 colors (3×3 mesh).")
        self.id = eyebrow + title
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.colors = colors
        self.paragraphs = paragraphs
    }
}

// MARK: - Feed

/// An App Store "Today"-style feed. Tapping a card morphs it into a
/// full-screen story with `matchedGeometryEffect`: the frame, artwork and
/// title fly into place, the corners straighten, and the body copy rises in
/// with a stagger. Pull down from the top to shrink the card back
/// interactively, or tap the close button.
public struct HeroExpandCardFeed<Header: View>: View {
    let items: [HeroExpandCardItem]
    var cardHeight: CGFloat
    var cornerRadius: CGFloat
    var dismissThreshold: CGFloat
    let header: Header

    @Namespace private var namespace
    @State private var selectedID: String?
    @State private var lastSelectedID: String?
    @State private var showContent = false
    @State private var scrollPull: CGFloat = 0
    @State private var dragPull: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    /// How far the detail is being pulled down, from overscroll or a direct drag.
    private var pull: CGFloat { max(scrollPull, dragPull) }
    @State private var isClosing = false

    private let openSpring = Animation.spring(response: 0.52, dampingFraction: 0.84)
    private let closeSpring = Animation.spring(response: 0.46, dampingFraction: 0.86)

    public init(
        items: [HeroExpandCardItem],
        cardHeight: CGFloat = 440,
        cornerRadius: CGFloat = 30,
        dismissThreshold: CGFloat = 90,
        @ViewBuilder header: () -> Header
    ) {
        self.items = items
        self.cardHeight = cardHeight
        self.cornerRadius = cornerRadius
        self.dismissThreshold = dismissThreshold
        self.header = header()
    }

    private var selectedItem: HeroExpandCardItem? {
        items.first { $0.id == selectedID }
    }

    public var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    header
                    ForEach(items) { item in
                        cardSlot(item)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .scrollClipDisabled()
            .scrollDisabled(selectedID != nil)

            if let item = selectedItem {
                detail(item)
                    .zIndex(2)
                    .transition(.identity)
            }
        }
        .toolbarVisibility(selectedID == nil ? .automatic : .hidden, for: .navigationBar)
        .sensoryFeedback(.impact(weight: .medium), trigger: selectedID)
        .sensoryFeedback(.impact(weight: .light), trigger: pull > dismissThreshold) { _, crossed in crossed }
    }

    // MARK: Card

    @ViewBuilder
    private func cardSlot(_ item: HeroExpandCardItem) -> some View {
        if selectedID == item.id {
            Color.clear.frame(height: cardHeight)
        } else {
            Button { open(item) } label: {
                artwork(item, expanded: false)
                    .frame(height: cardHeight)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .matchedGeometryEffect(id: "container-\(item.id)", in: namespace)
                    .shadow(color: .black.opacity(0.18), radius: 22, y: 12)
            }
            .buttonStyle(HeroExpandCardPressStyle())
            .zIndex(lastSelectedID == item.id ? 1 : 0)
            .transition(.identity)
            .accessibilityLabel("\(item.eyebrow), \(item.title)")
            .accessibilityHint("Opens the story")
        }
    }

    // MARK: Artwork

    private func artwork(_ item: HeroExpandCardItem, expanded: Bool) -> some View {
        ZStack(alignment: .bottomLeading) {
            HeroExpandCardMesh(colors: item.colors)

            Image(systemName: item.systemImage)
                .font(.system(size: 120, weight: .bold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)
                .shadow(color: .white.opacity(0.5), radius: 30)
                .rotationEffect(.degrees(-8))
                .matchedGeometryEffect(id: "symbol-\(item.id)", in: namespace)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(y: -40)

            LinearGradient(colors: [.clear, .black.opacity(0.45)], startPoint: .center, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.eyebrow.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(1.2)
                    .opacity(0.8)
                Text(item.title)
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(item.subtitle)
                    .font(.subheadline.weight(.medium))
                    .opacity(0.85)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .matchedGeometryEffect(id: "title-\(item.id)", in: namespace)
            .padding(22)
        }
        .clipped()
    }

    // MARK: Detail

    private func detail(_ item: HeroExpandCardItem) -> some View {
        let progress = min(pull / (dismissThreshold * 1.6), 1)
        let radius = showContent ? min(cornerRadius + 10, pull * 0.6) : cornerRadius

        return ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                artwork(item, expanded: true)
                    .frame(height: cardHeight)

                VStack(alignment: .leading, spacing: 18) {
                    ForEach(Array(item.paragraphs.enumerated()), id: \.offset) { index, paragraph in
                        Text(paragraph)
                            .font(index == 0 ? .title3.weight(.semibold) : .body)
                            .foregroundStyle(index == 0 ? Color(.label) : Color(.secondaryLabel))
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(showContent ? 1 : 0)
                            .blur(radius: showContent ? 0 : 6)
                            .offset(y: showContent ? 0 : 28)
                            .animation(
                                showContent
                                    ? .spring(response: 0.55, dampingFraction: 0.85).delay(0.12 + Double(index) * 0.06)
                                    : .easeOut(duration: 0.12),
                                value: showContent
                            )
                    }
                }
                .padding(24)
                .padding(.bottom, 60)
            }
            // Keep the content pinned while the user pulls; only the card shrinks.
            .offset(y: -pull)
        }
        .scrollIndicators(.hidden)
        // Short articles must still rubber-band, otherwise pull-to-dismiss can't start.
        .scrollBounceBehavior(.always, axes: .vertical)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top
        } action: { _, offset in
            scrollOffset = offset
            guard showContent, !isClosing else { return }
            scrollPull = max(0, -offset)
            if pull > dismissThreshold * 1.25 { close() }
        }
        .onScrollPhaseChange { oldPhase, newPhase in
            if oldPhase == .interacting, newPhase != .interacting, pull > dismissThreshold { close() }
        }
        // Direct drag-down, so dismissal works even when the article is too short to overscroll.
        .simultaneousGesture(
            DragGesture(minimumDistance: 12)
                .onChanged { value in
                    guard showContent, !isClosing, scrollOffset <= 1, value.translation.height > 0 else { return }
                    dragPull = value.translation.height * 0.55
                }
                .onEnded { value in
                    guard !isClosing else { return }
                    if dragPull > dismissThreshold || value.predictedEndTranslation.height > 360 {
                        close()
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { dragPull = 0 }
                    }
                }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
        .matchedGeometryEffect(id: "container-\(item.id)", in: namespace)
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .overlay(alignment: .topTrailing) {
            Button(action: close) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(width: 34, height: 34)
                    .background(.ultraThinMaterial, in: Circle())
                    .contentShape(Circle())
            }
            .buttonStyle(HeroExpandCardPressStyle())
            .padding(.top, 62)
            .padding(.trailing, 18)
            .opacity(showContent ? 1 - progress : 0)
            .scaleEffect(showContent ? 1 : 0.5)
            .animation(.spring(response: 0.4, dampingFraction: 0.65).delay(showContent ? 0.2 : 0), value: showContent)
            .accessibilityLabel("Close")
        }
        .scaleEffect(1 - progress * 0.14)
        .shadow(color: .black.opacity(0.25 * progress), radius: 30, y: 10)
        .ignoresSafeArea()
        .accessibilityAction(.escape) { close() }
    }

    // MARK: Actions

    private func open(_ item: HeroExpandCardItem) {
        scrollPull = 0
        dragPull = 0
        isClosing = false
        lastSelectedID = item.id
        withAnimation(openSpring) { selectedID = item.id }
        // A separate transaction, so the freshly inserted detail animates its corners and content.
        DispatchQueue.main.async {
            withAnimation(openSpring) { showContent = true }
        }
    }

    private func close() {
        guard !isClosing, selectedID != nil else { return }
        isClosing = true
        withAnimation(closeSpring) { showContent = false }
        DispatchQueue.main.async {
            withAnimation(closeSpring) {
                selectedID = nil
                scrollPull = 0
                dragPull = 0
            }
        }
    }
}

public extension HeroExpandCardFeed where Header == EmptyView {
    init(items: [HeroExpandCardItem], cardHeight: CGFloat = 440, cornerRadius: CGFloat = 30) {
        self.init(items: items, cardHeight: cardHeight, cornerRadius: cornerRadius) { EmptyView() }
    }
}

// MARK: - Helpers

/// A slowly drifting 3×3 mesh, used as the card "photo".
private struct HeroExpandCardMesh: View {
    let colors: [Color]

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate * 0.6
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0, 0], [Float(0.5 + 0.15 * sin(t)), 0], [1, 0],
                    [0, Float(0.5 + 0.15 * cos(t * 0.8))],
                    [Float(0.5 + 0.2 * sin(t * 0.7)), Float(0.5 + 0.2 * cos(t * 0.9))],
                    [1, Float(0.5 + 0.15 * sin(t * 1.1))],
                    [0, 1], [Float(0.5 + 0.2 * cos(t * 0.6)), 1], [1, 1],
                ],
                colors: colors
            )
        }
    }
}

private struct HeroExpandCardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

// MARK: - Sample Data

public extension HeroExpandCardItem {
    static let samples: [HeroExpandCardItem] = [
        HeroExpandCardItem(
            eyebrow: "Meet the developer",
            title: "Painting with Light",
            subtitle: "How a two-person studio built Lumen",
            systemImage: "camera.aperture",
            colors: [
                Color(red: 0.98, green: 0.45, blue: 0.3), Color(red: 1.0, green: 0.65, blue: 0.35), Color(red: 0.95, green: 0.3, blue: 0.45),
                Color(red: 0.85, green: 0.25, blue: 0.55), Color(red: 1.0, green: 0.5, blue: 0.4), Color(red: 0.6, green: 0.2, blue: 0.7),
                Color(red: 0.4, green: 0.15, blue: 0.6), Color(red: 0.75, green: 0.2, blue: 0.5), Color(red: 0.3, green: 0.1, blue: 0.45),
            ],
            paragraphs: [
                "Lumen started as a weekend experiment: what if editing photos felt like painting with a flashlight?",
                "The team spent a year tuning a single gesture. Drag anywhere on the photo and light pours out of your fingertip, spreading across surfaces the way it would in the real world.",
                "Every slider in the app is optional. Most edits take one swipe, and the app learns which looks you come back to.",
                "\"We wanted the tool to disappear,\" says co-founder Ana. \"You should remember the photo, not the app.\"",
            ]
        ),
        HeroExpandCardItem(
            eyebrow: "App of the day",
            title: "Deep Focus",
            subtitle: "Soundscapes that adapt to you",
            systemImage: "waveform.circle.fill",
            colors: [
                Color(red: 0.1, green: 0.2, blue: 0.55), Color(red: 0.2, green: 0.45, blue: 0.9), Color(red: 0.1, green: 0.6, blue: 0.85),
                Color(red: 0.25, green: 0.15, blue: 0.6), Color(red: 0.3, green: 0.5, blue: 1.0), Color(red: 0.2, green: 0.8, blue: 0.8),
                Color(red: 0.1, green: 0.1, blue: 0.35), Color(red: 0.2, green: 0.3, blue: 0.7), Color(red: 0.15, green: 0.55, blue: 0.65),
            ],
            paragraphs: [
                "Deep Focus composes music in real time, matched to your heart rate and the time of day.",
                "Start a session and the soundscape slowly narrows, filtering out busy melodies as you settle in.",
                "It works offline, never interrupts with ads, and fades out gently when your timer ends.",
            ]
        ),
    ]
}

// MARK: - Preview

#Preview("Hero Expand Card") {
    HeroExpandCardFeed(items: HeroExpandCardItem.samples) {
        VStack(alignment: .leading, spacing: 2) {
            Text("TUESDAY, NOVEMBER 11")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("Today")
                .font(.largeTitle.bold())
        }
        .padding(.top, 8)
    }
    .background(Color(.systemBackground))
}
