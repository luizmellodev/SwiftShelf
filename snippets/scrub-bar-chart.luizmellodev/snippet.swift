import SwiftUI
import Charts

// MARK: - Model

public struct ScrubBarChartEntry: Equatable {
    public let label: String
    public let value: Double

    public init(_ label: String, _ value: Double) {
        self.label = label
        self.value = value
    }
}

// MARK: - Scrub Bar Chart

/// A touch-first bar chart built on Swift Charts.
///
/// Bars grow in with a left-to-right stagger, and swapping `entries` sends
/// the same wave through the new values. Drag across the chart to highlight
/// a bar: the others dim, a tooltip glides along on a spring, and every new
/// bar ticks a selection haptic. A dashed rule marks the average.
public struct ScrubBarChart: View {
    let entries: [ScrubBarChartEntry]
    var gradient: [Color]
    var valueFormat: (Double) -> String
    private var externalSelection: Binding<Int?>?

    @State private var internalSelection: Int?
    /// Animated bar heights; filled bar by bar to get the staggered wave.
    @State private var shown: [Double] = []

    public init(
        entries: [ScrubBarChartEntry],
        selection: Binding<Int?>? = nil,
        gradient: [Color] = [.cyan, .blue, .indigo],
        valueFormat: @escaping (Double) -> String = { $0.formatted(.number.notation(.compactName)) }
    ) {
        self.entries = entries
        self.externalSelection = selection
        self.gradient = gradient
        self.valueFormat = valueFormat
    }

    private var selection: Int? {
        externalSelection?.wrappedValue ?? internalSelection
    }

    private func setSelection(_ value: Int?) {
        if let externalSelection { externalSelection.wrappedValue = value } else { internalSelection = value }
    }

    /// Bridges the integer selection to the chart's categorical x selection.
    private var chartSelection: Binding<String?> {
        Binding(
            get: { selection.map(String.init) },
            set: { newValue in
                // Clearing happens only when the finger lifts (see chartGesture).
                guard let index = newValue.flatMap(Int.init), entries.indices.contains(index) else { return }
                if index != selection { setSelection(index) }
            }
        )
    }

    private var maxValue: Double { max(entries.map(\.value).max() ?? 1, .ulpOfOne) * 1.12 }
    private var average: Double { entries.isEmpty ? 0 : entries.map(\.value).reduce(0, +) / Double(entries.count) }
    private var shownAverage: Double { shown.isEmpty ? 0 : shown.reduce(0, +) / Double(shown.count) }

    private func shownValue(at index: Int) -> Double {
        let value = shown.indices.contains(index) ? shown[index] : 0
        return max(value, maxValue * 0.015)
    }

    private let tooltipSpace: CGFloat = 46

    private let growSpring = Animation.spring(response: 0.6, dampingFraction: 0.72)
    private let selectSpring = Animation.spring(response: 0.32, dampingFraction: 0.78)

    public var body: some View {
        GeometryReader { proxy in
            let slot = proxy.size.width / CGFloat(max(entries.count, 1))
            let barWidth = min(slot * 0.62, 34)

            chart(barWidth: barWidth)
                .padding(.top, tooltipSpace)
        }
        .task(id: entries) { await grow(to: entries.map(\.value)) }
        .sensoryFeedback(.selection, trigger: selection) { _, new in new != nil }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Bar chart")
        .accessibilityValue(accessibilityValue)
        .accessibilityAdjustableAction { direction in
            let current = selection ?? -1
            switch direction {
            case .increment: setSelection(min(current + 1, entries.count - 1))
            case .decrement: setSelection(max(current - 1, 0))
            @unknown default: break
            }
        }
    }

    private var accessibilityValue: String {
        if let selection, entries.indices.contains(selection) {
            return "\(entries[selection].label), \(valueFormat(entries[selection].value))"
        }
        return "\(entries.count) bars, average \(valueFormat(average))"
    }

    // MARK: Chart

    private func chart(barWidth: CGFloat) -> some View {
        Chart {
            ForEach(entries.indices, id: \.self) { index in
                let isSelected = selection == index
                let dimmed = selection != nil && !isSelected

                BarMark(
                    x: .value("Bar", String(index)),
                    y: .value("Value", shownValue(at: index)),
                    width: .fixed(isSelected ? barWidth * 1.12 : barWidth)
                )
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: barWidth * 0.32,
                        bottomLeadingRadius: 4,
                        bottomTrailingRadius: 4,
                        topTrailingRadius: barWidth * 0.32,
                        style: .continuous
                    )
                )
                .foregroundStyle(barStyle(dimmed: dimmed))
                .opacity(dimmed ? 0.35 : 1)
                .shadow(color: (gradient.last ?? .accentColor).opacity(isSelected ? 0.45 : 0), radius: 10, y: 4)
            }

