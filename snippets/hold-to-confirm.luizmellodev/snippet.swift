import SwiftUI

// MARK: - Hold To Confirm

/// A press-and-hold button for actions that deserve a moment of intent.
///
/// While your finger is down a gradient sweeps across the pill (and a ring
/// fills around the icon) with haptic ticks that get stronger as it nears
/// the end. Let go early and it rewinds smoothly from exactly where it was;
/// hold to the end and it morphs into a success state.
public struct HoldToConfirmButton: View {
    let title: String
    let systemImage: String
    var holdingTitle: String
    var successTitle: String
    var successImage: String
    var colors: [Color]
    var duration: Double
    var resetsAfterSuccess: Bool
    let action: () -> Void

    private enum Phase: Equatable { case idle, holding, rewinding, done }

    @State private var phase: Phase = .idle
    @State private var anchor: Date = .now
    @State private var rewindFrom: CGFloat = 0
    @State private var tick = 0
    @State private var holdTask: Task<Void, Never>?
    @State private var width: CGFloat = 0

    private let height: CGFloat = 62
    private let rewindDuration: Double = 0.45

    public init(
        _ title: String,
        systemImage: String = "hand.tap.fill",
        holdingTitle: String = "Keep holding…",
        successTitle: String = "Done",
        successImage: String = "checkmark",
        colors: [Color] = [Color(red: 0.36, green: 0.4, blue: 1.0), Color(red: 0.66, green: 0.36, blue: 1.0)],
        duration: Double = 1.4,
        resetsAfterSuccess: Bool = true,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.systemImage = systemImage
        self.holdingTitle = holdingTitle
        self.successTitle = successTitle
        self.successImage = successImage
        self.colors = colors.isEmpty ? [.accentColor] : colors
        self.duration = duration
        self.resetsAfterSuccess = resetsAfterSuccess
        self.action = action
    }

    /// The destructive preset: red-to-orange sweep with a trash icon.
    public static func destructive(
        _ title: String = "Hold to delete",
        successTitle: String = "Deleted",
        duration: Double = 1.6,
        action: @escaping () -> Void = {}
    ) -> HoldToConfirmButton {
        HoldToConfirmButton(
            title,
            systemImage: "trash.fill",
            holdingTitle: "Release to cancel",
            successTitle: successTitle,
            colors: [Color(red: 1.0, green: 0.23, blue: 0.3), Color(red: 1.0, green: 0.52, blue: 0.24)],
            duration: duration,
            action: action
        )
    }

    private var isAnimating: Bool { phase == .holding || phase == .rewinding }

    private var surface: some View {
        TimelineView(.animation(paused: !isAnimating)) { context in
            sweep(progress(at: context.date))
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(colors[0].opacity(phase == .done ? 0 : 0.22), lineWidth: 1))
        .background {
            Capsule()
                .fill(colors.last ?? colors[0])
                .blur(radius: 18)
                .opacity(glowOpacity)
                .offset(y: 8)
        }
        .scaleEffect(phase == .holding ? 0.97 : 1)
        .keyframeAnimator(initialValue: CGFloat(1), trigger: phase == .done) { content, scale in
            content.scaleEffect(scale)
        } keyframes: { _ in
            KeyframeTrack {
                SpringKeyframe(1.05, duration: 0.15, spring: .snappy)
                SpringKeyframe(1.0, duration: 0.4, spring: .bouncy)
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.7), value: phase)
    }

