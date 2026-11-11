import SwiftUI

// MARK: - Style

/// The look of an `AnimatedLikeButton`: which symbol it uses, its gradient,
/// and the colors of the sparks it throws. Use a preset or build your own.
public struct AnimatedLikeStyle {
    public var symbol: String
    public var filledSymbol: String
    /// Gradient for the filled icon and the ring (top-leading → bottom-trailing).
    public var colors: [Color]
    /// Colors cycled through by the spark particles.
    public var sparks: [Color]
    /// VoiceOver name, e.g. "Like".
    public var label: String

    public init(symbol: String, filledSymbol: String, colors: [Color], sparks: [Color], label: String) {
        self.symbol = symbol
        self.filledSymbol = filledSymbol
        self.colors = colors.isEmpty ? [.accentColor] : colors
        self.sparks = sparks.isEmpty ? self.colors : sparks
        self.label = label
    }

    public static let heart = AnimatedLikeStyle(
        symbol: "heart", filledSymbol: "heart.fill",
        colors: [Color(red: 1.0, green: 0.36, blue: 0.5), Color(red: 0.93, green: 0.11, blue: 0.32)],
        sparks: [Color(red: 1.0, green: 0.36, blue: 0.5), Color(red: 1.0, green: 0.62, blue: 0.25),
                 Color(red: 0.69, green: 0.45, blue: 1.0), Color(red: 0.33, green: 0.72, blue: 1.0),
                 Color(red: 1.0, green: 0.8, blue: 0.25)],
        label: "Like"
    )

    public static let star = AnimatedLikeStyle(
        symbol: "star", filledSymbol: "star.fill",
        colors: [Color(red: 1.0, green: 0.84, blue: 0.25), Color(red: 1.0, green: 0.58, blue: 0.1)],
        sparks: [Color(red: 1.0, green: 0.84, blue: 0.25), Color(red: 1.0, green: 0.55, blue: 0.2),
                 Color(red: 1.0, green: 0.4, blue: 0.45), Color(red: 0.98, green: 0.92, blue: 0.55)],
        label: "Favorite"
    )

    public static let bookmark = AnimatedLikeStyle(
        symbol: "bookmark", filledSymbol: "bookmark.fill",
        colors: [Color(red: 0.36, green: 0.62, blue: 1.0), Color(red: 0.4, green: 0.33, blue: 0.98)],
        sparks: [Color(red: 0.36, green: 0.62, blue: 1.0), Color(red: 0.25, green: 0.85, blue: 0.75),
                 Color(red: 0.62, green: 0.45, blue: 1.0), Color(red: 0.55, green: 0.85, blue: 1.0)],
        label: "Save"
    )

    fileprivate var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - Animated Like Button

/// A premium like button. Liking squashes and stretches the icon, fires a
/// shockwave ring and two-tone sparks, and rolls the count up. Unliking
/// deflates it softly and rolls the count down.
///
/// The animation reacts to *any* change of `isLiked` — so a double-tap on
/// media (see `.likeOnDoubleTap`) also makes the button burst. When `count`
/// is provided, the button keeps it in sync (+1 on like, -1 on unlike).
public struct AnimatedLikeButton: View {
    @Binding var isLiked: Bool
    var count: Binding<Int>?
    var style: AnimatedLikeStyle
    var size: CGFloat

    @State private var pulse = 0
    @State private var burst: AnimatedLikeBurstModel?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        isLiked: Binding<Bool>,
        count: Binding<Int>? = nil,
        style: AnimatedLikeStyle = .heart,
        size: CGFloat = 26
    ) {
        _isLiked = isLiked
        self.count = count
        self.style = style
        self.size = size
    }

