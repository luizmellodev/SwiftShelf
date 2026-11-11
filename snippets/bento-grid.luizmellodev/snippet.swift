import SwiftUI

// MARK: - Bento Layout

/// A column-based bento layout. Each child declares how many columns and
/// rows it spans with `.bentoSpan(columns:rows:)`, and tiles are packed
/// top-to-bottom into the first gap that fits (dense packing).
public struct BentoGridLayout: Layout {
    public var columns: Int
    public var spacing: CGFloat
    public var rowHeight: CGFloat

    public init(columns: Int = 4, spacing: CGFloat = 12, rowHeight: CGFloat = 86) {
        self.columns = max(1, columns)
        self.spacing = spacing
        self.rowHeight = rowHeight
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 360
        let frames = frames(for: subviews, width: width)
        return CGSize(width: width, height: frames.map(\.maxY).max() ?? 0)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let frames = frames(for: subviews, width: bounds.width)
        for (subview, frame) in zip(subviews, frames) {
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func frames(for subviews: Subviews, width: CGFloat) -> [CGRect] {
        let columnWidth = (width - CGFloat(columns - 1) * spacing) / CGFloat(columns)
        var occupied: [[Bool]] = []
        var frames: [CGRect] = []

        func isFree(row: Int, column: Int, width w: Int, height h: Int) -> Bool {
            for r in row..<(row + h) {
                guard r < occupied.count else { continue }
                for c in column..<(column + w) where occupied[r][c] { return false }
            }
            return true
        }

        for subview in subviews {
            let span = subview[BentoGridSpanKey.self]
            let w = min(max(1, span.columns), columns)
            let h = max(1, span.rows)
            var row = 0
            var placed = false

            while !placed {
                for column in 0...(columns - w) where isFree(row: row, column: column, width: w, height: h) {
                    while occupied.count < row + h { occupied.append(Array(repeating: false, count: columns)) }
                    for r in row..<(row + h) {
                        for c in column..<(column + w) { occupied[r][c] = true }
                    }
                    frames.append(CGRect(
                        x: CGFloat(column) * (columnWidth + spacing),
                        y: CGFloat(row) * (rowHeight + spacing),
                        width: CGFloat(w) * columnWidth + CGFloat(w - 1) * spacing,
                        height: CGFloat(h) * rowHeight + CGFloat(h - 1) * spacing
                    ))
                    placed = true
                    break
                }
                row += 1
            }
        }
        return frames
    }
}

private struct BentoGridSpan {
    var columns: Int
    var rows: Int
}

private struct BentoGridSpanKey: LayoutValueKey {
    static let defaultValue = BentoGridSpan(columns: 2, rows: 1)
}

public extension View {
    /// How many columns and rows this tile occupies inside a `BentoGridLayout`.
    func bentoSpan(columns: Int, rows: Int = 1) -> some View {
        layoutValue(key: BentoGridSpanKey.self, value: BentoGridSpan(columns: columns, rows: rows))
    }
}

// MARK: - Bento Cell

/// A bento tile. It springs in with a staggered blur + scale + rise based on
/// its `index`, and presses in with depth (scale, shadow, haptic) on touch.
public struct BentoGridCell<Content: View>: View {
    let index: Int
    let columns: Int
    let rows: Int
    let tint: Color?
    let action: () -> Void
    let content: Content

    @State private var appeared = false

    /// - Parameters:
    ///   - index: Position in the entrance choreography.
    ///   - tint: `nil` for a neutral card, or a color for a vivid gradient tile.
    public init(
        index: Int,
        columns: Int,
        rows: Int = 1,
        tint: Color? = nil,
        action: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        self.index = index
        self.columns = columns
        self.rows = rows
        self.tint = tint
        self.action = action
        self.content = content()
    }

    private var background: AnyShapeStyle {
        if let tint {
            AnyShapeStyle(LinearGradient(colors: [tint, tint.mix(with: .black, by: 0.35)], startPoint: .topLeading, endPoint: .bottomTrailing))
        } else {
            AnyShapeStyle(Color(.secondarySystemGroupedBackground))
        }
    }

    public var body: some View {
        Button(action: action) {
            content
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .foregroundStyle(tint == nil ? Color(.label) : .white)
                .background(background, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .strokeBorder(.white.opacity(tint == nil ? 0.06 : 0.22), lineWidth: 1)
                }
                .contentShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
        .buttonStyle(BentoGridPressStyle())
        .opacity(appeared ? 1 : 0)
        .blur(radius: appeared ? 0 : 14)
        .scaleEffect(appeared ? 1 : 0.86)
        .offset(y: appeared ? 0 : 26)
        .bentoSpan(columns: columns, rows: rows)
        .onAppear {
            withAnimation(.spring(response: 0.62, dampingFraction: 0.78).delay(0.05 + Double(index) * 0.07)) {
                appeared = true
            }
        }
    }
}

private struct BentoGridPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .brightness(configuration.isPressed ? -0.03 : 0)
            .shadow(
                color: .black.opacity(configuration.isPressed ? 0.06 : 0.12),
                radius: configuration.isPressed ? 4 : 14,
                y: configuration.isPressed ? 2 : 8
            )
            .animation(.spring(response: 0.28, dampingFraction: 0.62), value: configuration.isPressed)
            .sensoryFeedback(.impact(weight: .light), trigger: configuration.isPressed) { _, pressed in pressed }
    }
}

// MARK: - Live Chart

/// A continuously flowing area chart with a glowing head dot.
public struct BentoGridLiveChart: View {
    var tint: Color
    var lineWidth: CGFloat

