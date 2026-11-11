import SwiftUI

// MARK: - Star Rating

/// A scrub-to-rate control. Drag your finger across the row (or tap a star)
/// and each star pops, tilts and fills with a gradient as you pass it,
/// with half-star precision. Reaching the top rating sends a sparkle burst
/// out of the row while the stars hop in a wave.
public struct StarRatingControl: View {
    @Binding var rating: Double
    var maxRating: Int
    var allowsHalfStars: Bool
    var starSize: CGFloat
    var spacing: CGFloat
    var colors: [Color]

    @State private var bursts = 0
    @State private var isScrubbing = false

    public init(
        rating: Binding<Double>,
        maxRating: Int = 5,
        allowsHalfStars: Bool = true,
        starSize: CGFloat = 44,
        spacing: CGFloat = 10,
        colors: [Color] = [Color(red: 1.0, green: 0.85, blue: 0.25), Color(red: 1.0, green: 0.5, blue: 0.15)]
    ) {
        self._rating = rating
        self.maxRating = max(1, maxRating)
        self.allowsHalfStars = allowsHalfStars
        self.starSize = starSize
        self.spacing = spacing
        self.colors = colors.isEmpty ? [.yellow] : colors
    }

    private var rowWidth: CGFloat { CGFloat(maxRating) * starSize + CGFloat(maxRating - 1) * spacing }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<maxRating, id: \.self) { index in
                StarRatingCell(
                    fill: fill(for: index),
                    size: starSize,
                    colors: colors,
                    index: index,
                    celebration: bursts,
                    isLifted: isScrubbing && Int(ceil(rating)) - 1 == index
                )
            }
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    isScrubbing = true
                    update(for: value.location.x)
                }
                .onEnded { _ in isScrubbing = false }
        )
        .overlay {
            StarRatingBurst(trigger: bursts, colors: colors, spread: CGSize(width: rowWidth * 0.62, height: starSize * 1.6))
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isScrubbing)
        .onChange(of: rating) { old, new in
            if new >= Double(maxRating), old < Double(maxRating) { bursts += 1 }
        }
        .sensoryFeedback(.selection, trigger: rating)
        .sensoryFeedback(.success, trigger: bursts)
        .accessibilityElement()
        .accessibilityLabel("Rating")
        .accessibilityValue("\(rating.formatted()) of \(maxRating) stars")
        .accessibilityAdjustableAction { direction in
            let step = allowsHalfStars ? 0.5 : 1
            switch direction {
            case .increment: rating = min(rating + step, Double(maxRating))
            case .decrement: rating = max(rating - step, 0)
            @unknown default: break
            }
        }
    }

    // MARK: Logic

    private func fill(for index: Int) -> Double {
        min(max(rating - Double(index), 0), 1)
    }

    private func update(for x: CGFloat) {
        let pitch = starSize + spacing
        let index = min(max(Int(floor(x / pitch)), 0), maxRating - 1)
        let local = x - CGFloat(index) * pitch
        var value = Double(index) + 1
        if allowsHalfStars, local < starSize / 2 { value -= 0.5 }
        if x < 0 { value = allowsHalfStars ? 0.5 : 1 }
        if value != rating { rating = value }
    }
}

// MARK: - Star Cell

private struct StarRatingCell: View {
    let fill: Double
    let size: CGFloat
    let colors: [Color]
    let index: Int
    let celebration: Int
    let isLifted: Bool

    var body: some View {
        ZStack {
            star.foregroundStyle(Color(.systemFill))

            star
                .foregroundStyle(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay {
                    star
                        .foregroundStyle(LinearGradient(colors: [.white.opacity(0.55), .clear], startPoint: .top, endPoint: .center))
                        .blendMode(.plusLighter)
                }
                .mask(alignment: .leading) {
                    Rectangle().frame(width: size * fill)
                }
                .shadow(color: (colors.last ?? .orange).opacity(fill > 0 ? 0.45 : 0), radius: 8, y: 2)
                .animation(.spring(response: 0.28, dampingFraction: 0.75), value: fill)
        }
        .frame(width: size, height: size)
        .scaleEffect(isLifted ? 1.18 : 1)
        .offset(y: isLifted ? -4 : 0)
        // Pop + tilt whenever this star's fill changes.
        .keyframeAnimator(initialValue: StarRatingPop(), trigger: fill) { content, value in
            content
                .scaleEffect(value.scale)
                .rotationEffect(.degrees(value.angle))
        } keyframes: { _ in
            KeyframeTrack(\.scale) {
                SpringKeyframe(1.3, duration: 0.1, spring: .snappy)
                SpringKeyframe(1.0, duration: 0.4, spring: .bouncy)
            }
            KeyframeTrack(\.angle) {
                SpringKeyframe(-14, duration: 0.1)
                SpringKeyframe(0, duration: 0.45, spring: .bouncy)
            }
        }
        // Staggered hop wave on a perfect score.
        .keyframeAnimator(initialValue: CGFloat(0), trigger: celebration) { content, y in
            content.offset(y: y)
        } keyframes: { _ in
            KeyframeTrack {
                LinearKeyframe(0, duration: 0.05 + Double(index) * 0.06)
                SpringKeyframe(-16, duration: 0.14, spring: .snappy)
                SpringKeyframe(0, duration: 0.4, spring: .bouncy)
            }
        }
    }

    private var star: some View {
        Image(systemName: "star.fill")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

private struct StarRatingPop {
    var scale: CGFloat = 1
    var angle: Double = 0
}

// MARK: - Burst

/// Sparkles and dots that radiate out of the row and fade.
private struct StarRatingBurst: View {
    let trigger: Int
    let colors: [Color]
    let spread: CGSize

    private let count = 22

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { index in
                let angle = Double(index) / Double(count) * 2 * .pi + (index.isMultiple(of: 2) ? 0.12 : -0.08)
                let reach = index.isMultiple(of: 3) ? 1.0 : (index.isMultiple(of: 2) ? 0.78 : 0.6)
                piece(index)
                    .keyframeAnimator(initialValue: 0.0, trigger: trigger) { content, t in
                        content
                            .offset(x: cos(angle) * spread.width * reach * t,
                                    y: sin(angle) * spread.height * reach * t)
                            .scaleEffect(t <= 0 || t >= 1 ? 0.01 : 1.2 - t * 0.7)
                            .rotationEffect(.degrees(t * 180))
                            .opacity(t <= 0 || t >= 1 ? 0 : 1 - t * t)
                    } keyframes: { _ in
                        KeyframeTrack {
                            MoveKeyframe(0.001)
                            CubicKeyframe(0.75, duration: 0.45)
                            LinearKeyframe(0.999, duration: 0.35)
                            MoveKeyframe(1)
                        }
                    }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func piece(_ index: Int) -> some View {
        let color = colors[index % colors.count]
        if index.isMultiple(of: 3) {
            Image(systemName: "sparkle")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
        } else {
            Circle()
                .fill(index.isMultiple(of: 2) ? color : Color.pink.opacity(0.9))
                .frame(width: index.isMultiple(of: 2) ? 7 : 5, height: index.isMultiple(of: 2) ? 7 : 5)
        }
    }
}

// MARK: - Preview

private struct StarRatingPreview: View {
    @State private var rating = 3.5

    var body: some View {
        VStack(spacing: 18) {
            Text("How was your stay?").font(.title2.bold())
            StarRatingControl(rating: $rating)
            Text(rating.formatted() + " / 5")
                .font(.headline.monospacedDigit())
                .contentTransition(.numericText(value: rating))
                .animation(.snappy, value: rating)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview("Star Rating") {
    StarRatingPreview()
}
