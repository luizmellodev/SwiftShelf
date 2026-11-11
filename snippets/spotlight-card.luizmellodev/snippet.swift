import SwiftUI

// MARK: - Spotlight Card

/// A card that reacts to your finger: a soft spotlight follows the touch,
/// the border lights up nearest to it, and the card tilts in 3D toward
/// the press. Optional holographic foil for "membership pass" vibes.
public struct SpotlightCard<Content: View>: View {
    var cornerRadius: CGFloat
    var glowColor: Color
    var maxTilt: Double
    var holographic: Bool
    let content: Content

    @State private var location: CGPoint = .zero
    @State private var size: CGSize = .zero
    @State private var isTouching = false

    public init(
        cornerRadius: CGFloat = 28,
        glowColor: Color = .white,
        maxTilt: Double = 9,
        holographic: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.glowColor = glowColor
        self.maxTilt = maxTilt
        self.holographic = holographic
        self.content = content()
    }

    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: cornerRadius, style: .continuous) }

    private var unit: UnitPoint {
        guard size.width > 0, size.height > 0 else { return .center }
        return UnitPoint(x: location.x / size.width, y: location.y / size.height)
    }

    /// -1...1 offset of the touch from the center.
    private var normalized: CGPoint {
        guard isTouching else { return .zero }
        return CGPoint(x: (unit.x - 0.5) * 2, y: (unit.y - 0.5) * 2)
    }

    public var body: some View {
        content
            .overlay {
                if holographic {
                    LinearGradient(
                        colors: [.clear, .pink, .yellow, .mint, .cyan, .purple, .clear],
                        startPoint: UnitPoint(x: unit.x - 0.9, y: unit.y - 0.9),
                        endPoint: UnitPoint(x: unit.x + 0.9, y: unit.y + 0.9)
                    )
                    .blendMode(.overlay)
                    .opacity(isTouching ? 0.55 : 0.15)
                }
            }
            .overlay {
                RadialGradient(
                    colors: [glowColor.opacity(0.32), .clear],
                    center: unit,
                    startRadius: 0,
                    endRadius: max(size.width, size.height) * 0.6
                )
                .blendMode(.plusLighter)
                .opacity(isTouching ? 1 : 0)
            }
            .overlay {
                shape.strokeBorder(
                    RadialGradient(
                        colors: [glowColor.opacity(isTouching ? 0.95 : 0.35), glowColor.opacity(0.06)],
                        center: unit,
                        startRadius: 0,
                        endRadius: max(size.width, size.height) * 0.7
                    ),
                    lineWidth: 1.5
                )
            }
            .clipShape(shape)
            .allowsHitTesting(true)
            .onGeometryChange(for: CGSize.self) { $0.size } action: { newSize in
                size = newSize
                if !isTouching { location = CGPoint(x: newSize.width / 2, y: newSize.height * 0.2) }
            }
            .contentShape(shape)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        withAnimation(.interactiveSpring(response: 0.28, dampingFraction: 0.82)) {
                            location = CGPoint(x: min(max(value.location.x, 0), size.width),
                                               y: min(max(value.location.y, 0), size.height))
                            isTouching = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.55)) {
                            isTouching = false
                        }
                    }
            )
            .scaleEffect(isTouching ? 0.97 : 1)
            .rotation3DEffect(.degrees(Double(normalized.y) * maxTilt), axis: (x: 1, y: 0, z: 0), perspective: 0.5)
            .rotation3DEffect(.degrees(Double(-normalized.x) * maxTilt), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
            .shadow(color: .black.opacity(isTouching ? 0.32 : 0.2),
                    radius: isTouching ? 28 : 18,
                    x: normalized.x * 10,
                    y: 14 + normalized.y * 10)
            .sensoryFeedback(.impact(weight: .light), trigger: isTouching) { _, touching in touching }
    }
}

// MARK: - Aurora Background (iOS 18+)

/// A slowly drifting mesh gradient. Great as a card fill or hero background.
@available(iOS 18.0, *)
public struct AuroraBackground: View {
    var colors: [Color]
    var speed: Double

    public init(colors: [Color] = AuroraBackground.nebula, speed: Double = 1) {
        precondition(colors.count == 9, "AuroraBackground needs 9 colors (3×3 mesh).")
        self.colors = colors
        self.speed = speed
    }

    public static let nebula: [Color] = [
        Color(red: 0.15, green: 0.05, blue: 0.4), Color(red: 0.42, green: 0.12, blue: 0.7), Color(red: 0.1, green: 0.2, blue: 0.55),
        Color(red: 0.85, green: 0.25, blue: 0.6), Color(red: 0.55, green: 0.3, blue: 0.95), Color(red: 0.2, green: 0.55, blue: 0.95),
        Color(red: 1.0, green: 0.55, blue: 0.35), Color(red: 0.95, green: 0.35, blue: 0.5), Color(red: 0.3, green: 0.8, blue: 0.85),
    ]

    public var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate * speed
            let points: [SIMD2<Float>] = [
                [0, 0], [Float(0.5 + 0.2 * sin(t * 0.5)), 0], [1, 0],
                [0, Float(0.5 + 0.2 * sin(t * 0.9))],
                [Float(0.5 + 0.25 * sin(t * 0.7)), Float(0.5 + 0.22 * cos(t * 0.8))],
                [1, Float(0.5 + 0.2 * cos(t * 1.1))],
                [0, 1], [Float(0.5 + 0.3 * cos(t * 0.6)), 1], [1, 1],
            ]
            MeshGradient(width: 3, height: 3, points: points, colors: colors)
        }
    }
}

// MARK: - Preview

#Preview("Spotlight Card") {
    VStack(spacing: 28) {
        SpotlightCard(holographic: true) {
            ZStack(alignment: .bottomLeading) {
                AuroraBackground()
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("SHELF PASS")
                            .font(.caption.weight(.bold))
                            .tracking(2)
                        Spacer()
                        Image(systemName: "wave.3.right")
                    }
                    Spacer()
                    Text("Luiz Mello")
                        .font(.title2.bold())
                    Text("Member since 2026")
                        .font(.footnote)
                        .opacity(0.75)
                }
                .foregroundStyle(.white)
                .padding(22)
            }
            .frame(height: 210)
        }

        SpotlightCard(cornerRadius: 24, glowColor: .purple) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Pro")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$9").font(.system(size: 44, weight: .bold, design: .rounded))
                    Text("/month").font(.headline).foregroundStyle(.secondary)
                }
                Label("Unlimited components", systemImage: "checkmark.circle.fill")
                Label("Source code access", systemImage: "checkmark.circle.fill")
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
            .background(Color(.secondarySystemBackground))
        }
    }
    .padding(24)
}
