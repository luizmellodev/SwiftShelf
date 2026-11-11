import SwiftUI

// MARK: - Dot Grid Spotlight

/// Appearance of a dot grid spotlight background.
public struct DotGridSpotlightStyle {
    /// Distance between dots, in points.
    public var spacing: CGFloat
    /// Resting radius of each dot.
    public var dotRadius: CGFloat
    /// Reach of the finger spotlight.
    public var spotlightRadius: CGFloat
    /// How much a dot right under the finger grows.
    public var maxScale: CGFloat
    /// Glow color at the edge of the spotlight.
    public var tint: Color
    /// Glow color at the center of the spotlight.
    public var coreTint: Color
    /// Strength of the idle diagonal "breathing" wave (0 disables it).
    public var waveAmplitude: CGFloat
    /// Resting dot color. `nil` adapts to light / dark mode.
    public var dotColor: Color?

    public init(
        spacing: CGFloat = 20,
        dotRadius: CGFloat = 1.25,
        spotlightRadius: CGFloat = 130,
        maxScale: CGFloat = 3.4,
        tint: Color = .indigo,
        coreTint: Color = .cyan,
        waveAmplitude: CGFloat = 0.55,
        dotColor: Color? = nil
    ) {
        self.spacing = spacing
        self.dotRadius = dotRadius
        self.spotlightRadius = spotlightRadius
        self.maxScale = maxScale
        self.tint = tint
        self.coreTint = coreTint
        self.waveAmplitude = waveAmplitude
        self.dotColor = dotColor
    }
}

public extension View {
    /// Puts an interactive dot grid behind the view. Dots near the finger grow,
    /// get pushed aside and glow; an idle wave keeps the grid gently breathing.
    /// Touches are observed simultaneously, so buttons and scroll views keep working.
    func dotGridSpotlightBackground(
        _ style: DotGridSpotlightStyle = .init(),
        ignoresSafeArea: Bool = true
    ) -> some View {
        modifier(DotGridSpotlightModifier(style: style, ignoresSafeArea: ignoresSafeArea))
    }
}

/// Standalone dot grid surface (fills the space it's given).
public struct DotGridSpotlight: View {
    var style: DotGridSpotlightStyle

    public init(_ style: DotGridSpotlightStyle = .init()) {
        self.style = style
    }

    public var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .dotGridSpotlightBackground(style, ignoresSafeArea: false)
    }
}

// MARK: - Touch Tracking

/// Finger state, in global coordinates.
private struct DotGridSpotlightTouch: Equatable {
    var location: CGPoint
    var began: Date
    var ended: Date?
}

private struct DotGridSpotlightModifier: ViewModifier {
    var style: DotGridSpotlightStyle
    var ignoresSafeArea: Bool

    @State private var touch: DotGridSpotlightTouch?
    @State private var isTouching = false

    func body(content: Content) -> some View {
        content
            .background {
                DotGridSpotlightCanvas(style: style, touch: touch)
                    .contentShape(Rectangle()) // empty areas still catch the finger
                    .ignoresSafeArea(edges: ignoresSafeArea ? .all : [])
                    .accessibilityHidden(true)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in
                        if var current = touch, current.ended == nil {
                            current.location = value.location
                            touch = current
                        } else {
                            touch = DotGridSpotlightTouch(location: value.location, began: .now)
                            isTouching = true
                        }
                    }
                    .onEnded { value in
                        touch?.location = value.location
                        touch?.ended = .now
                        isTouching = false
                    }
            )
            .sensoryFeedback(.impact(weight: .light, intensity: 0.55), trigger: isTouching) { _, new in new }
    }
}

// MARK: - Canvas

private struct DotGridSpotlightCanvas: View {
    var style: DotGridSpotlightStyle
    var touch: DotGridSpotlightTouch?

    @State private var origin: CGPoint = .zero
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let fadeIn: Double = 0.22
    private let fadeOut: Double = 0.7

    var body: some View {
        TimelineView(.animation(paused: reduceMotion && touch == nil)) { timeline in
            let now = timeline.date
            Canvas { ctx, size in
                draw(in: &ctx, size: size, now: now)
            }
        }
        .onGeometryChange(for: CGPoint.self) { $0.frame(in: .global).origin } action: { origin = $0 }
    }

    /// 0...1 strength of the spotlight, eased in on touch and out on release.
    private func intensity(at now: Date) -> CGFloat {
        guard let touch else { return 0 }
        let rise = min(max(now.timeIntervalSince(touch.began) / fadeIn, 0), 1)
        var value = 1 - pow(1 - rise, 3)
        if let ended = touch.ended {
            let fall = min(max(now.timeIntervalSince(ended) / fadeOut, 0), 1)
            value *= pow(1 - fall, 2)
        }
        return CGFloat(value)
    }