    public init(tint: Color = .white, lineWidth: CGFloat = 2.5) {
        self.tint = tint
        self.lineWidth = lineWidth
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate * 1.1
            GeometryReader { proxy in
                let size = proxy.size
                let head = CGPoint(x: size.width, y: BentoGridWave.y(at: 1, phase: phase) * size.height)
                ZStack(alignment: .topLeading) {
                    BentoGridWave(phase: phase, closed: true)
                        .fill(LinearGradient(colors: [tint.opacity(0.4), tint.opacity(0)], startPoint: .top, endPoint: .bottom))
                    BentoGridWave(phase: phase, closed: false)
                        .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    Circle()
                        .fill(tint)
                        .frame(width: 9, height: 9)
                        .shadow(color: tint, radius: 6)
                        .position(head)
                }
            }
        }
        .accessibilityHidden(true)
    }
}

private struct BentoGridWave: Shape {
    var phase: Double
    var closed: Bool

    static func y(at x: Double, phase: Double) -> Double {
        let v = 0.5
            + 0.22 * sin(x * .pi * 2.4 + phase)
            + 0.1 * sin(x * .pi * 6.2 + phase * 1.7)
            - 0.16 * x
        return min(max(v, 0.05), 0.95)
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let steps = 48
        for step in 0...steps {
            let x = Double(step) / Double(steps)
            let point = CGPoint(x: rect.minX + x * rect.width, y: rect.minY + Self.y(at: x, phase: phase) * rect.height)
            step == 0 ? path.move(to: point) : path.addLine(to: point)
        }
        if closed {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
        return path
    }
}

// MARK: - Live Ring

/// An activity ring that fills on appear and gently breathes.
public struct BentoGridLiveRing: View {
    var progress: Double
    var colors: [Color]
    var lineWidth: CGFloat

    @State private var shown: Double = 0

