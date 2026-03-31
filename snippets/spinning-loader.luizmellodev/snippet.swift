import SwiftUI

// MARK: - Spinning Loader
//
// Two concentric arcs that alternate expand/collapse phases while rotating.
// Outer arc has a gradient stroke; inner arc is semi-transparent.
// Inspired by the SpinningView pattern from SwiftUI-Animations.

struct SpinningLoader: View {
    @State private var outerEnd: CGFloat = 0.7
    @State private var innerEnd: CGFloat = 0.15
    @State private var outerAngle: Double = 0
    @State private var innerAngle: Double = 0

    private let outerSize: CGFloat = 68
    private let innerSize: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .stroke(.secondary.opacity(0.1), lineWidth: 4)
                .frame(width: outerSize, height: outerSize)

            Circle()
                .stroke(.secondary.opacity(0.08), lineWidth: 3)
                .frame(width: innerSize, height: innerSize)

            Circle()
                .trim(from: 0.04, to: outerEnd)
                .stroke(
                    LinearGradient(
                        colors: [.blue, .indigo, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: outerSize, height: outerSize)
                .rotationEffect(.degrees(outerAngle - 90))

            Circle()
                .trim(from: 0.08, to: innerEnd)
                .stroke(
                    Color.indigo.opacity(0.55),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: innerSize, height: innerSize)
                .rotationEffect(.degrees(innerAngle - 90))
        }
        .onAppear { runCycle() }
    }

    private func runCycle() {
        withAnimation(.easeInOut(duration: 0.65)) {
            outerEnd = 0.78
            innerEnd = 0.08
            outerAngle += 365
            innerAngle += 400
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeInOut(duration: 0.65)) {
                outerEnd = 0.15
                innerEnd = 0.72
                outerAngle += 320
                innerAngle += 275
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            runCycle()
        }
    }
}

#Preview {
    ZStack {
        Color(.systemBackground).ignoresSafeArea()
        VStack(spacing: 32) {
            SpinningLoader()

            HStack(spacing: 40) {
                SpinningLoader()
                    .scaleEffect(0.6)
                SpinningLoader()
                    .scaleEffect(0.6)
                SpinningLoader()
                    .scaleEffect(0.6)
            }
        }
    }
}
