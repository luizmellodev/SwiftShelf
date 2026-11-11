import SwiftUI

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

/// A touch-first bar chart built from plain shapes.
///
/// Bars grow in with a left-to-right stagger, and swapping `entries` sends
/// the same wave through the new values. Drag across the chart to highlight
/// a bar: the others dim, a tooltip glides along on a spring, and every new
/// bar ticks a selection haptic.
public struct ScrubBarChart: View {
    let entries: [ScrubBarChartEntry]
    var gradient: [Color]
    var valueFormat: (Double) -> String
    private var externalSelection: Binding<Int?>?

    @State private var internalSelection: Int?
    @State private var grown = false

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
        get { externalSelection?.wrappedValue ?? internalSelection }
    }

    private func setSelection(_ value: Int?) {
        if let externalSelection { externalSelection.wrappedValue = value } else { internalSelection = value }
    }

    private var maxValue: Double { max(entries.map(\.value).max() ?? 1, .ulpOfOne) * 1.12 }
    private var average: Double { entries.isEmpty ? 0 : entries.map(\.value).reduce(0, +) / Double(entries.count) }

    private let tooltipSpace: CGFloat = 46
    private let labelHeight: CGFloat = 22

    public var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let plotHeight = max(proxy.size.height - tooltipSpace - labelHeight, 1)
            let slot = width / CGFloat(max(entries.count, 1))
            let barWidth = min(slot * 0.62, 34)

            ZStack(alignment: .topLeading) {
                gridLines(plotHeight: plotHeight, width: width)
                    .offset(y: tooltipSpace)

                // Bars
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(entries.indices, id: \.self) { index in
                        bar(index: index, plotHeight: plotHeight, barWidth: barWidth)
                            .frame(width: slot, height: plotHeight, alignment: .bottom)
                            .transition(.opacity.combined(with: .scale(scale: 0.2, anchor: .bottom)))
                    }
                }
                .offset(y: tooltipSpace)

                // X labels
                HStack(spacing: 0) {
                    ForEach(entries.indices, id: \.self) { index in
                        Text(entries[index].label)
                            .font(.caption2.weight(selection == index ? .bold : .medium))
                            .foregroundStyle(selection == index ? Color.primary : Color.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(width: slot)
                    }
                }
                .frame(height: labelHeight)
                .offset(y: tooltipSpace + plotHeight + 4)

                if let selection, entries.indices.contains(selection) {
                    tooltip(for: selection)
                        .fixedSize()
                        .position(
                            x: tooltipX(for: selection, slot: slot, width: width),
                            y: tooltipSpace + plotHeight * (1 - CGFloat(entries[selection].value / maxValue)) - 26
                        )
                        .transition(.scale(scale: 0.6, anchor: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.32, dampingFraction: 0.78), value: selection)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard !entries.isEmpty else { return }
                        let index = min(max(Int(value.location.x / slot), 0), entries.count - 1)
                        if index != selection { setSelection(index) }
                    }
                    .onEnded { _ in setSelection(nil) }
            )
        }
        .onAppear { grown = true }
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

    // MARK: Pieces

    private func bar(index: Int, plotHeight: CGFloat, barWidth: CGFloat) -> some View {
        let entry = entries[index]
        let isSelected = selection == index
        let dimmed = selection != nil && !isSelected
        let height = grown ? max(plotHeight * CGFloat(entry.value / maxValue), 4) : 4

        return UnevenRoundedRectangle(
            topLeadingRadius: barWidth * 0.32,
            bottomLeadingRadius: 4,
            bottomTrailingRadius: 4,
            topTrailingRadius: barWidth * 0.32,
            style: .continuous
        )
        .fill(LinearGradient(colors: gradient.reversed(), startPoint: .top, endPoint: .bottom))
        .overlay(alignment: .top) {
            // Glossy highlight on the cap
            UnevenRoundedRectangle(topLeadingRadius: barWidth * 0.32, topTrailingRadius: barWidth * 0.32, style: .continuous)
                .fill(.white.opacity(0.25))
                .frame(height: min(height * 0.3, 14))
                .blendMode(.plusLighter)
        }
        .frame(width: isSelected ? barWidth * 1.12 : barWidth, height: height)
        .saturation(dimmed ? 0.2 : 1)
        .opacity(dimmed ? 0.3 : 1)
        .shadow(color: (gradient.last ?? .accentColor).opacity(isSelected ? 0.45 : 0), radius: 10, y: 4)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.72).delay(Double(index) * 0.035),
            value: entries
        )
        .animation(
            .spring(response: 0.7, dampingFraction: 0.7).delay(0.1 + Double(index) * 0.045),
            value: grown
        )
    }

    private func gridLines(plotHeight: CGFloat, width: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(0..<4, id: \.self) { i in
                Rectangle()
                    .fill(Color.primary.opacity(i == 0 ? 0.12 : 0.06))
                    .frame(width: width, height: 1)
                    .offset(y: plotHeight * (1 - CGFloat(i) / 3))
            }

            // Average rule
            let avgY = plotHeight * (1 - CGFloat(average / maxValue))
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: width, y: 0))
            }
            .stroke(Color.secondary.opacity(0.6), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .frame(height: 1)
            .overlay(alignment: .trailing) {
                Text("avg")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(Color(.systemBackground).opacity(0.9), in: Capsule())
                    .offset(y: -10)
            }
            .offset(y: avgY)
            .opacity(selection == nil ? 1 : 0.3)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: entries)
        }
        .frame(width: width, height: plotHeight, alignment: .topLeading)
    }

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

    private func tooltipX(for index: Int, slot: CGFloat, width: CGFloat) -> CGFloat {
        let center = slot * (CGFloat(index) + 0.5)
        return min(max(center, 40), width - 40)
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
