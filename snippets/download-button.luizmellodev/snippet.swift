import SwiftUI

// MARK: - Download Button

/// An App Store–style "GET" button built for long downloads.
///
/// **GET** → tap → the pill collapses into a circle with a *waiting* spinner →
/// a **progress ring** fills with a glowing head while liquid rises inside it
/// (tap the stop square to cancel and the ring unwinds back into the pill) →
/// the circle floods with color, a **checkmark draws itself**, then it
/// expands into **OPEN**. A failure shakes the ring and offers **RETRY**.
///
/// You own the download; the button only renders it. Drive it through the
/// `status` binding: the button sets `.preparing` when tapped (and calls
/// `onStart`), sets `.idle` when cancelled (and calls `onCancel`); you report
/// `.downloading(progress)`, then `.installed` or `.failed`.
public struct DownloadButton: View {
    /// What the download is doing right now.
    public enum Status: Equatable {
        case idle
        /// Queued / connecting — shows a spinner before bytes arrive.
        case preparing
        /// 0...1
        case downloading(Double)
        case installed
        case failed
    }

    /// `.compact` is the App Store list-row size; `.large` is a hero button
    /// with a live percentage / size readout underneath.
    public enum Variant { case compact, large }

    @Binding var status: Status
    var variant: Variant
    var title: String
    var openTitle: String
    var retryTitle: String
    var fileSize: Int64?
    var tint: Color
    var onStart: () -> Void
    var onCancel: () -> Void
    var onOpen: () -> Void

    private enum Stage: Equatable { case pill, spinner, ring, check }

