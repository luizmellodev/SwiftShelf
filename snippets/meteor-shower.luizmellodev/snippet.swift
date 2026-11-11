import SwiftUI

// MARK: - Meteor Shower

/// A night-sky background: angled shooting stars with glowing heads and
/// gradient tails streak across a softly twinkling star field.
///
/// Everything is drawn in a single `Canvas` and every meteor is a pure
/// function of time (seeded randomness), so there is no per-frame state.
public struct MeteorShower: View {
    var meteorCount: Int
    var starCount: Int
    var direction: Angle
    var flightDuration: ClosedRange<Double>
    var interval: ClosedRange<Double>
    var tailLength: ClosedRange<CGFloat>
    var color: Color?
    var glow: Color
    var seed: UInt64

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - meteorCount: Simultaneous meteor "lanes".
    ///   - starCount: Background stars (0 disables the star field).
    ///   - direction: Travel direction (0° = right, 90° = up). Default heads down-left.
    ///   - flightDuration: Seconds a meteor takes to cross its path.
    ///   - interval: Seconds between two meteors in the same lane.
    ///   - tailLength: Tail length range, in points.
    ///   - color: Meteor & star color. `nil` = white in dark mode, deep indigo in light mode.
    ///   - glow: Tint of the halo around each meteor head.
    public init(
        meteorCount: Int = 12,
        starCount: Int = 80,
        direction: Angle = .degrees(215),
        flightDuration: ClosedRange<Double> = 0.9...1.6,
        interval: ClosedRange<Double> = 2.2...5.5,
        tailLength: ClosedRange<CGFloat> = 70...170,
        color: Color? = nil,
        glow: Color = Color(red: 0.55, green: 0.7, blue: 1),
        seed: UInt64 = 7
    ) {
        self.meteorCount = meteorCount
        self.starCount = starCount
        self.direction = direction
        self.flightDuration = flightDuration
        self.interval = interval
        self.tailLength = tailLength
        self.color = color
        self.glow = glow
        self.seed = seed
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 1.0 / 8 : nil)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let ink = color ?? (colorScheme == .dark ? .white : Color(red: 0.18, green: 0.16, blue: 0.42))
                drawStars(in: &ctx, size: size, time: time, ink: ink)
                if !reduceMotion {
                    drawMeteors(in: &ctx, size: size, time: time, ink: ink)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    // MARK: Stars

    private func drawStars(in ctx: inout GraphicsContext, size: CGSize, time: Double, ink: Color) {
        guard starCount > 0 else { return }
        for index in 0..<starCount {
            let key = seed &* 1_000 &+ UInt64(index)
            let x = MeteorShowerRandom.unit(key, 1) * size.width
            let y = MeteorShowerRandom.unit(key, 2) * size.height
            let radius = 0.4 + MeteorShowerRandom.unit(key, 3) * 1.1
            let speed = 0.6 + MeteorShowerRandom.unit(key, 4) * 2.2
            let phase = MeteorShowerRandom.unit(key, 5) * .pi * 2
            let twinkle = 0.5 + 0.5 * sin(time * speed + phase)
            let base = 0.15 + MeteorShowerRandom.unit(key, 6) * 0.45
            let opacity = base * (0.35 + 0.65 * twinkle)

            let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
            ctx.fill(Path(ellipseIn: rect), with: .color(ink.opacity(opacity)))

            // A few bright stars get a tiny cross flare.
            if radius > 1.3 {
                let flare = radius * 3.5 * twinkle
                var cross = Path()
                cross.move(to: CGPoint(x: x - flare, y: y)); cross.addLine(to: CGPoint(x: x + flare, y: y))
                cross.move(to: CGPoint(x: x, y: y - flare)); cross.addLine(to: CGPoint(x: x, y: y + flare))
                ctx.stroke(cross, with: .color(ink.opacity(opacity * 0.5)), lineWidth: 0.5)
            }
        }
    }

    // MARK: Meteors

    private func drawMeteors(in ctx: inout GraphicsContext, size: CGSize, time: Double, ink: Color) {
        let radians = direction.radians
        let heading = CGVector(dx: cos(radians), dy: -sin(radians))
        let travel = (size.width + size.height) * 0.75
        let isDark = colorScheme == .dark

        for lane in 0..<meteorCount {
            let laneKey = seed &* 7_919 &+ UInt64(lane)
            let period = MeteorShowerRandom.lerp(interval, MeteorShowerRandom.unit(laneKey, 10))
            let shifted = time + MeteorShowerRandom.unit(laneKey, 11) * period
            let cycle = floor(shifted / period)
            let local = shifted - cycle * period

            let key = laneKey &* 31 &+ UInt64(Int64(cycle) & 0xFFFFFF)
            let duration = MeteorShowerRandom.lerp(flightDuration, MeteorShowerRandom.unit(key, 1))
            guard local < duration else { continue }
            let progress = local / duration

            // Midpoint of the flight, biased to the upper part of the canvas.
            let mid = CGPoint(
                x: (MeteorShowerRandom.unit(key, 2) * 1.2 - 0.1) * size.width,
                y: (MeteorShowerRandom.unit(key, 3) * 0.75 - 0.05) * size.height
            )
            let along = (progress - 0.5) * travel
            let head = CGPoint(x: mid.x + heading.dx * along, y: mid.y + heading.dy * along)

            // Tail grows in quickly, fades out near the end.
            let maxTail = MeteorShowerRandom.lerp(tailLength, MeteorShowerRandom.unit(key, 4))
            let tail = maxTail * min(progress * 4, 1)
            let end = CGPoint(x: head.x - heading.dx * tail, y: head.y - heading.dy * tail)
            let fade = min(progress * 6, 1) * pow(1 - progress, 0.6)
            let thickness = 0.8 + MeteorShowerRandom.unit(key, 5) * 1.2

            var streak = Path()
            streak.move(to: head)
            streak.addLine(to: end)
            let tailShading = GraphicsContext.Shading.linearGradient(
                Gradient(colors: [ink.opacity(0.95 * fade), glow.opacity(0.35 * fade), .clear]),
                startPoint: head, endPoint: end
            )

            // Glow pass (one blurred layer per meteor).
            let bloom = thickness * 5
            ctx.drawLayer { halo in
                if isDark { halo.blendMode = .plusLighter }
                halo.addFilter(.blur(radius: 3))
                halo.stroke(streak, with: .linearGradient(
                    Gradient(colors: [glow.opacity(0.8 * fade), .clear]), startPoint: head, endPoint: end
                ), style: StrokeStyle(lineWidth: thickness * 3.5, lineCap: .round))
                halo.fill(Path(ellipseIn: CGRect(x: head.x - bloom, y: head.y - bloom, width: bloom * 2, height: bloom * 2)),
                          with: .radialGradient(Gradient(colors: [glow.opacity(0.9 * fade), .clear]),
                                                center: head, startRadius: 0, endRadius: bloom))
            }

            // Crisp tail + head.
            ctx.stroke(streak, with: tailShading, style: StrokeStyle(lineWidth: thickness, lineCap: .round))
            let core = thickness * 0.9
            ctx.fill(Path(ellipseIn: CGRect(x: head.x - core, y: head.y - core, width: core * 2, height: core * 2)),
                     with: .color(ink.opacity(fade)))
        }
    }
}

// MARK: - Seeded Randomness

/// Deterministic hash-based randomness, so the sky never needs stored state.
private enum MeteorShowerRandom {
    static func unit(_ key: UInt64, _ salt: UInt64) -> Double {
        var z = key &+ salt &* 0x9E37_79B9_7F4A_7C15
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        z ^= z >> 31
        return Double(z >> 11) / Double(1 << 53)
    }

    static func lerp(_ range: ClosedRange<Double>, _ t: Double) -> Double {
        range.lowerBound + (range.upperBound - range.lowerBound) * t
    }

    static func lerp(_ range: ClosedRange<CGFloat>, _ t: Double) -> CGFloat {
        range.lowerBound + (range.upperBound - range.lowerBound) * CGFloat(t)
    }
}

// MARK: - Preview

#Preview("Meteor Shower") {
    ZStack {
        LinearGradient(colors: [Color(red: 0.02, green: 0.02, blue: 0.1), Color(red: 0.12, green: 0.06, blue: 0.3)],
                       startPoint: .top, endPoint: .bottom)
        MeteorShower(color: .white)
        VStack(spacing: 10) {
            Text("Make a wish")
                .font(.system(size: 44, weight: .bold, design: .rounded))
            Text("Perseids peak tonight at 2 AM")
                .foregroundStyle(.white.opacity(0.7))
        }
        .foregroundStyle(.white)
    }
    .ignoresSafeArea()
}
