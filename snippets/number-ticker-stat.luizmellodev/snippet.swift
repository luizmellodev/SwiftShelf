import SwiftUI

// MARK: - Number Ticker Stat Card

/// A KPI card with an odometer-style number: every digit is its own rolling
/// column that springs to the new value with a right-to-left stagger.
///
/// The sparkline draws itself on appear (stroke trim + a gradient fill that
/// is revealed with it). Scrub the sparkline with your finger to inspect any
/// point — the big number rolls to that value and the delta badge follows.
public struct NumberTickerStatCard: View {
    let title: String
    let points: [Double]
    var labels: [String]
    var caption: String
    var systemImage: String
    var prefix: String
    var suffix: String
    var fractionDigits: Int
    var gradient: [Color]

    @State private var selectedIndex: Int?
    @State private var appeared = false
    @State private var drawProgress: CGFloat = 0

    public init(
        _ title: String,
        points: [Double],
        labels: [String] = [],
        caption: String = "Last 30 days",
        systemImage: String = "chart.line.uptrend.xyaxis",
        prefix: String = "",
        suffix: String = "",
        fractionDigits: Int = 0,
        gradient: [Color] = [.indigo, .purple, .pink]
    ) {
        self.title = title
        self.points = points
        self.labels = labels
        self.caption = caption
        self.systemImage = systemImage
        self.prefix = prefix
        self.suffix = suffix
        self.fractionDigits = fractionDigits
        self.gradient = gradient
    }

    private var shownValue: Double {
        if let selectedIndex, points.indices.contains(selectedIndex) { return points[selectedIndex] }
        return points.last ?? 0
    }

    private var delta: Double {
        guard let base = points.first, base != 0 else { return 0 }
        return (shownValue - base) / abs(base) * 100
    }

    private var formatted: String {
        let value = appeared ? shownValue : 0
        return prefix + value.formatted(.number.precision(.fractionLength(fractionDigits))) + suffix
    }

    private var currentCaption: String {
        guard let selectedIndex else { return caption }
        return labels.indices.contains(selectedIndex) ? labels[selectedIndex] : "Point \(selectedIndex + 1)"
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            NumberTickerStatRoller(
                text: formatted,
                font: .system(size: 44, weight: .bold, design: .rounded).monospacedDigit()
            )
            .foregroundStyle(.primary)

            NumberTickerStatSparkline(
                points: points,
                gradient: gradient,
                progress: drawProgress,
                selectedIndex: $selectedIndex
            )
            .frame(height: 92)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.08), radius: 24, y: 12)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
        .onAppear {
            guard !appeared else { return }
            withAnimation(.spring(response: 0.9, dampingFraction: 0.8).delay(0.15)) { appeared = true }
            withAnimation(.easeInOut(duration: 1.3).delay(0.15)) { drawProgress = 1 }
        }
        .sensoryFeedback(.selection, trigger: selectedIndex) { _, new in new != nil }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue("\(formatted), \(currentCaption), \(delta >= 0 ? "up" : "down") \(abs(delta).formatted(.number.precision(.fractionLength(1)))) percent")
        .accessibilityAdjustableAction { direction in
            let current = selectedIndex ?? points.count - 1
            switch direction {
            case .increment: selectedIndex = min(current + 1, points.count - 1)
            case .decrement: selectedIndex = max(current - 1, 0)
            @unknown default: break
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(
                    LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 11, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(currentCaption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .contentTransition(.opacity)
                    .animation(.snappy, value: currentCaption)
            }

            Spacer(minLength: 8)

            NumberTickerStatDeltaBadge(delta: appeared ? delta : 0)
        }
    }
}

// MARK: - Delta Badge

private struct NumberTickerStatDeltaBadge: View {
    let delta: Double

    private var isUp: Bool { delta >= 0 }
    private var tint: Color { isUp ? .green : .red }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                .font(.caption2.weight(.heavy))
                .contentTransition(.symbolEffect(.replace))
            Text("\(abs(delta).formatted(.number.precision(.fractionLength(1))))%")
                .font(.caption.weight(.bold).monospacedDigit())
                .contentTransition(.numericText(value: delta))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(tint.opacity(0.14), in: Capsule())
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: delta)
    }
}

// MARK: - Odometer

/// Renders a string where every digit is a rolling 0–9 column.
/// Columns are identified from the right so place values stay stable
/// when the number gains or loses digits.
private struct NumberTickerStatRoller: View {
    let text: String
    let font: Font
    var stagger: Double = 0.035

    private struct Glyph: Identifiable {
        let id: Int
        let character: Character
    }

    private var glyphs: [Glyph] {
        let chars = Array(text)
        return chars.indices.map { Glyph(id: chars.count - 1 - $0, character: chars[$0]) }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(glyphs) { glyph in
                Group {
                    if let digit = glyph.character.wholeNumberValue {
                        NumberTickerStatDigitColumn(digit: digit, font: font)
                            .animation(
                                .spring(response: 0.75, dampingFraction: 0.78).delay(Double(glyph.id) * stagger),
                                value: digit
                            )
                    } else {
                        Text(String(glyph.character)).font(font)
                    }
                }
                .transition(BlurReplaceTransition(configuration: .downUp).combined(with: ScaleTransition(0.6)))
            }
        }
        .monospacedDigit()
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: glyphs.count)
        .accessibilityLabel(text)
    }
}

private struct NumberTickerStatDigitColumn: View {
    let digit: Int
    let font: Font

