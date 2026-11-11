import SwiftUI

// MARK: - Border Beam

/// Configuration for `.borderBeam(...)`.
public struct BorderBeamStyle {
    /// Colors from the beam's head to its tail.
    public var colors: [Color]
    /// Seconds per lap.
    public var duration: Double
    /// Beam length as a fraction of the perimeter (0...1).
    public var length: CGFloat
    public var lineWidth: CGFloat
    /// Blur radius of the bloom around the beam.
    public var glow: CGFloat
    /// Number of evenly spaced beams chasing each other.
    public var beamCount: Int
    public var reversed: Bool
    /// Start offset of the first beam, as a fraction of a lap.
    public var offset: Double
    /// Faint static border underneath the beam.
    public var showsTrack: Bool

    public init(
        colors: [Color] = [.cyan, .indigo, .purple, .pink],
        duration: Double = 5,
        length: CGFloat = 0.24,
        lineWidth: CGFloat = 1.5,
        glow: CGFloat = 7,
        beamCount: Int = 1,
        reversed: Bool = false,
        offset: Double = 0,
        showsTrack: Bool = true
    ) {
        self.colors = colors
        self.duration = duration
        self.length = length
        self.lineWidth = lineWidth
        self.glow = glow
        self.beamCount = beamCount
        self.reversed = reversed
        self.offset = offset
        self.showsTrack = showsTrack
    }
}

public extension View {
    /// Sends a glowing beam of light around the view's rounded-rect border.
    /// Use a large `cornerRadius` (e.g. `.infinity`) for capsules.
    func borderBeam(cornerRadius: CGFloat = 20, style: BorderBeamStyle = .init()) -> some View {
        overlay {
            BorderBeamOverlay(cornerRadius: cornerRadius, style: style)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }

    /// Convenience variant with the most common knobs.
    func borderBeam(
        cornerRadius: CGFloat = 20,
        colors: [Color],
        duration: Double = 5,
        length: CGFloat = 0.24,
        lineWidth: CGFloat = 1.5,
        beamCount: Int = 1
    ) -> some View {
        borderBeam(cornerRadius: cornerRadius,
                   style: BorderBeamStyle(colors: colors, duration: duration, length: length,
                                          lineWidth: lineWidth, beamCount: beamCount))
    }
}

// MARK: - Overlay

private struct BorderBeamOverlay: View {
    var cornerRadius: CGFloat
    var style: BorderBeamStyle

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Tail is drawn as this many short segments, each with its own color / opacity / width.
    private let segments = 30

    var body: some View {
        let pad = style.glow * 2.5
        let palette = sampledColors()

        ZStack {
            if style.showsTrack {
                RoundedRectangle(cornerRadius: clampedRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.08), lineWidth: style.lineWidth)
                    .padding(pad)
            }

            TimelineView(.animation(paused: reduceMotion)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                Canvas { ctx, size in
                    let rect = CGRect(origin: .zero, size: size)
                        .insetBy(dx: pad + style.lineWidth / 2, dy: pad + style.lineWidth / 2)
                    let radius = min(cornerRadius, min(rect.width, rect.height) / 2)
                    let path = RoundedRectangle(cornerRadius: max(radius - style.lineWidth / 2, 0), style: .continuous)
                        .path(in: rect)
                    let lap = time / max(style.duration, 0.1) + style.offset
                    let count = max(style.beamCount, 1)

                    for beam in 0..<count {
                        var head = lap + Double(beam) / Double(count)
                        head -= floor(head)
                        if style.reversed { head = 1 - head }
                        draw(path: path, head: CGFloat(head), palette: palette, in: ctx)
                    }
                }
            }
        }
        .padding(-pad)
    }

    private var clampedRadius: CGFloat { cornerRadius.isFinite ? cornerRadius : 10_000 }

    // MARK: Drawing

    private func draw(path: Path, head: CGFloat, palette: [Color], in ctx: GraphicsContext) {
        let step = style.length / CGFloat(segments)
        let direction: CGFloat = style.reversed ? 1 : -1 // tail trails behind the head
        let isDark = colorScheme == .dark

        let pieces: [(path: Path, color: Color, fade: Double, width: CGFloat)] = (0..<segments).map { index in
            let f = CGFloat(index) / CGFloat(segments) // 0 at head → 1 at tail
            let a = head + direction * step * CGFloat(index)
            let b = head + direction * step * CGFloat(index + 1)
            return (segment(of: path, from: min(a, b), to: max(a, b)),
                    palette[index],
                    Double(pow(1 - f, 1.5)),
                    style.lineWidth * (1 + 0.7 * (1 - f)))
        }
        let tip = segment(of: path, from: max(head - 0.002, 0), to: max(head, 0.002)).boundingRect
        let point = CGPoint(x: tip.midX, y: tip.midY)
        let headColor = palette.first ?? .white

        // Bloom: one blurred layer for the whole beam (one blur pass, not one per segment).
        ctx.drawLayer { glow in
            glow.addFilter(.blur(radius: style.glow))
            if isDark { glow.blendMode = .plusLighter }
            for piece in pieces.prefix(segments * 2 / 3) {
                glow.stroke(piece.path, with: .color(piece.color.opacity(piece.fade * 0.9)), lineWidth: piece.width * 3)
            }
            let r = style.lineWidth * 4
            glow.fill(Path(ellipseIn: CGRect(x: point.x - r, y: point.y - r, width: r * 2, height: r * 2)),
                      with: .color(headColor.opacity(0.9)))
        }

        // Crisp beam.
        for piece in pieces {
            ctx.stroke(piece.path, with: .color(piece.color.opacity(piece.fade)),
                       style: StrokeStyle(lineWidth: piece.width, lineCap: .butt))
        }
        let core = style.lineWidth * 1.2
        ctx.fill(Path(ellipseIn: CGRect(x: point.x - core, y: point.y - core, width: core * 2, height: core * 2)),
                 with: .color(isDark ? .white : headColor))
    }

    /// Trims `path` between two fractions, wrapping across the start point.
    private func segment(of path: Path, from start: CGFloat, to end: CGFloat) -> Path {
        var a = start, b = end
        if a < 0 { a += 1; b += 1 }
        if b <= 1 { return path.trimmedPath(from: a, to: b) }
        var result = path.trimmedPath(from: a, to: 1)
        result.addPath(path.trimmedPath(from: 0, to: b - 1))
        return result
    }

    /// Pre-blends the color list into one color per tail segment.
    private func sampledColors() -> [Color] {
        let colors = style.colors.isEmpty ? [Color.white] : style.colors
        guard colors.count > 1 else { return Array(repeating: colors[0], count: segments) }
        return (0..<segments).map { index in
            let position = Double(index) / Double(segments - 1) * Double(colors.count - 1)
            let lower = Int(position)
            let upper = min(lower + 1, colors.count - 1)
            return colors[lower].mix(with: colors[upper], by: position - Double(lower))
        }
    }
}

// MARK: - Preview

#Preview("Border Beam") {
    VStack(spacing: 28) {
        VStack(alignment: .leading, spacing: 8) {
            Label("Pro plan", systemImage: "sparkles")
                .font(.headline)
            Text("$12 / month")
                .font(.system(size: 36, weight: .bold, design: .rounded))
            Text("Every component, every update.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .borderBeam(cornerRadius: 24)

        Text("Get started")
            .font(.headline)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .background(Color(.tertiarySystemBackground), in: Capsule())
            .borderBeam(cornerRadius: .infinity,
                        style: .init(colors: [.yellow, .orange, .red], duration: 3, length: 0.35, beamCount: 2))
    }
    .padding(24)
}
