import SwiftUI

// MARK: - Orbit Ring Model

/// One orbit: a radius, a speed and the items riding on it.
public struct OrbitingIconsRing<Item: Identifiable> {
    public var radius: CGFloat
    /// Seconds per full revolution.
    public var period: Double
    public var clockwise: Bool
    /// Rotation offset of the first item.
    public var phase: Angle
    public var items: [Item]

    public init(radius: CGFloat, period: Double = 20, clockwise: Bool = true, phase: Angle = .zero, items: [Item]) {
        self.radius = radius
        self.period = period
        self.clockwise = clockwise
        self.phase = phase
        self.items = items
    }
}

// MARK: - Orbiting Icons

/// Concentric orbits of icons / avatars circling a center view.
/// Items stay upright, rings rotate at their own speed and direction, and
/// tapping the center sends a shock-wave pulse that kicks the orbits outward
/// and spins them up for a moment.
///
/// Set `tilt` to lay the orbits down in perspective: items passing behind the
/// center shrink, dim and slide underneath it.
public struct OrbitingIcons<Item: Identifiable, ItemContent: View, Center: View>: View {
    var rings: [OrbitingIconsRing<Item>]
    var tilt: Angle
    var ringColor: Color
    var pulseColor: Color
    var itemContent: (Item) -> ItemContent
    var center: Center

    @State private var pulseDate: Date?
    @State private var pulseCount = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        rings: [OrbitingIconsRing<Item>],
        tilt: Angle = .zero,
        ringColor: Color = .primary,
        pulseColor: Color = .accentColor,
        @ViewBuilder item: @escaping (Item) -> ItemContent,
        @ViewBuilder center: () -> Center
    ) {
        self.rings = rings
        self.tilt = tilt
        self.ringColor = ringColor
        self.pulseColor = pulseColor
        self.itemContent = item
        self.center = center()
    }

    private var maxRadius: CGFloat { rings.map(\.radius).max() ?? 0 }
    private var squash: CGFloat { CGFloat(cos(tilt.radians)) }

    public var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 1.0 / 15 : nil)) { timeline in
            let now = timeline.date
            let time = now.timeIntervalSinceReferenceDate * (reduceMotion ? 0.25 : 1)
            let elapsed = pulseDate.map { now.timeIntervalSince($0) } ?? .infinity

            // Pulse envelopes: a damped outward kick and a decaying spin boost.
            let kick = elapsed < 2 ? CGFloat(exp(-4.2 * elapsed) * sin(elapsed * 11)) : 0
            let boost = elapsed.isFinite ? (1 - exp(-3 * elapsed)) * .pi * 0.6 : 0

            ZStack {
                orbitTracks
                shockwave(elapsed: elapsed)

                ForEach(rings.indices, id: \.self) { ringIndex in
                    let ring = rings[ringIndex]
                    let count = max(ring.items.count, 1)
                    ForEach(Array(ring.items.enumerated()), id: \.element.id) { itemIndex, item in
                        let direction: Double = ring.clockwise ? 1 : -1
                        let angle = ring.phase.radians
                            + Double(itemIndex) / Double(count) * 2 * .pi
                            + direction * (time / ring.period * 2 * .pi + boost)
                        let radius = ring.radius * (1 + kick * 0.14)
                        let depth = sin(angle) // -1 = behind, 1 = in front (when tilted)
                        let depthScale = 1 + CGFloat(depth) * (1 - squash) * 0.25

                        itemContent(item)
                            .scaleEffect(depthScale)
                            .brightness(squash < 0.999 ? Double(depth - 1) * 0.08 * Double(1 - squash) * 4 : 0)
                            .offset(x: CGFloat(cos(angle)) * radius,
                                    y: CGFloat(sin(angle)) * radius * squash)
                            .zIndex(depth)
                    }
                }

                Button {
                    pulseDate = .now
                    pulseCount += 1
                } label: {
                    center
                        .keyframeAnimator(initialValue: CGFloat(1), trigger: pulseCount) { view, scale in
                            view.scaleEffect(scale)
                        } keyframes: { _ in
                            SpringKeyframe(0.82, duration: 0.12, spring: .snappy)
                            SpringKeyframe(1.12, duration: 0.22, spring: .bouncy)
                            SpringKeyframe(1, duration: 0.5, spring: .bouncy(extraBounce: 0.15))
                        }
                }
                .buttonStyle(OrbitingIconsCenterStyle())
                .zIndex(0)
            }
            .frame(width: maxRadius * 2 + 80, height: maxRadius * 2 * squash + 80)
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: pulseCount)
    }

    // MARK: Decorations

    private var orbitTracks: some View {
        ZStack {
            ForEach(rings.indices, id: \.self) { index in
                let r = rings[index].radius
                Ellipse()
                    .stroke(
                        LinearGradient(colors: [ringColor.opacity(0.16), ringColor.opacity(0.04), ringColor.opacity(0.16)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 1, dash: index.isMultiple(of: 2) ? [] : [3, 5])
                    )
                    .frame(width: r * 2, height: r * 2 * squash)
            }
        }
        .zIndex(-2)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func shockwave(elapsed: Double) -> some View {
        if elapsed < 1.2 {
            let progress = elapsed / 1.2
            let eased = 1 - pow(1 - progress, 3)
            let r = 30 + (maxRadius + 30) * CGFloat(eased)
            ZStack {
                Ellipse()
                    .stroke(pulseColor.opacity(0.7 * (1 - progress)), lineWidth: 2 + 6 * CGFloat(1 - progress))
                    .blur(radius: 2)
                Ellipse()
                    .fill(RadialGradient(colors: [.clear, pulseColor.opacity(0.18 * (1 - progress))],
                                         center: .center, startRadius: 0, endRadius: r))
            }
            .frame(width: r * 2, height: r * 2 * squash)
            .zIndex(-1)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

// MARK: - Center Button Style

private struct OrbitingIconsCenterStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview

private struct OrbitingIconsPreviewApp: Identifiable {
    let id: String
    let color: Color
}

#Preview("Orbiting Icons") {
    let apps = ["swift", "paintpalette.fill", "bolt.fill", "cloud.fill", "camera.fill", "music.note",
                "heart.fill", "map.fill", "gamecontroller.fill"]
    let colors: [Color] = [.orange, .pink, .yellow, .blue, .purple, .red, .mint, .green, .indigo]
    let items = zip(apps, colors).map { OrbitingIconsPreviewApp(id: $0, color: $1) }

    OrbitingIcons(
        rings: [
            .init(radius: 80, period: 12, items: Array(items[0..<3])),
            .init(radius: 145, period: 22, clockwise: false, phase: .degrees(30), items: Array(items[3..<9])),
        ],
        pulseColor: .orange
    ) { app in
        Image(systemName: app.id)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(app.color.gradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: app.color.opacity(0.4), radius: 8, y: 4)
    } center: {
        Image(systemName: "swift")
            .font(.system(size: 34, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 84, height: 84)
            .background(.orange.gradient, in: Circle())
            .shadow(color: .orange.opacity(0.5), radius: 20, y: 8)
    }
}
