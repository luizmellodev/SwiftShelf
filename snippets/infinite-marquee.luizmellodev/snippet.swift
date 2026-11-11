import SwiftUI

// MARK: - Direction

public enum InfiniteMarqueeDirection {
    case left, right

    var sign: CGFloat { self == .left ? 1 : -1 }
}

// MARK: - Infinite Marquee

/// A seamless, endlessly scrolling row. Content is tiled as many times as
/// needed to fill the width and wrapped with modulo math, so there is never
/// a visible seam.
///
/// Touch to pause, drag to scrub, and flick to throw it — the row coasts
/// with momentum, then eases back to its cruising speed.
public struct InfiniteMarquee<Content: View>: View {
    var speed: CGFloat
    var direction: InfiniteMarqueeDirection
    var spacing: CGFloat
    var fadeWidth: CGFloat
    let content: Content

    @State private var engine = InfiniteMarqueeEngine()
    @State private var contentWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var isTouching = false

    /// - Parameters:
    ///   - speed: Cruising speed in points per second.
    ///   - direction: Which way the content travels.
    ///   - spacing: Gap between repeated copies (and should match your inner spacing).
    ///   - fadeWidth: Fraction of the width faded out at each edge (0...0.5).
    public init(
        speed: CGFloat = 40,
        direction: InfiniteMarqueeDirection = .left,
        spacing: CGFloat = 12,
        fadeWidth: CGFloat = 0.12,
        @ViewBuilder content: () -> Content
    ) {
        self.speed = speed
        self.direction = direction
        self.spacing = spacing
        self.fadeWidth = min(max(fadeWidth, 0), 0.5)
        self.content = content()
    }

    private var period: CGFloat { contentWidth + spacing }

    private var copies: Int {
        guard period > 1 else { return 1 }
        return Int((containerWidth / period).rounded(.up)) + 1
    }

    public var body: some View {
        // The GeometryReader takes exactly the proposed width, so the number of
        // copies can never feed back into the measured container width.
        GeometryReader { proxy in
            TimelineView(.animation) { timeline in
                let offset = engine.step(to: timeline.date, speed: speed * direction.sign)
                let wrapped = period > 1 ? offset.truncatingRemainder(dividingBy: period) : 0
                let x = -(wrapped < 0 ? wrapped + period : wrapped)

                HStack(spacing: spacing) {
                    ForEach(0..<copies, id: \.self) { index in
                        content
                            .fixedSize()
                            .onGeometryChange(for: CGSize.self) { $0.size } action: { size in
                                guard index == 0 else { return }
                                if contentWidth != size.width { contentWidth = size.width }
                                if contentHeight != size.height { contentHeight = size.height }
                            }
                            .accessibilityHidden(index > 0)
                    }
                }
                .fixedSize()
                .offset(x: x)
                .frame(width: proxy.size.width, alignment: .leading)
            }
            .onAppear { containerWidth = proxy.size.width }
            .onChange(of: proxy.size.width) { _, width in containerWidth = width }
        }
        .frame(height: contentHeight)
        .scaleEffect(isTouching ? 0.985 : 1)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isTouching)
        .clipped()
        .mask {
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: fadeWidth),
                    .init(color: .black, location: 1 - fadeWidth),
                    .init(color: .clear, location: 1),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if !isTouching {
                        isTouching = true
                        engine.beginTouch()
                    }
                    engine.scrub(translation: value.translation.width)
                }
                .onEnded { value in
                    isTouching = false
                    engine.endTouch(velocity: value.velocity.width)
                }
        )
        .sensoryFeedback(.impact(weight: .light), trigger: isTouching) { _, touching in touching }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - Engine

/// Plain (non-observable) physics state. The `TimelineView` re-renders every
/// frame anyway, so mutating this during body evaluation never invalidates
/// SwiftUI state.
private final class InfiniteMarqueeEngine {
    private(set) var offset: CGFloat = 0
    private var momentum: CGFloat = 0
    private var cruise: CGFloat = 1
    private var isTouching = false
    private var touchStartOffset: CGFloat = 0
    private var lastDate: Date?

    func step(to date: Date, speed: CGFloat) -> CGFloat {
        let dt = CGFloat(min(lastDate.map { date.timeIntervalSince($0) } ?? 0, 1 / 20))
        lastDate = date
        guard !isTouching, dt > 0 else { return offset }

        // Momentum decays quickly; cruise speed eases back in after release.
        momentum *= pow(0.035, dt)
        if abs(momentum) < 1 { momentum = 0 }
        cruise += (1 - cruise) * min(1, dt * 2.2)
        offset += (speed * cruise + momentum) * dt
        return offset
    }

    func beginTouch() {
        isTouching = true
        touchStartOffset = offset
        momentum = 0
        cruise = 0
    }

    func scrub(translation: CGFloat) {
        offset = touchStartOffset - translation
    }

    func endTouch(velocity: CGFloat) {
        isTouching = false
        momentum = max(-4000, min(4000, -velocity))
        lastDate = nil
    }
}

// MARK: - Chip

/// A ready-made logo/tag chip that looks great inside a marquee.
public struct InfiniteMarqueeChip: View {
    let title: String
    let systemImage: String
    let tint: Color

    public init(_ title: String, systemImage: String, tint: Color = .accentColor) {
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
    }

    public var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(tint.gradient, in: Circle())
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .padding(.leading, 6)
        .padding(.trailing, 16)
        .padding(.vertical, 6)
        .background(Color(.secondarySystemBackground), in: Capsule())
        .overlay(Capsule().strokeBorder(Color(.separator).opacity(0.5), lineWidth: 0.5))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview("Infinite Marquee") {
    let top: [(String, String, Color)] = [
        ("Swift", "swift", .orange), ("Vision", "eye.fill", .purple), ("Maps", "map.fill", .green),
        ("Music", "music.note", .pink), ("Health", "heart.fill", .red), ("Weather", "cloud.sun.fill", .blue),
    ]
    let bottom: [(String, String, Color)] = [
        ("Camera", "camera.fill", .gray), ("Wallet", "wallet.bifold.fill", .indigo), ("Notes", "note.text", .yellow),
        ("Fitness", "figure.run", .mint), ("Photos", "photo.fill", .teal), ("Books", "book.fill", .brown),
    ]

    VStack(spacing: 14) {
        InfiniteMarquee(speed: 36, direction: .left) {
            HStack(spacing: 12) {
                ForEach(top, id: \.0) { InfiniteMarqueeChip($0.0, systemImage: $0.1, tint: $0.2) }
            }
        }
        InfiniteMarquee(speed: 28, direction: .right) {
            HStack(spacing: 12) {
                ForEach(bottom, id: \.0) { InfiniteMarqueeChip($0.0, systemImage: $0.1, tint: $0.2) }
            }
        }
    }
    .padding(.vertical, 40)
}