    @State private var stage: Stage
    @State private var shownProgress: Double
    @State private var checkDrawn: CGFloat = 0
    @State private var shakes = 0
    @State private var celebrate = 0
    @State private var sequence: Task<Void, Never>?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        status: Binding<Status>,
        variant: Variant = .compact,
        title: String = "GET",
        openTitle: String = "OPEN",
        retryTitle: String = "RETRY",
        fileSize: Int64? = nil,
        tint: Color = .blue,
        onStart: @escaping () -> Void = {},
        onCancel: @escaping () -> Void = {},
        onOpen: @escaping () -> Void = {}
    ) {
        self._status = status
        self.variant = variant
        self.title = title
        self.openTitle = openTitle
        self.retryTitle = retryTitle
        self.fileSize = fileSize
        self.tint = tint
        self.onStart = onStart
        self.onCancel = onCancel
        self.onOpen = onOpen
        let initial = status.wrappedValue
        self._stage = State(initialValue: Self.restingStage(for: initial))
        self._shownProgress = State(initialValue: Self.progress(of: initial))
    }

    // MARK: Metrics

    private var isLarge: Bool { variant == .large }
    private var pillSize: CGSize { isLarge ? CGSize(width: 200, height: 52) : CGSize(width: 76, height: 30) }
    private var diameter: CGFloat { isLarge ? 64 : 30 }
    private var lineWidth: CGFloat { isLarge ? 4.5 : 2.5 }
    private var failed: Bool { status == .failed }
    private var accent: Color { failed ? .red : tint }

    private var shapeSize: CGSize {
        stage == .pill ? pillSize : CGSize(width: diameter, height: diameter)
    }

    // MARK: Body

    public var body: some View {
        VStack(spacing: 12) {
            Button(action: handleTap) {
                control
                    .frame(width: pillSize.width, height: max(pillSize.height, diameter),
                           alignment: isLarge ? .center : .trailing)
                    .contentShape(Rectangle())
            }
            .buttonStyle(DownloadPressStyle())

            if isLarge { details }
        }
        .onChange(of: status) { old, new in transition(from: old, to: new) }
        .sensoryFeedback(trigger: status) { old, new in feedback(from: old, to: new) }
        .sensoryFeedback(trigger: milestone) { old, new in
            new > old && new < 4 ? .impact(weight: .light, intensity: 0.45) : nil
        }
        .onDisappear { sequence?.cancel() }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
        .accessibilityHint(accessibilityHint)
        .accessibilityAction { handleTap() }
    }

    private var control: some View {
        ZStack {
            Capsule()
                .fill(surfaceFill)
                .frame(width: shapeSize.width, height: shapeSize.height)

            switch stage {
            case .pill:
                pillLabel
                    .transition(.opacity.combined(with: .scale(scale: 0.6)))
            case .spinner:
                spinner
                    .transition(.opacity)
            case .ring:
                ring
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            case .check:
                DownloadCheckmark()
                    .trim(from: 0, to: checkDrawn)
                    .stroke(.white, style: StrokeStyle(lineWidth: isLarge ? 4 : 2.5, lineCap: .round, lineJoin: .round))
                    .frame(width: diameter * 0.42, height: diameter * 0.42)
                    .transition(.opacity)
            }
        }
        .frame(width: max(shapeSize.width, diameter), height: max(shapeSize.height, diameter))
        .background {
            // Soft bloom when the download lands.
            Circle()
                .fill(tint)
                .frame(width: diameter, height: diameter)
                .blur(radius: isLarge ? 20 : 10)
                .opacity(stage == .check ? 0.55 : 0)
        }
        .keyframeAnimator(initialValue: CGFloat(1), trigger: celebrate) { content, scale in
            content.scaleEffect(scale)
        } keyframes: { _ in
            KeyframeTrack {
                SpringKeyframe(1.14, duration: 0.16, spring: .snappy)
                SpringKeyframe(1.0, duration: 0.45, spring: .bouncy)
            }
        }
        .keyframeAnimator(initialValue: CGFloat(0), trigger: shakes) { content, x in
            content.offset(x: x)
        } keyframes: { _ in
            KeyframeTrack {
                CubicKeyframe(-7, duration: 0.06)
                CubicKeyframe(6, duration: 0.08)
                CubicKeyframe(-4, duration: 0.08)
                CubicKeyframe(2, duration: 0.07)
                CubicKeyframe(0, duration: 0.07)
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.78), value: stage)
        .animation(.easeInOut(duration: 0.25), value: failed)
    }

    private var surfaceFill: Color {
        switch stage {
        case .pill:
            if isLarge { return accent }
            return Color(.tertiarySystemFill)
        case .spinner, .ring:
            return isLarge ? tint.opacity(0.08) : .clear
        case .check:
            return tint
        }
    }

    // MARK: Stages

    private var pillLabel: some View {
        let text: String = {
            switch status {
            case .installed: return openTitle
            case .failed: return retryTitle
            default: return title
            }
        }()
        return HStack(spacing: 6) {
            if isLarge {
                Image(systemName: failed ? "arrow.clockwise" : status == .installed ? "arrow.up.forward.app.fill" : "icloud.and.arrow.down.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .contentTransition(.symbolEffect(.replace))
            }
            Text(text)
                .font(.system(size: isLarge ? 17 : 15, weight: isLarge ? .semibold : .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(isLarge ? Color.white : accent)
        .id(text)
        .transition(.blurReplace)
    }

    private var spinner: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            Circle()
                .trim(from: 0, to: 0.72)
                .stroke(Color.secondary.opacity(0.55), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(reduceMotion ? 0 : (t * 400).truncatingRemainder(dividingBy: 360)))
        }
        .frame(width: diameter - lineWidth, height: diameter - lineWidth)
    }

    private var ring: some View {
        let inner = diameter - lineWidth
        let p = shownProgress
        return ZStack {
            // Liquid rising inside the ring.
            TimelineView(.animation(paused: reduceMotion || stage != .ring)) { context in
                let t = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate
                ZStack {
                    DownloadWave(level: p, phase: t * 2.6, amplitude: 0.07, frequency: 1.1)
                        .fill(accent.opacity(0.14))
                    DownloadWave(level: p, phase: -t * 3.4 + 1.3, amplitude: 0.05, frequency: 1.6)
                        .fill(accent.opacity(0.22))
                }
            }
            .frame(width: inner - lineWidth, height: inner - lineWidth)
            .clipShape(Circle())

            Circle()
                .stroke(Color(.systemFill), lineWidth: lineWidth)

            // Progress arc: dim tail → bright head.
            Circle()
                .trim(from: 0, to: p)
                .stroke(
                    AngularGradient(
                        colors: [accent.opacity(0.35), accent],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(max(360 * p, 1))
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Trailing glow at the head of the arc.
            let angle = Angle.degrees(360 * p - 90).radians
            ZStack {
                Circle().fill(accent).frame(width: lineWidth * 3.2, height: lineWidth * 3.2).blur(radius: lineWidth * 1.2)
                Circle().fill(.white.opacity(0.9)).frame(width: lineWidth * 0.7, height: lineWidth * 0.7)
            }
            .offset(x: cos(angle) * inner / 2, y: sin(angle) * inner / 2)
            .opacity(p > 0.015 && p < 0.995 ? 1 : 0)

            // Stop square.
            RoundedRectangle(cornerRadius: isLarge ? 4 : 2, style: .continuous)
                .fill(accent)
                .frame(width: isLarge ? 18 : 9, height: isLarge ? 18 : 9)
        }
        .frame(width: inner, height: inner)
    }

    // MARK: Details (large variant)

    private var details: some View {
        Group {
            switch status {
            case .idle:
                Text(fileSize.map { $0.formatted(.byteCount(style: .file)) } ?? " ")
                    .foregroundStyle(.secondary)
            case .preparing:
                Text("Waiting…")
                    .foregroundStyle(.secondary)
            case .downloading(let p):
                HStack(spacing: 6) {
                    Text("\(Int((p * 100).rounded(.down)))%")
                        .foregroundStyle(.primary)
                        .fontWeight(.semibold)
                        .contentTransition(.numericText(value: p))
                    if let fileSize {
                        Text("·").foregroundStyle(.tertiary)
                        Text("\(Int64(Double(fileSize) * p).formatted(.byteCount(style: .file))) of \(fileSize.formatted(.byteCount(style: .file)))")
                            .foregroundStyle(.secondary)
                            .contentTransition(.numericText(value: p))
                    }
                }
            case .installed:
                Label("Installed", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            case .failed:
                Label("Download failed", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            }
        }
        .font(.system(size: 14, weight: .medium, design: .rounded))
        .monospacedDigit()
        .frame(height: 18)
        .animation(.snappy(duration: 0.2), value: status)
    }

    // MARK: Logic

    private var milestone: Int {
        if case .downloading(let p) = status { return Int(p * 4) }
        return 0
    }

    private func handleTap() {
        guard stage != .check else { return }
        switch status {
        case .idle, .failed:
            status = .preparing
            onStart()
        case .preparing, .downloading:
            status = .idle
            onCancel()
        case .installed:
            onOpen()
        }
    }

    private func transition(from old: Status, to new: Status) {
        switch new {
        case .preparing:
            sequence?.cancel()
            shownProgress = 0
            stage = .spinner

        case .downloading(let p):
            if stage != .ring {
                sequence?.cancel()
                stage = .ring
            }
            withAnimation(.linear(duration: 0.12)) { shownProgress = min(max(p, 0), 1) }

        case .idle:
            sequence?.cancel()
            if stage == .ring {
                // Cancelled: unwind the ring, then grow back into the pill.
                withAnimation(.easeOut(duration: 0.3)) { shownProgress = 0 }
                sequence = Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.26))
                    guard !Task.isCancelled else { return }
                    stage = .pill
                }
            } else {
                shownProgress = 0
                stage = .pill
            }

        case .installed:
            sequence?.cancel()
            withAnimation(.easeOut(duration: 0.18)) { shownProgress = 1 }
            sequence = Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.2))
                guard !Task.isCancelled else { return }
                checkDrawn = 0
                stage = .check
                celebrate += 1
                withAnimation(.easeOut(duration: 0.35).delay(0.12)) { checkDrawn = 1 }
                try? await Task.sleep(for: .seconds(0.95))
                guard !Task.isCancelled else { return }
                stage = .pill
            }

        case .failed:
            sequence?.cancel()
            if !reduceMotion { shakes += 1 }
            sequence = Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.45))
                guard !Task.isCancelled else { return }
                stage = .pill
                shownProgress = 0
            }
        }
    }

    private func feedback(from old: Status, to new: Status) -> SensoryFeedback? {
        switch new {
        case .preparing: return .impact(weight: .medium)
        case .installed: return .success
        case .failed: return .error
        case .idle:
            switch old {
            case .preparing, .downloading: return .impact(weight: .light)
            default: return nil
            }
        case .downloading: return nil
        }
    }

    private static func restingStage(for status: Status) -> Stage {
        switch status {
        case .idle, .installed, .failed: return .pill
        case .preparing: return .spinner
        case .downloading: return .ring
        }
    }

    private static func progress(of status: Status) -> Double {
        if case .downloading(let p) = status { return p }
        return 0
    }

    // MARK: Accessibility

    private var accessibilityLabel: String {
        switch status {
        case .idle: return title.capitalized
        case .preparing, .downloading: return "Downloading"
        case .installed: return openTitle.capitalized
        case .failed: return "Download failed"
        }
    }

    private var accessibilityValue: String {
        switch status {
        case .preparing: return "Waiting"
        case .downloading(let p): return "\(Int(p * 100)) percent"
        default: return ""
        }
    }

    private var accessibilityHint: String {
        switch status {
        case .idle: return "Starts the download"
        case .preparing, .downloading: return "Double-tap to cancel"
        case .installed: return "Opens the item"
        case .failed: return "Double-tap to retry"
        }
    }
}