    var body: some View {
        Text("0")
            .font(font)
            .hidden()
            .overlay(alignment: .top) {
                GeometryReader { proxy in
                    let cell = proxy.size.height
                    VStack(spacing: 0) {
                        ForEach(0..<10, id: \.self) { number in
                            Text("\(number)")
                                .font(font)
                                .frame(height: cell)
                        }
                    }
                    .frame(width: proxy.size.width)
                    .offset(y: -CGFloat(digit) * cell)
                }
            }
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.1),
                        .init(color: .black, location: 0.9),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
    }
}

// MARK: - Sparkline

private struct NumberTickerStatSparkline: View {
    let points: [Double]
    let gradient: [Color]
    let progress: CGFloat
    @Binding var selectedIndex: Int?

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let locations = numberTickerStatLocations(points, in: size)
            let accent = gradient.last ?? .accentColor

            ZStack(alignment: .topLeading) {
                // Gradient area, revealed left-to-right with the stroke
                NumberTickerStatCurve(values: points, closed: true)
                    .fill(
                        LinearGradient(
                            colors: [(gradient.first ?? accent).opacity(0.32), accent.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .mask(alignment: .leading) {
                        Rectangle().frame(width: size.width * progress)
                    }

                NumberTickerStatCurve(values: points, closed: false)
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 2.75, lineCap: .round, lineJoin: .round)
                    )
                    .shadow(color: accent.opacity(0.35), radius: 6, y: 4)

                if let selectedIndex, locations.indices.contains(selectedIndex) {
                    let point = locations[selectedIndex]
                    Rectangle()
                        .fill(Color.primary.opacity(0.18))
                        .frame(width: 1, height: size.height)
                        .offset(x: point.x - 0.5)

                    NumberTickerStatDot(color: accent, pulsing: false)
                        .position(point)
                } else if progress >= 1, let last = locations.last {
                    NumberTickerStatDot(color: accent, pulsing: true)
                        .position(last)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedIndex == nil)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard points.count > 1 else { return }
                        let step = size.width / CGFloat(points.count - 1)
                        let index = Int((value.location.x / step).rounded())
                        let clamped = min(max(index, 0), points.count - 1)
                        if clamped != selectedIndex { selectedIndex = clamped }
                    }
                    .onEnded { _ in selectedIndex = nil }
            )
        }
    }
}

private struct NumberTickerStatDot: View {
    let color: Color
    let pulsing: Bool

    var body: some View {
        ZStack {
            if pulsing {
                Circle()
                    .fill(color.opacity(0.35))
                    .frame(width: 22, height: 22)
                    .phaseAnimator([false, true]) { content, phase in
                        content
                            .scaleEffect(phase ? 1.4 : 0.6)
                            .opacity(phase ? 0 : 1)
                    } animation: { _ in .easeOut(duration: 1.4) }
            }
            Circle()
                .fill(Color(.systemBackground))
                .frame(width: 13, height: 13)
                .overlay { Circle().fill(color).padding(3) }
                .shadow(color: color.opacity(0.5), radius: 4, y: 2)
        }
    }
}

/// Maps values into the drawing rect (with a little vertical breathing room).
private func numberTickerStatLocations(_ values: [Double], in size: CGSize) -> [CGPoint] {
    guard values.count > 1, let minV = values.min(), let maxV = values.max() else { return [] }
    let range = max(maxV - minV, .ulpOfOne)
    let top: CGFloat = 10
    let bottom: CGFloat = 6
    let usable = size.height - top - bottom
    let step = size.width / CGFloat(values.count - 1)
    return values.enumerated().map { index, value in
        CGPoint(
            x: CGFloat(index) * step,
            y: top + usable * CGFloat(1 - (value - minV) / range)
        )
    }
}

/// Smooth Catmull-Rom curve through the values; `closed` adds the area under it.
private struct NumberTickerStatCurve: Shape {
    let values: [Double]
    let closed: Bool

    func path(in rect: CGRect) -> Path {
        let pts = numberTickerStatLocations(values, in: rect.size)
        var path = Path()
        guard let first = pts.first else { return path }
        path.move(to: first)
        for i in 0..<(pts.count - 1) {
            let p0 = pts[max(i - 1, 0)]
            let p1 = pts[i]
            let p2 = pts[i + 1]
            let p3 = pts[min(i + 2, pts.count - 1)]
            let c1 = CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6)
            let c2 = CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6)
            path.addCurve(to: p2, control1: c1, control2: c2)
        }
        if closed, let last = pts.last {
            path.addLine(to: CGPoint(x: last.x, y: rect.maxY))
            path.addLine(to: CGPoint(x: first.x, y: rect.maxY))
            path.closeSubpath()
        }
        return path
    }
}

// MARK: - Preview

#Preview("Number Ticker Stat") {
    let revenue: [Double] = [8200, 8900, 8600, 9400, 10100, 9800, 11200, 11900, 11400, 12600, 13300, 12900, 14100, 15240]
    ScrollView {
        VStack(spacing: 16) {
            NumberTickerStatCard(
                "Revenue",
                points: revenue,
                labels: revenue.indices.map { "Nov \($0 + 1)" },
                caption: "Last 14 days",
                systemImage: "dollarsign",
                prefix: "$"
            )
            NumberTickerStatCard(
                "Conversion",
                points: [4.1, 3.8, 3.6, 3.9, 3.4, 3.2, 3.0, 2.9, 3.1, 2.7],
                caption: "Last 10 days",
                systemImage: "arrow.triangle.branch",
                suffix: "%",
                fractionDigits: 1,
                gradient: [.orange, .pink]
            )
        }
        .padding(20)
    }
    .background(Color(.systemGroupedBackground))
}
