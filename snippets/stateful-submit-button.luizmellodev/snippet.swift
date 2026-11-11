import SwiftUI

// MARK: - Stateful Submit Button

/// A submit button that tells the whole story of an async action in one shape:
///
/// **idle** → tap → **loading** (the pill squeezes into a circle with a spinner)
/// → **success** (turns green, a checkmark draws itself, then it relaxes back)
/// or **failure** (turns red, shakes, and offers "Try again").
///
/// The action is `async throws`: return normally for success, throw for failure.
public struct StatefulSubmitButton: View {
    let title: String
    var systemImage: String?
    var successTitle: String
    var failureTitle: String
    var gradient: [Color]
    var height: CGFloat
    var resetDelay: Duration
    let action: () async throws -> Void

    private enum Phase: Equatable { case idle, loading, success, failure }

    @State private var phase: Phase = .idle
    @State private var shakes: CGFloat = 0

    public init(
        _ title: String,
        systemImage: String? = nil,
        successTitle: String = "Done",
        failureTitle: String = "Try again",
        gradient: [Color] = [.indigo, .purple],
        height: CGFloat = 58,
        resetDelay: Duration = .seconds(2),
        action: @escaping () async throws -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.successTitle = successTitle
        self.failureTitle = failureTitle
        self.gradient = gradient
        self.height = height
        self.resetDelay = resetDelay
        self.action = action
    }

    private var isCircle: Bool { phase == .loading }

    private var fill: [Color] {
        switch phase {
        case .idle, .loading: gradient
        case .success: [Color(red: 0.2, green: 0.78, blue: 0.42), Color(red: 0.1, green: 0.66, blue: 0.52)]
        case .failure: [Color(red: 1.0, green: 0.36, blue: 0.36), Color(red: 0.9, green: 0.2, blue: 0.38)]
        }
    }

    public var body: some View {
        Button(action: submit) {
            ZStack {
                label
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: isCircle ? height : .infinity)
            .frame(height: height)
            .background {
                Capsule()
                    .fill(LinearGradient(colors: fill, startPoint: .leading, endPoint: .trailing))
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                LinearGradient(colors: [.white.opacity(0.45), .white.opacity(0.05)], startPoint: .top, endPoint: .bottom),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: (fill.last ?? .accentColor).opacity(0.4), radius: isCircle ? 10 : 18, y: 8)
            }
            .contentShape(Capsule())
        }
        .buttonStyle(StatefulSubmitPressStyle())
        .disabled(phase == .loading || phase == .success)
        .frame(maxWidth: .infinity)
        .animation(.spring(response: 0.5, dampingFraction: 0.78), value: phase)
        .modifier(StatefulSubmitShake(shakes: shakes))
        .sensoryFeedback(trigger: phase) { _, new in
            switch new {
            case .loading: .impact(weight: .light)
            case .success: .success
            case .failure: .error
            case .idle: nil
            }
        }
        .accessibilityLabel(accessibilityTitle)
        .accessibilityAddTraits(.updatesFrequently)
    }

    // MARK: Label

    @ViewBuilder
    private var label: some View {
        switch phase {
        case .idle:
            HStack(spacing: 8) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title)
            }
            .transition(.blurReplace)

        case .loading:
            StatefulSubmitSpinner()
                .frame(width: 24, height: 24)
                .transition(.scale(scale: 0.3).combined(with: .opacity))

        case .success:
            HStack(spacing: 10) {
                StatefulSubmitCheck()
                    .frame(width: 20, height: 20)
                Text(successTitle)
            }
            .transition(.scale(scale: 0.6).combined(with: .opacity))

        case .failure:
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise")
                    .fontWeight(.bold)
                Text(failureTitle)
            }
            .transition(.blurReplace)
        }
    }

    private var accessibilityTitle: String {
        switch phase {
        case .idle: title
        case .loading: "Loading"
        case .success: successTitle
        case .failure: failureTitle
        }
    }

    // MARK: Logic

    private func submit() {
        guard phase == .idle || phase == .failure else { return }
        Task { @MainActor in
            phase = .loading
            do {
                try await action()
                phase = .success
                try? await Task.sleep(for: resetDelay)
                if phase == .success { phase = .idle }
            } catch {
                phase = .failure
                withAnimation(.linear(duration: 0.5)) { shakes += 1 }
            }
        }
    }
}

// MARK: - Helpers

/// Horizontal shake: one full `shakes` step = 3 damped oscillations.
private struct StatefulSubmitShake: GeometryEffect {
    var shakes: CGFloat

    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let t = shakes - shakes.rounded(.down)
        let damping = 1 - t
        let x = sin(t * .pi * 6) * 12 * damping
        return ProjectionTransform(CGAffineTransform(translationX: x, y: 0))
    }
}

private struct StatefulSubmitSpinner: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let angle = (time * 400).truncatingRemainder(dividingBy: 360)
            let breathe = 0.35 + 0.3 * (sin(time * 3) + 1) / 2
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.25), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: breathe)
                    .stroke(.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(angle))
            }
        }
    }
}

private struct StatefulSubmitCheckShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.midY + rect.height * 0.04))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.38, y: rect.maxY - rect.height * 0.14))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.06, y: rect.minY + rect.height * 0.16))
        return path
    }
}

private struct StatefulSubmitCheck: View {
    @State private var drawn = false

    var body: some View {
        StatefulSubmitCheckShape()
            .trim(from: 0, to: drawn ? 1 : 0)
            .stroke(.white, style: StrokeStyle(lineWidth: 3.2, lineCap: .round, lineJoin: .round))
            .onAppear {
                withAnimation(.easeOut(duration: 0.4).delay(0.15)) { drawn = true }
            }
    }
}

private struct StatefulSubmitPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

private struct StatefulSubmitPreviewError: Error {}

#Preview("Stateful Submit Button") {
    VStack(spacing: 20) {
        StatefulSubmitButton("Place order", systemImage: "bag.fill") {
            try await Task.sleep(for: .seconds(1.5))
        }

        StatefulSubmitButton("Sync now", systemImage: "arrow.triangle.2.circlepath", gradient: [.orange, .pink]) {
            try await Task.sleep(for: .seconds(1.2))
            throw StatefulSubmitPreviewError()
        }
    }
    .padding(24)
}
