import SwiftUI

// MARK: - Slide To Confirm

/// The mobile-native confirm: drag the knob to the end and the whole track
/// morphs into a circle, spins while your async work runs, then draws a
/// checkmark. Releasing early springs the knob back with a rubber-band feel.
public struct SlideToConfirm: View {
    let title: String
    var tint: Color
    var resetsAfterSuccess: Bool
    let onConfirm: () async -> Void

    private enum Phase: Equatable { case idle, loading, done }

    @State private var phase: Phase = .idle
    @State private var drag: CGFloat = 0
    @State private var width: CGFloat = 0

    private let height: CGFloat = 64
    private let inset: CGFloat = 5
    private let threshold: CGFloat = 0.9

    public init(
        _ title: String,
        tint: Color = .indigo,
        resetsAfterSuccess: Bool = true,
        onConfirm: @escaping () async -> Void
    ) {
        self.title = title
        self.tint = tint
        self.resetsAfterSuccess = resetsAfterSuccess
        self.onConfirm = onConfirm
    }

    private var knob: CGFloat { height - inset * 2 }
    private var maxDrag: CGFloat { max(width - knob - inset * 2, 1) }
    private var progress: CGFloat { min(max(drag / maxDrag, 0), 1) }
    private var isArmed: Bool { progress >= threshold }

    public var body: some View {
        ZStack {
            Capsule()
                .fill(phase == .idle ? AnyShapeStyle(Color(.secondarySystemFill)) : AnyShapeStyle(tint.gradient))

            if phase == .idle {
                idleContent
                    .transition(.opacity)
            } else {
                statusIcon
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
            }
        }
        .frame(maxWidth: phase == .idle ? .infinity : height)
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
        .sensoryFeedback(.impact(weight: .light), trigger: isArmed) { _, armed in armed }
        .sensoryFeedback(trigger: phase) { _, new in new == .done ? .success : nil }
        .accessibilityElement()
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { confirm() }
    }

    // MARK: Idle

    private var idleContent: some View {
        ZStack(alignment: .leading) {
            // Trail that follows the knob
            Capsule()
                .fill(tint.gradient)
                .frame(width: knob + inset * 2 + drag)
                .opacity(Double(0.25 + progress * 0.75))

            SlideShimmerLabel(text: title)
                .frame(maxWidth: .infinity)
                .padding(.leading, knob * 0.6)
                .opacity(Double(1 - progress * 1.6))
                .blur(radius: progress * 6)

            Circle()
                .fill(.white)
                .frame(width: knob, height: knob)
                .overlay {
                    Image(systemName: isArmed ? "checkmark" : "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(tint)
                        .contentTransition(.symbolEffect(.replace))
                }
                .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
                .scaleEffect(drag > 0 ? 1.04 : 1)
                .offset(x: inset + drag)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            guard phase == .idle else { return }
                            drag = rubberBand(value.translation.width)
                        }
                        .onEnded { _ in
                            guard phase == .idle else { return }
                            if isArmed {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { drag = maxDrag }
                                confirm()
                            } else {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { drag = 0 }
                            }
                        }
                )
        }
        .animation(.snappy, value: isArmed)
    }

    // MARK: Status

    @ViewBuilder
    private var statusIcon: some View {
        if phase == .loading {
            TimelineView(.animation) { timeline in
                let angle = timeline.date.timeIntervalSinceReferenceDate * 360
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 26, height: 26)
                    .rotationEffect(.degrees(angle.truncatingRemainder(dividingBy: 360)))
            }
        } else {
            DrawnCheckmark()
                .frame(width: 24, height: 24)
        }
    }

    // MARK: Logic

    private func rubberBand(_ x: CGFloat) -> CGFloat {
        if x < 0 { return 0 }
        if x > maxDrag { return maxDrag + (x - maxDrag) * 0.15 }
        return x
    }

    private func confirm() {
        guard phase == .idle else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(160))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { phase = .loading }
            await onConfirm()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { phase = .done }

            guard resetsAfterSuccess else { return }
            try? await Task.sleep(for: .seconds(1.6))
            drag = 0
            withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) { phase = .idle }
        }
    }
}

// MARK: - Helpers

private struct SlideShimmerLabel: View {
    let text: String

    var body: some View {
        TimelineView(.animation) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 2.2) / 1.6

            Text(text)
                .font(.headline)
                .foregroundStyle(.secondary)
                .overlay {
                    GeometryReader { proxy in
                        let width = proxy.size.width
                        LinearGradient(colors: [.clear, .primary, .clear], startPoint: .leading, endPoint: .trailing)
                            .frame(width: width * 0.5)
                            .offset(x: -width * 0.5 + width * 1.5 * phase)
                    }
                    .mask(Text(text).font(.headline))
                }
        }
    }
}

private struct SlideCheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.1, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.4, y: rect.maxY - rect.height * 0.15))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.05, y: rect.minY + rect.height * 0.15))
        return path
    }
}

private struct DrawnCheckmark: View {
    @State private var drawn = false

    var body: some View {
        SlideCheckmarkShape()
            .trim(from: 0, to: drawn ? 1 : 0)
            .stroke(.white, style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
            .onAppear {
                withAnimation(.easeOut(duration: 0.35).delay(0.1)) { drawn = true }
            }
    }
}

// MARK: - Preview

#Preview("Slide To Confirm") {
    VStack(spacing: 24) {
        SlideToConfirm("Slide to pay $24.90") {
            try? await Task.sleep(for: .seconds(1.4))
        }

        SlideToConfirm("Slide to unlock", tint: .green) {
            try? await Task.sleep(for: .seconds(0.8))
        }
    }
    .padding(24)
}
