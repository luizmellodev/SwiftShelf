import SwiftUI

// MARK: - Flip Clock Display

/// A split-flap display. Digits become flip cards and `:` becomes a colon.
///
/// Every card is a real split-flap: the upper half of the old glyph falls
/// forward around the hinge (rotation3DEffect), then the lower half of the
/// new glyph lands with a little bounce — with shading cast on the halves
/// underneath while the flap is in the air.
public struct FlipClockDisplay: View {
    let text: String
    var cardSize: CGSize
    var spacing: CGFloat
    var haptics: Bool

    public init(_ text: String, cardSize: CGSize = CGSize(width: 64, height: 92), spacing: CGFloat = 6, haptics: Bool = false) {
        self.text = text
        self.cardSize = cardSize
        self.spacing = spacing
        self.haptics = haptics
    }

    private var glyphs: [(id: Int, char: String)] {
        Array(text).enumerated().map { ($0.offset, String($0.element)) }
    }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(glyphs, id: \.id) { glyph in
                if glyph.char == ":" {
                    FlipClockColon(height: cardSize.height)
                } else {
                    FlipClockCard(glyph.char, size: cardSize)
                }
            }
        }
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.45), trigger: text) { _, _ in haptics }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }
}

// MARK: - Flip Card

/// A single split-flap card. Change `value` and it flips.
public struct FlipClockCard: View {
    let value: String
    var size: CGSize

    @State private var previous: String
    @State private var current: String
    @State private var flips: Double = 0
    @State private var target = 0

    public init(_ value: String, size: CGSize = CGSize(width: 64, height: 92)) {
        self.value = value
        self.size = size
        _previous = State(initialValue: value)
        _current = State(initialValue: value)
    }

    public var body: some View {
        FlipClockFlap(previous: previous, current: current, flips: flips, target: target, size: size)
            .onChange(of: value) { _, newValue in
                guard newValue != current else { return }
                previous = current
                current = newValue
                target += 1
                // `flips` animates n-1 → n while `target` jumps to n instantly,
                // so the flap progress runs 0 → 1 in a single transaction.
                withAnimation(.spring(duration: 0.62, bounce: 0.22)) { flips = Double(target) }
            }
    }
}

/// The animatable core: everything is derived from `flips`.
private struct FlipClockFlap: View, Animatable {
    let previous: String
    let current: String
    var flips: Double
    let target: Int
    let size: CGSize

    var animatableData: Double {
        get { flips }
        set { flips = newValue }
    }

    /// 0 = old glyph showing, 1 = new glyph settled (slightly >1 on bounce).
    private var progress: Double { min(max(1 - (Double(target) - flips), 0), 1.04) }

    private let perspective: CGFloat = 0.45

    var body: some View {
        let p = progress
        let falling = p < 0.5
        let airborne = falling ? p * 2 : max(0, (1 - p) * 2)

        VStack(spacing: 1.5) {
            // Upper half: new glyph underneath, old glyph falling on top.
            ZStack {
                half(current, top: true)
                    .overlay(Color.black.opacity(falling ? 0.45 * (1 - p * 2) : 0))
                if falling {
                    half(previous, top: true)
                        .overlay(Color.black.opacity(0.35 * p * 2))
                        .rotation3DEffect(.degrees(-180 * p), axis: (1, 0, 0), anchor: .bottom, perspective: perspective)
                }
            }
            .zIndex(falling ? 1 : 0)

            // Lower half: old glyph underneath, new glyph landing on top.
            ZStack {
                half(previous, top: false)
                    .overlay(Color.black.opacity(0.4 * airborne))
                if !falling {
                    half(current, top: false)
                        .overlay(Color.black.opacity(0.3 * airborne))
                        .shadow(color: .black.opacity(0.35 * airborne), radius: 6, y: 4)
                        .rotation3DEffect(.degrees(180 * (1 - p)), axis: (1, 0, 0), anchor: .top, perspective: perspective)
                }
            }
            .zIndex(falling ? 0 : 1)
        }
        .background(
            RoundedRectangle(cornerRadius: size.width * 0.16, style: .continuous)
                .fill(Color(white: 0.04))
        )
        .overlay {
            // Hinge pins
            HStack {
                Capsule().frame(width: 3, height: size.height * 0.12)
                Spacer()
                Capsule().frame(width: 3, height: size.height * 0.12)
            }
            .foregroundStyle(Color(white: 0.02))
            .padding(.horizontal, -1)
        }
        .shadow(color: .black.opacity(0.28), radius: 10, y: 8)
        .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
        .frame(width: size.width, height: size.height + 1.5)
    }

    private func half(_ text: String, top: Bool) -> some View {
        FlipClockFace(text: text, size: size)
            .frame(width: size.width, height: size.height / 2, alignment: top ? .top : .bottom)
            .clipped()
    }
}

private struct FlipClockFace: View {
    let text: String
    let size: CGSize

    var body: some View {
        RoundedRectangle(cornerRadius: size.width * 0.16, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color(white: 0.24), Color(white: 0.15), Color(white: 0.11)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: size.width * 0.16, style: .continuous)
                    .strokeBorder(.white.opacity(0.07), lineWidth: 1)
            }
            .overlay {
                Text(text)
                    .font(.system(size: size.height * 0.74, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(
                        LinearGradient(colors: [.white, Color(white: 0.82)], startPoint: .top, endPoint: .bottom)
                    )
                    .minimumScaleFactor(0.5)
            }
            .frame(width: size.width, height: size.height)
    }
}

private struct FlipClockColon: View {
    let height: CGFloat

    var body: some View {
        VStack(spacing: height * 0.22) {
            Circle().frame(width: height * 0.09)
            Circle().frame(width: height * 0.09)
        }
        .foregroundStyle(Color.primary.opacity(0.7))
        .frame(width: height * 0.16)
    }
}

// MARK: - Preview

#Preview("Flip Clock") {
    VStack(spacing: 40) {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            FlipClockDisplay(
                context.date.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits).second(.twoDigits)),
                cardSize: CGSize(width: 46, height: 68),
                spacing: 4
            )
        }

        FlipClockPreviewCountdown()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
}

private struct FlipClockPreviewCountdown: View {
    @State private var remaining = 600

    var body: some View {
        FlipClockDisplay(String(format: "%02d:%02d", remaining / 60, remaining % 60), haptics: true)
            .task {
                while remaining > 0 {
                    try? await Task.sleep(for: .seconds(1))
                    remaining -= 1
                }
            }
    }
}