    public var body: some View {
        Button { isLiked.toggle() } label: {
            HStack(spacing: size * 0.28) {
                icon
                if let count {
                    Text(count.wrappedValue.formatted(.number.notation(.compactName)))
                        .font(.system(size: size * 0.58, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundStyle(isLiked ? AnyShapeStyle(style.colors.last ?? .accentColor) : AnyShapeStyle(.secondary))
                        .contentTransition(.numericText(value: Double(count.wrappedValue)))
                        .animation(.snappy(duration: 0.35), value: count.wrappedValue)
                }
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(AnimatedLikePressStyle())
        .onChange(of: isLiked) { _, liked in
            count?.wrappedValue += liked ? 1 : -1
            pulse += 1
            if liked && !reduceMotion { fireBurst() }
        }
        .sensoryFeedback(trigger: isLiked) { _, liked in
            liked ? .impact(weight: .medium, intensity: 0.9) : .impact(flexibility: .soft, intensity: 0.45)
        }
        .accessibilityLabel(style.label)
        .accessibilityValue(count.map { "\($0.wrappedValue)" } ?? "")
        .accessibilityAddTraits(isLiked ? .isSelected : [])
    }

    // MARK: Icon

    private var icon: some View {
        ZStack {
            Image(systemName: style.symbol)
                .foregroundStyle(.secondary)
                .opacity(isLiked ? 0 : 1)
            Image(systemName: style.filledSymbol)
                .foregroundStyle(style.gradient)
                .opacity(isLiked ? 1 : 0)
        }
        .font(.system(size: size, weight: .semibold))
        .keyframeAnimator(initialValue: AnimatedLikeIconPose(), trigger: pulse) { content, pose in
            content
                .scaleEffect(x: pose.scaleX, y: pose.scaleY, anchor: .bottom)
                .rotationEffect(.degrees(pose.rotation))
                .offset(y: pose.lift)
        } keyframes: { _ in
            iconKeyframes(reduceMotion ? .still : (isLiked ? .like : .unlike))
        }
        .frame(width: size * 1.25, height: size * 1.25)
        .background {
            if let burst {
                AnimatedLikeBurstView(model: burst, radius: size * 1.05, ringColors: style.colors)
                    .frame(width: size * 4.5, height: size * 4.5)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .zIndex(1)
    }

    private enum Motion { case like, unlike, still }

    /// Like: anticipation squeeze -> wide squash -> tall stretch -> bouncy settle, with a tilt and hop.
    /// Unlike: a soft deflate that sinks, shrinks and eases back without overshoot.
    @KeyframesBuilder<AnimatedLikeIconPose>
    private func iconKeyframes(_ motion: Motion) -> some Keyframes<AnimatedLikeIconPose> {
        KeyframeTrack(\.scaleX) {
            switch motion {
            case .like:
                CubicKeyframe(0.7, duration: 0.08)
                CubicKeyframe(1.3, duration: 0.1)
                CubicKeyframe(0.86, duration: 0.1)
                SpringKeyframe(1, duration: 0.45, spring: Spring(response: 0.35, dampingRatio: 0.45))
            case .unlike:
                CubicKeyframe(1.08, duration: 0.06)
                CubicKeyframe(0.74, duration: 0.14)
                SpringKeyframe(1, duration: 0.4, spring: Spring(response: 0.4, dampingRatio: 0.85))
            case .still:
                LinearKeyframe(1, duration: 0.01)
            }
        }
        KeyframeTrack(\.scaleY) {
            switch motion {
            case .like:
                CubicKeyframe(0.7, duration: 0.08)
                CubicKeyframe(0.78, duration: 0.1)
                CubicKeyframe(1.3, duration: 0.1)
                SpringKeyframe(1, duration: 0.45, spring: Spring(response: 0.35, dampingRatio: 0.45))
            case .unlike:
                CubicKeyframe(0.92, duration: 0.06)
                CubicKeyframe(0.7, duration: 0.14)
                SpringKeyframe(1, duration: 0.4, spring: Spring(response: 0.4, dampingRatio: 0.85))
            case .still:
                LinearKeyframe(1, duration: 0.01)
            }
        }
        KeyframeTrack(\.rotation) {
            if motion == .like {
                LinearKeyframe(0, duration: 0.1)
                CubicKeyframe(-14, duration: 0.14)
                SpringKeyframe(0, duration: 0.5, spring: Spring(response: 0.4, dampingRatio: 0.4))
            } else {
                LinearKeyframe(0, duration: 0.01)
            }
        }
        KeyframeTrack(\.lift) {
            if motion == .like {
                LinearKeyframe(0, duration: 0.16)
                CubicKeyframe(-size * 0.28, duration: 0.12)
                SpringKeyframe(0, duration: 0.4, spring: Spring(response: 0.3, dampingRatio: 0.55))
            } else {
                LinearKeyframe(0, duration: 0.01)
            }
        }
    }

    // MARK: Burst

    private func fireBurst() {
        let model = AnimatedLikeBurstModel(palette: style.sparks)
        burst = model
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(AnimatedLikeBurstModel.duration + 0.05))
            if burst?.id == model.id { burst = nil }
        }
    }
}

// MARK: - Double Tap To Like

public extension View {
    /// Double-tap anywhere on this view to like it: a big glossy icon pops at
    /// the finger, throws sparks, then floats away. Double-tapping something
    /// already liked pops the icon again but never unlikes (like Instagram).
    func likeOnDoubleTap(_ isLiked: Binding<Bool>, style: AnimatedLikeStyle = .heart, iconSize: CGFloat = 96) -> some View {
        modifier(AnimatedLikeDoubleTapModifier(isLiked: isLiked, style: style, iconSize: iconSize))
    }
}

private struct AnimatedLikeDoubleTapModifier: ViewModifier {
    @Binding var isLiked: Bool
    let style: AnimatedLikeStyle
    let iconSize: CGFloat

    @State private var pops: [AnimatedLikePop] = []
    @State private var echoes = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack {
                    ForEach(pops) { pop in
                        AnimatedLikePopView(pop: pop, style: style, iconSize: iconSize, reduceMotion: reduceMotion)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
            .onTapGesture(count: 2, coordinateSpace: .local) { location in
                pop(at: location)
            }
            .sensoryFeedback(.impact(weight: .light, intensity: 0.7), trigger: echoes)
            .accessibilityAction(named: Text(style.label)) { isLiked = true }
    }

    private func pop(at location: CGPoint) {
        let pop = AnimatedLikePop(location: location, tilt: .random(in: -18...18), burst: .init(palette: style.sparks))
        pops.append(pop)
        if pops.count > 4 { pops.removeFirst() }
        if isLiked { echoes += 1 } else { isLiked = true }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(AnimatedLikePop.timeline.duration + 0.05))
            pops.removeAll { $0.id == pop.id }
        }
    }
}

private struct AnimatedLikePop: Identifiable {
    let id = UUID()
    let location: CGPoint
    let tilt: Double
    let burst: AnimatedLikeBurstModel
    var start: Date { burst.start }

    struct Pose {
        var scale: CGFloat = 0
        var rise: CGFloat = 0
        var opacity: Double = 0
        var tiltFactor: Double = 1
    }

    static let timeline = KeyframeTimeline(initialValue: Pose()) {
        KeyframeTrack(\.scale) {
            CubicKeyframe(1.22, duration: 0.16)
            SpringKeyframe(0.94, duration: 0.14, spring: .init(response: 0.2, dampingRatio: 0.6))
            SpringKeyframe(1.0, duration: 0.42, spring: .init(response: 0.3, dampingRatio: 0.6))
            CubicKeyframe(0.55, duration: 0.3)
        }
        KeyframeTrack(\.rise) {
            LinearKeyframe(0, duration: 0.68)
            CubicKeyframe(-140, duration: 0.34)
        }
        KeyframeTrack(\.opacity) {
            LinearKeyframe(1, duration: 0.06)
            LinearKeyframe(1, duration: 0.66)
            CubicKeyframe(0, duration: 0.3)
        }
        KeyframeTrack(\.tiltFactor) {
            SpringKeyframe(0, duration: 0.6, spring: .init(response: 0.45, dampingRatio: 0.5))
        }
    }
}

private struct AnimatedLikePopView: View {
    let pop: AnimatedLikePop
    let style: AnimatedLikeStyle
    let iconSize: CGFloat
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            if !reduceMotion {
                AnimatedLikeBurstView(model: pop.burst, radius: iconSize * 0.75, ringColors: [.white, .white])
                    .frame(width: iconSize * 3.4, height: iconSize * 3.4)
            }
            TimelineView(.animation) { context in
                let elapsed = context.date.timeIntervalSince(pop.start)
                let pose = AnimatedLikePop.timeline.value(time: min(elapsed, AnimatedLikePop.timeline.duration))
                Image(systemName: style.filledSymbol)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(style.gradient)
                    .overlay {
                        // Glossy highlight on the upper half.
                        Image(systemName: style.filledSymbol)
                            .font(.system(size: iconSize, weight: .semibold))
                            .foregroundStyle(LinearGradient(colors: [.white.opacity(0.55), .white.opacity(0)], startPoint: .top, endPoint: .center))
                    }
                    .shadow(color: (style.colors.last ?? .black).opacity(0.45), radius: 18, y: 8)
                    .shadow(color: .black.opacity(0.18), radius: 3, y: 2)
                    .scaleEffect(reduceMotion ? 1 : pose.scale)
                    .rotationEffect(.degrees(reduceMotion ? 0 : pop.tilt * pose.tiltFactor))
                    .offset(y: reduceMotion ? 0 : pose.rise)
                    .opacity(pose.opacity)
            }
        }
        .position(pop.location)
    }
}

// MARK: - Burst Engine (ring + sparks)

/// One burst: a seeded set of sparks plus its start time. Rendering is a pure
/// function of elapsed time, so a single Canvas draws the whole effect.
private struct AnimatedLikeBurstModel: Identifiable {
    static let duration: TimeInterval = 0.85