// MARK: - Pieces

private struct DownloadPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// A sine-wave liquid surface sitting at `level` (0 = empty, 1 = full).
/// Amplitude eases to zero at both ends so it starts and finishes flat.
private struct DownloadWave: Shape {
    var level: Double
    var phase: Double
    var amplitude: Double
    var frequency: Double

    var animatableData: Double {
        get { level }
        set { level = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let clamped = min(max(level, 0), 1)
        let baseline = rect.maxY - rect.height * clamped
        let amp = rect.height * amplitude * sin(.pi * clamped)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        var x: CGFloat = 0
        while x <= rect.width {
            let rel = Double(x / rect.width)
            let y = baseline + amp * sin(rel * .pi * 2 * frequency + phase)
            path.addLine(to: CGPoint(x: rect.minX + x, y: y))
            x += 1.5
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: baseline + amp * sin(.pi * 2 * frequency + phase)))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct DownloadCheckmark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY + rect.height * 0.05))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.37, y: rect.maxY - rect.height * 0.08))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.1))
        return path
    }
}

// MARK: - Preview

#Preview("Download Button") {
    struct PreviewHost: View {
        @State private var row: DownloadButton.Status = .idle
        @State private var hero: DownloadButton.Status = .idle
        @State private var tasks: [String: Task<Void, Never>] = [:]

        var body: some View {
            VStack(spacing: 48) {
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom))
                        .frame(width: 60, height: 60)
                        .overlay(Image(systemName: "cloud.sun.fill").font(.title2).foregroundStyle(.white))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nimbus").font(.headline)
                        Text("Weather, beautifully").font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    DownloadButton(status: $row, onStart: { run("row", $row) }, onCancel: { tasks["row"]?.cancel() })
                }
                .padding(.horizontal, 20)

                DownloadButton(
                    status: $hero,
                    variant: .large,
                    title: "Download",
                    openTitle: "Open",
                    retryTitle: "Retry",
                    fileSize: 48_300_000,
                    tint: .indigo,
                    onStart: { run("hero", $hero) },
                    onCancel: { tasks["hero"]?.cancel() }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }

        private func run(_ key: String, _ status: Binding<DownloadButton.Status>) {
            tasks[key]?.cancel()
            tasks[key] = Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.4))
                var p = 0.0
                while p < 1, !Task.isCancelled {
                    status.wrappedValue = .downloading(p)
                    try? await Task.sleep(for: .milliseconds(50))
                    p = min(p + .random(in: 0.012...0.03), 1)
                }
                guard !Task.isCancelled else { return }
                status.wrappedValue = .installed
            }
        }
    }
    return PreviewHost()
}