    public var body: some View {
        surface
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
        .contentShape(Capsule())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: 60, perform: {}, onPressingChanged: handlePress)
        .sensoryFeedback(trigger: tick) { _, value in tickFeedback(value) }
        .sensoryFeedback(trigger: phase) { _, new in new == .done ? SensoryFeedback.success : nil }
        .accessibilityElement()
        .accessibilityLabel(phase == .done ? successTitle : title)
        .accessibilityHint("Press and hold to confirm")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { complete() }
    }

    // MARK: Content

    private func sweep(_ progress: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            Capsule().fill(colors[0].opacity(0.13))

            // Sweep
            Rectangle()
                .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                .frame(width: width * progress)
                .overlay(alignment: .trailing) {
                    // Bright leading edge of the sweep
                    Capsule()
                        .fill(.white.opacity(0.55))
                        .frame(width: 10, height: height * 0.9)
                        .blur(radius: 6)
                        .opacity(progress > 0.02 && progress < 0.99 ? 1 : 0)
                }

            if phase == .done {
                successContent
                    .frame(maxWidth: .infinity)
                    .transition(.blurReplace.combined(with: .scale(0.7)))
            } else {
                label(progress: progress, foreground: colors[0])
                label(progress: progress, foreground: .white)
                    .mask(alignment: .leading) {
                        Rectangle().frame(width: width * progress)
                    }
            }
        }
    }

    private func label(progress: CGFloat, foreground: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().stroke(foreground.opacity(0.25), lineWidth: 2.5)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(foreground, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .bold))
                    .symbolEffect(.wiggle, options: .repeat(.continuous), isActive: phase == .holding)
            }
            .frame(width: 30, height: 30)

            ZStack {
                Text(title).opacity(phase == .holding ? 0 : 1).blur(radius: phase == .holding ? 4 : 0)
                Text(holdingTitle).opacity(phase == .holding ? 1 : 0).blur(radius: phase == .holding ? 0 : 4)
            }
            .font(.system(size: 17, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(foreground)
        .frame(maxWidth: .infinity)
    }

    private var successContent: some View {
        HStack(spacing: 10) {
            Image(systemName: successImage)
                .font(.system(size: 17, weight: .heavy))
                .symbolEffect(.bounce, value: phase == .done)
            Text(successTitle)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(.white)
    }

    // MARK: Logic

    private func handlePress(_ pressing: Bool) {
        if pressing { beginHold() } else { endHold() }
    }

    private var glowOpacity: Double {
        switch phase {
        case .done: 0.45
        case .holding: 0.25
        default: 0
        }
    }

    /// Haptic ticks that rise in intensity as the hold nears completion.
    private func tickFeedback(_ value: Int) -> SensoryFeedback? {
        guard value > 0 else { return nil }
        return .impact(flexibility: .rigid, intensity: min(0.25 + Double(value) * 0.06, 1))
    }

    private func progress(at date: Date) -> CGFloat {
        switch phase {
        case .idle:
            return 0
        case .done:
            return 1
        case .holding:
            return min(max(CGFloat(date.timeIntervalSince(anchor) / duration), 0), 1)
        case .rewinding:
            let t = min(max(date.timeIntervalSince(anchor) / rewindDuration, 0), 1)
            let eased = 1 - pow(1 - t, 3)
            return rewindFrom * CGFloat(1 - eased)
        }
    }

    private func beginHold() {
        guard phase == .idle || phase == .rewinding else { return }
        // Resume from wherever the rewind currently is.
        let start = progress(at: .now)
        anchor = Date.now.addingTimeInterval(-Double(start) * duration)
        phase = .holding
        tick = 0

        holdTask?.cancel()
        holdTask = Task { @MainActor in
            let steps = 12
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(duration / Double(steps)))
                guard !Task.isCancelled, phase == .holding else { return }
                if progress(at: .now) >= 1 {
                    complete()
                    return
                }
                tick += 1
            }
        }
    }

    private func endHold() {
        guard phase == .holding else { return }
        holdTask?.cancel()
        rewindFrom = progress(at: .now)
        anchor = .now
        phase = .rewinding
        tick = 0

        holdTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(rewindDuration))
            guard !Task.isCancelled, phase == .rewinding else { return }
            phase = .idle
        }
    }

    private func complete() {
        guard phase != .done else { return }
        holdTask?.cancel()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { phase = .done }
        action()

        guard resetsAfterSuccess else { return }
        holdTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.8))
            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { phase = .idle }
        }
    }
}

// MARK: - Preview

#Preview("Hold To Confirm") {
    VStack(spacing: 18) {
        VStack(alignment: .leading, spacing: 6) {
            Text("Danger zone").font(.title2.bold())
            Text("Deleting this project removes 248 files for everyone.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        HoldToConfirmButton.destructive()
        HoldToConfirmButton("Hold to publish", systemImage: "paperplane.fill", successTitle: "Published")
    }
    .padding(24)
    .frame(maxHeight: .infinity)
    .background(Color(.systemBackground))
}