    struct Spark {
        var angle: Double
        var reach: CGFloat
        var size: CGFloat
        var color: Color
    }

    let id = UUID()
    let start = Date()
    let sparks: [Spark]

    init(palette: [Color]) {
        // Seven directions, each with a big and a small dot in different colors.
        let groups = 7
        let offset = Double.random(in: 0..<(2 * .pi))
        var sparks: [Spark] = []
        for index in 0..<groups {
            let angle = offset + Double(index) / Double(groups) * 2 * .pi
            let colorA = palette[index % palette.count]
            let colorB = palette[(index + 2) % palette.count]
            sparks.append(Spark(angle: angle - 0.16, reach: .random(in: 0.95...1.1), size: .random(in: 0.15...0.19), color: colorA))
            sparks.append(Spark(angle: angle + 0.2, reach: .random(in: 0.7...0.85), size: .random(in: 0.09...0.12), color: colorB))
        }
        self.sparks = sparks
    }
}

private struct AnimatedLikeBurstView: View {
    let model: AnimatedLikeBurstModel
    /// Radius of the shockwave ring at its widest, in points.
    let radius: CGFloat
    let ringColors: [Color]

    var body: some View {
        TimelineView(.animation) { context in
            let t = min(max(context.date.timeIntervalSince(model.start) / AnimatedLikeBurstModel.duration, 0), 1)
            Canvas { canvas, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                drawRing(in: &canvas, center: center, t: t)
                drawSparks(in: &canvas, center: center, t: t)
            }
        }
    }