            if !entries.isEmpty {
                RuleMark(y: .value("Average", shownAverage))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Color.secondary.opacity(0.6))
                    .opacity(selection == nil ? 1 : 0.3)
                    .annotation(position: .top, alignment: .trailing, spacing: 2) {
                        Text("avg")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Color(.systemBackground).opacity(0.9), in: Capsule())
                            .opacity(selection == nil ? 1 : 0.3)
                    }
            }
        }
        .chartXScale(domain: entries.indices.map(String.init))
        .chartYScale(domain: 0...maxValue)
        .chartXAxis {
            AxisMarks(values: entries.indices.map(String.init)) { value in
                AxisValueLabel(centered: true, collisionResolution: .disabled) {
                    if let raw = value.as(String.self), let index = Int(raw), entries.indices.contains(index) {
                        Text(entries[index].label)
                            .font(.caption2.weight(selection == index ? .bold : .medium))
                            .foregroundStyle(selection == index ? Color.primary : Color.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: (0...3).map { maxValue * Double($0) / 3 }) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(Color.primary.opacity(value.index == 0 ? 0.12 : 0.06))
            }
        }
        .chartLegend(.hidden)
        .chartXSelection(value: chartSelection)
        .chartGesture { proxy in
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    guard !entries.isEmpty else { return }
                    // Clamp so dragging past either edge sticks to the first/last bar.
                    let x = min(max(value.location.x, 0.5), max(proxy.plotSize.width - 0.5, 0.5))
                    proxy.selectXValue(at: x)
                }
                .onEnded { _ in setSelection(nil) }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                if let selection, entries.indices.contains(selection),
                   let plotAnchor = proxy.plotFrame,
                   let x = proxy.position(forX: String(selection)),
                   let y = proxy.position(forY: shownValue(at: selection)) {
                    let plot = geometry[plotAnchor]
                    tooltip(for: selection)
                        .fixedSize()
                        .position(
                            x: min(max(plot.minX + x, 40), geometry.size.width - 40),
                            y: plot.minY + y - 26
                        )
                        .transition(.scale(scale: 0.6, anchor: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(selectSpring, value: selection)
    }

    private func barStyle(dimmed: Bool) -> LinearGradient {
        let colors = gradient.reversed().map { dimmed ? $0.mix(with: .gray, by: 0.75) : $0 }
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }

    // MARK: Growth

    /// Snaps the bar count to the new data, then springs each bar to its
    /// value with a left-to-right stagger. Cancelled if `entries` changes.
    private func grow(to target: [Double]) async {
        let firstRun = shown.isEmpty
        let base = target.indices.map { shown.indices.contains($0) ? shown[$0] : 0 }
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) { shown = base }

        let initialDelay: Duration = firstRun ? .milliseconds(100) : .zero
        let step: Duration = firstRun ? .milliseconds(45) : .milliseconds(35)
        try? await Task.sleep(for: initialDelay)
        for index in target.indices {
            guard !Task.isCancelled else { return }
            withAnimation(firstRun ? .spring(response: 0.7, dampingFraction: 0.7) : growSpring) {
                if shown.indices.contains(index) { shown[index] = target[index] }
            }
            try? await Task.sleep(for: step)
        }
    }

    // MARK: Tooltip

    private func tooltip(for index: Int) -> some View {
        VStack(spacing: 1) {
            Text(valueFormat(entries[index].value))
                .font(.subheadline.weight(.bold).monospacedDigit())
                .contentTransition(.numericText(value: entries[index].value))
            Text(entries[index].label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color(.systemBackground).opacity(0.7))
        }
        .foregroundStyle(Color(.systemBackground))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.primary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }
}

// MARK: - Preview

#Preview("Scrub Bar Chart") {
    @Previewable @State var weekly = true
    let week: [ScrubBarChartEntry] = zip(["M", "T", "W", "T", "F", "S", "S"], [6.2, 8.1, 5.4, 9.8, 7.3, 11.6, 4.9]).map { .init($0, $1 * 1000) }
    let year: [ScrubBarChartEntry] = zip(["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"], [32, 41, 38, 52, 47, 60, 66, 58, 71, 64, 79, 88]).map { .init($0, $1 * 1000) }

    VStack(spacing: 20) {
        Picker("Period", selection: $weekly) {
            Text("Week").tag(true)
            Text("Year").tag(false)
        }
        .pickerStyle(.segmented)

        ScrubBarChart(entries: weekly ? week : year)
            .frame(height: 280)
    }
    .padding(24)
}