    private func draw(in ctx: inout GraphicsContext, size: CGSize, now: Date) {
        let isDark = colorScheme == .dark
        let time = reduceMotion ? 0 : now.timeIntervalSinceReferenceDate
        let strength = intensity(at: now)
        let finger = touch.map { CGPoint(x: $0.location.x - origin.x, y: $0.location.y - origin.y) }
        let reach = style.spotlightRadius
        let baseColor = style.dotColor ?? (isDark ? Color.white.opacity(0.2) : Color.black.opacity(0.17))

        // Soft halo under the finger.
        if strength > 0.01, let finger {
            let r = reach * 1.5
            var halo = ctx
            if isDark { halo.blendMode = .plusLighter }
            halo.fill(
                Path(ellipseIn: CGRect(x: finger.x - r, y: finger.y - r, width: r * 2, height: r * 2)),
                with: .radialGradient(
                    Gradient(colors: [style.coreTint.opacity((isDark ? 0.22 : 0.14) * strength),
                                      style.tint.opacity((isDark ? 0.1 : 0.06) * strength),
                                      .clear]),
                    center: finger, startRadius: 0, endRadius: r
                )
            )
        }

        let spacing = max(style.spacing, 4)
        let columns = Int(size.width / spacing) + 2
        let rows = Int(size.height / spacing) + 2
        let offsetX = (size.width - CGFloat(columns - 1) * spacing) / 2
        let offsetY = (size.height - CGFloat(rows - 1) * spacing) / 2

        var resting = Path()
        var lit: [(center: CGPoint, radius: CGFloat, amount: CGFloat)] = []
        lit.reserveCapacity(160)

        for row in 0..<rows {
            let y = offsetY + CGFloat(row) * spacing
            for column in 0..<columns {
                let x = offsetX + CGFloat(column) * spacing

                // Idle wave: a diagonal band that slowly sweeps across the grid.
                let wave = 0.5 + 0.5 * sin(time * 1.4 - Double(x * 0.014 + y * 0.009))
                var radius = style.dotRadius * (1 + style.waveAmplitude * CGFloat(pow(wave, 6)))

                var amount: CGFloat = 0
                var center = CGPoint(x: x, y: y)
                if strength > 0.01, let finger {
                    let dx = x - finger.x, dy = y - finger.y
                    let distance = sqrt(dx * dx + dy * dy)
                    if distance < reach {
                        let falloff = 1 - distance / reach
                        amount = falloff * falloff * (3 - 2 * falloff) * strength // smoothstep
                        // Push dots slightly away from the finger for a "lens" feel.
                        let push = amount * spacing * 0.35
                        if distance > 0.5 {
                            center.x += dx / distance * push
                            center.y += dy / distance * push
                        }
                        radius *= 1 + (style.maxScale - 1) * amount
                    }
                }

                if amount > 0.02 {
                    lit.append((center, radius, amount))
                } else {
                    resting.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius,
                                                  width: radius * 2, height: radius * 2))
                }
            }
        }

        ctx.fill(resting, with: .color(baseColor))
        guard !lit.isEmpty else { return }

        // Glow pass: blurred, additive in dark mode.
        ctx.drawLayer { layer in
            layer.addFilter(.blur(radius: 5))
            if isDark { layer.blendMode = .plusLighter }
            for dot in lit {
                let r = dot.radius * 2.2
                layer.fill(Path(ellipseIn: CGRect(x: dot.center.x - r, y: dot.center.y - r, width: r * 2, height: r * 2)),
                           with: .color(style.tint.mix(with: style.coreTint, by: Double(dot.amount)).opacity(Double(dot.amount) * 0.75)))
            }
        }

        // Crisp dots on top.
        for dot in lit {
            let r = dot.radius
            let color = style.tint.mix(with: style.coreTint, by: Double(dot.amount))
            ctx.fill(Path(ellipseIn: CGRect(x: dot.center.x - r, y: dot.center.y - r, width: r * 2, height: r * 2)),
                     with: .color(baseColor.mix(with: color, by: Double(min(dot.amount * 1.6, 1)))))
        }
    }
}

// MARK: - Preview

#Preview("Dot Grid Spotlight") {
    VStack(spacing: 14) {
        Spacer()
        Image(systemName: "hand.point.up.left.fill")
            .font(.system(size: 34))
            .foregroundStyle(.indigo.gradient)
        Text("Touch the grid")
            .font(.system(size: 34, weight: .bold, design: .rounded))
        Text("Dots swell and glow under your finger.")
            .foregroundStyle(.secondary)
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .dotGridSpotlightBackground()
}