    public init(progress: Double, colors: [Color] = [.pink, .orange], lineWidth: CGFloat = 12) {
        self.progress = min(max(progress, 0), 1)
        self.colors = colors
        self.lineWidth = lineWidth
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.tertiarySystemFill), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: shown)
                .stroke(
                    AngularGradient(colors: colors + [colors.first ?? .pink], center: .center),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: (colors.last ?? .orange).opacity(0.5), radius: 6)
            Text("\(Int(shown * 100))%")
                .font(.system(.title3, design: .rounded).weight(.bold))
                .contentTransition(.numericText(value: shown))
        }
        .padding(lineWidth / 2)
        .onAppear {
            withAnimation(.spring(response: 1.4, dampingFraction: 0.8).delay(0.4)) { shown = progress }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Int(progress * 100)) percent")
    }
}

// MARK: - Live Pulse

/// A status dot with sonar rings, e.g. "Live" or "Online".
public struct BentoGridLivePulse: View {
    var color: Color
    var size: CGFloat

    public init(color: Color = .green, size: CGFloat = 10) {
        self.color = color
        self.size = size
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(0..<2, id: \.self) { ring in
                    let p = (t / 1.6 + Double(ring) * 0.5).truncatingRemainder(dividingBy: 1)
                    Circle()
                        .stroke(color, lineWidth: 1.5)
                        .scaleEffect(1 + p * 1.8)
                        .opacity(1 - p)
                }
                Circle().fill(color).shadow(color: color, radius: 4)
            }
            .frame(width: size, height: size)
        }
        .frame(width: size * 3, height: size * 3)
        .accessibilityHidden(true)
    }
}

// MARK: - Live Bars

/// A mini bar chart whose values reshuffle every second with a spring.
public struct BentoGridLiveBars: View {
    var tint: Color
    var count: Int

    public init(tint: Color = .blue, count: Int = 7) {
        self.tint = tint
        self.count = count
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1.2)) { timeline in
            let tick = Int(timeline.date.timeIntervalSinceReferenceDate / 1.2)
            HStack(alignment: .bottom, spacing: 5) {
                ForEach(0..<count, id: \.self) { index in
                    let value = 0.25 + 0.75 * abs(sin(Double(index) * 1.7 + Double(tick) * 0.9))
                    GeometryReader { proxy in
                        VStack {
                            Spacer(minLength: 0)
                            Capsule()
                                .fill(index == count - 1 ? AnyShapeStyle(tint.gradient) : AnyShapeStyle(tint.opacity(0.35)))
                                .frame(height: proxy.size.height * value)
                        }
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(Double(index) * 0.03), value: tick)
                }
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Live Counter

/// A number that ticks upward with a rolling numeric transition.
public struct BentoGridLiveCounter: View {
    var start: Int
    var perTick: Int
    var prefix: String

    public init(start: Int, perTick: Int = 37, prefix: String = "") {
        self.start = start
        self.perTick = perTick
        self.prefix = prefix
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1.5)) { timeline in
            let ticks = Int(timeline.date.timeIntervalSinceReferenceDate / 1.5) % 10_000
            let value = start + ticks % 400 * perTick
            Text(prefix + value.formatted())
                .contentTransition(.numericText(value: Double(value)))
                .animation(.snappy, value: value)
        }
    }
}

// MARK: - Preview

#Preview("Bento Grid") {
    ScrollView {
        BentoGridLayout {
            BentoGridCell(index: 0, columns: 4, rows: 2, tint: .indigo) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Revenue").font(.subheadline.weight(.semibold)).opacity(0.8)
                    BentoGridLiveCounter(start: 48_210, prefix: "$")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    BentoGridLiveChart()
                }
            }
            BentoGridCell(index: 1, columns: 2, rows: 2) {
                VStack(alignment: .leading) {
                    Text("Goal").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                    BentoGridLiveRing(progress: 0.72)
                }
            }
            BentoGridCell(index: 2, columns: 2) {
                HStack {
                    BentoGridLivePulse()
                    VStack(alignment: .leading) {
                        Text("1,284").font(.headline)
                        Text("online").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            BentoGridCell(index: 3, columns: 2) {
                BentoGridLiveBars()
            }
        }
        .padding(20)
    }
    .background(Color(.systemGroupedBackground))
}