    private func easeOut(_ x: Double) -> Double { 1 - pow(1 - x, 3) }

    private func drawRing(in canvas: inout GraphicsContext, center: CGPoint, t: Double) {
        let p = min(t / 0.42, 1)
        guard p < 1 else { return }
        let width = radius * 0.62 * (1 - p)
        let r = radius * (0.3 + 0.7 * easeOut(p))
        let inner = max(r - width / 2, 0.1)
        let rect = CGRect(x: center.x - inner, y: center.y - inner, width: inner * 2, height: inner * 2)
        let shading = GraphicsContext.Shading.linearGradient(
            Gradient(colors: ringColors),
            startPoint: CGPoint(x: rect.minX, y: rect.minY),
            endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        canvas.opacity = 0.35 + 0.65 * (1 - p)
        canvas.stroke(Path(ellipseIn: rect), with: shading, lineWidth: width)
        canvas.opacity = 1
    }

    private func drawSparks(in canvas: inout GraphicsContext, center: CGPoint, t: Double) {
        let p = min(max((t - 0.12) / 0.88, 0), 1)
        guard p > 0, p < 1 else { return }
        let travel = easeOut(p)
        // Grow in quickly, then shrink to nothing as they fly.
        let scale = min(p / 0.15, 1) * pow(1 - p, 0.9)
        for spark in model.sparks {
            let distance = radius * (0.7 + 0.75 * spark.reach * travel)
            let point = CGPoint(x: center.x + CGFloat(cos(spark.angle)) * distance, y: center.y + CGFloat(sin(spark.angle)) * distance)
            let d = radius * spark.size * 2 * scale
            guard d > 0.2 else { continue }
            canvas.fill(Path(ellipseIn: CGRect(x: point.x - d / 2, y: point.y - d / 2, width: d, height: d)), with: .color(spark.color))
        }
    }
}

// MARK: - Helpers

private struct AnimatedLikeIconPose {
    var scaleX: CGFloat = 1
    var scaleY: CGFloat = 1
    var rotation: Double = 0
    var lift: CGFloat = 0
}

private struct AnimatedLikePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

private struct AnimatedLikeButtonPreview: View {
    @State private var liked = false
    @State private var likes = 1_248
    @State private var starred = false
    @State private var saved = true

    var body: some View {
        VStack(spacing: 28) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient(colors: [.orange, .pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 300)
                .overlay {
                    Text("Double-tap me")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .likeOnDoubleTap($liked)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            HStack(spacing: 28) {
                AnimatedLikeButton(isLiked: $liked, count: $likes, size: 30)
                AnimatedLikeButton(isLiked: $starred, style: .star, size: 30)
                AnimatedLikeButton(isLiked: $saved, style: .bookmark, size: 30)
            }
        }
        .padding(24)
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        AnimatedLikeButtonPreview()
    }
}
