import SwiftUI
import Charts

// MARK: - Number Ticker Stat Card

/// A KPI card with an odometer-style number: every digit is its own rolling
/// column that springs to the new value with a right-to-left stagger.
///
/// The Swift Charts sparkline draws itself on appear (a left-to-right wipe
/// of the line and its gradient area). Scrub the sparkline with your finger to inspect any
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

/// Swift Charts sparkline: a catmull-rom LineMark over a gradient AreaMark,
/// revealed left-to-right by `progress`. Dragging scrubs to the nearest point.
private struct NumberTickerStatSparkline: View {
    let points: [Double]
    let gradient: [Color]
    let progress: CGFloat
    @Binding var selectedIndex: Int?

    private var accent: Color { gradient.last ?? .accentColor }

    /// Y domain with a little breathing room above and below the curve.
    private var yDomain: ClosedRange<Double> {
        guard let minV = points.min(), let maxV = points.max() else { return 0...1 }
        let range = max(maxV - minV, .ulpOfOne)
        return (minV - range * 0.08)...(maxV + range * 0.14)
    }

    private var xDomain: ClosedRange<Int> { 0...max(points.count - 1, 1) }

    var body: some View {
        let baseline = yDomain.lowerBound

        Chart {
            ForEach(points.indices, id: \.self) { index in
                AreaMark(
                    x: .value("Index", index),
                    yStart: .value("Baseline", baseline),
                    yEnd: .value("Value", points[index])
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        colors: [(gradient.first ?? accent).opacity(0.32), accent.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            ForEach(points.indices, id: \.self) { index in
                LineMark(x: .value("Index", index), y: .value("Value", points[index]))
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2.75, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing))
                    .shadow(color: accent.opacity(0.35), radius: 6, y: 4)
            }

            if let selectedIndex, points.indices.contains(selectedIndex) {
                RuleMark(x: .value("Index", selectedIndex))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    .foregroundStyle(Color.primary.opacity(0.18))
            }
        }
        .chartXScale(domain: xDomain)
        .chartYScale(domain: yDomain)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                if let plotAnchor = proxy.plotFrame {
                    let plot = geometry[plotAnchor]
                    let index = selectedIndex.flatMap { points.indices.contains($0) ? $0 : nil }
                        ?? (progress >= 1 ? points.indices.last : nil)
                    if let index,
                       let x = proxy.position(forX: index),
                       let y = proxy.position(forY: points[index]) {
                        NumberTickerStatDot(color: accent, pulsing: selectedIndex == nil)
                            .position(x: plot.minX + x, y: plot.minY + y)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
        .chartGesture { proxy in
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    guard points.count > 1,
                          let x: Double = proxy.value(atX: value.location.x) else { return }
                    let clamped = min(max(Int(x.rounded()), 0), points.count - 1)
                    if clamped != selectedIndex { selectedIndex = clamped }
                }
                .onEnded { _ in selectedIndex = nil }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedIndex == nil)
        // Draw-on reveal. Slightly oversized so the end dot isn't clipped.
        .mask(alignment: .leading) {
            GeometryReader { proxy in
                Rectangle()
                    .frame(width: (proxy.size.width + 28) * progress, height: proxy.size.height + 40)
                    .offset(x: -14, y: -20)
            }
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
