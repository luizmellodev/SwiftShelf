import SwiftUI

// MARK: - Download Button
//
// Developer drives progress externally via @Binding:
//   - Set progress to any value in 0.0...1.0 as download advances
//   - Button auto-transitions: idle → downloading → downloaded
//   - Call onTap to start your download logic
//
// Example usage:
//   @State var progress: Double = 0
//   DownloadButton(progress: $progress) { startMyDownload() }

struct DownloadButton: View {
    @Binding var progress: Double
    var onTap: () -> Void

    @State private var phase: DownloadPhase = .idle
    @State private var checkProgress: CGFloat = 0
    @State private var confetti: [ConfettiPiece] = []

    private let h: CGFloat = 52
    private let w: CGFloat = 220

    var body: some View {
        ZStack {
            ForEach(confetti) { ConfettiParticleView(piece: $0) }

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(phase == .downloaded ? Color.green : Color.blue)
                    .animation(.easeInOut(duration: 0.35), value: phase)

                ZStack {
                    if phase == .idle {
                        idleContent
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    }
                    if phase == .downloading {
                        downloadingContent
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    }
                    if phase == .downloaded {
                        downloadedContent
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    }
                }
                .animation(.spring(response: 0.38, dampingFraction: 0.82), value: phase)
            }
            .frame(width: w, height: h)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: (phase == .downloaded ? Color.green : Color.blue).opacity(0.4),
                radius: 14,
                y: 7
            )
            .animation(.easeInOut(duration: 0.35), value: phase)
        }
        .onTapGesture {
            guard phase == .idle else { return }
            withAnimation { phase = .downloading }
            onTap()
        }
        .onChange(of: progress) { _, newValue in
            if newValue >= 1.0, phase == .downloading {
                finish()
            }
        }
    }

    private var idleContent: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 18, weight: .semibold))
            Text("Download")
                .font(.system(size: 16, weight: .semibold))
        }
        .foregroundStyle(.white)
    }

    private var downloadingContent: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.25))
                    Capsule()
                        .fill(.white)
                        .frame(width: geo.size.width * CGFloat(progress))
                        .animation(.linear(duration: 0.1), value: progress)
                }
            }
            .frame(height: 5)
            .padding(.horizontal, 24)

            Text("\(Int(progress * 100))%")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))
                .contentTransition(.numericText(value: progress * 100))
                .animation(.linear(duration: 0.1), value: Int(progress * 100))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var downloadedContent: some View {
        HStack(spacing: 8) {
            CheckmarkPath(progress: checkProgress)
                .stroke(.white, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .frame(width: 20, height: 20)
            Text("Downloaded!")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private func finish() {
        withAnimation { phase = .downloaded }
        spawnConfetti()
        withAnimation(.easeOut(duration: 0.4).delay(0.25)) { checkProgress = 1.0 }
    }

    func reset() {
        withAnimation { phase = .idle }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { checkProgress = 0 }
    }

    private func spawnConfetti() {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .cyan, .mint]
        confetti = (0..<28).map { i in
            ConfettiPiece(
                color: colors[i % colors.count],
                size: CGFloat.random(in: 5...11),
                angle: Double(i) / 28.0 * 360.0 + Double.random(in: -18...18),
                distance: CGFloat.random(in: 55...120),
                rotation: Double.random(in: 0...360),
                delay: Double.random(in: 0...0.12),
                isCircle: i % 3 != 0
            )
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { confetti = [] }
    }
}

// MARK: - Supporting Types

private enum DownloadPhase { case idle, downloading, downloaded }

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let angle: Double
    let distance: CGFloat
    let rotation: Double
    let delay: Double
    let isCircle: Bool
}

private struct ConfettiParticleView: View {
    let piece: ConfettiPiece
    @State private var spread = false

    var body: some View {
        Group {
            if piece.isCircle {
                Circle().fill(piece.color)
            } else {
                RoundedRectangle(cornerRadius: 2).fill(piece.color)
            }
        }
        .frame(width: piece.size, height: piece.size)
        .rotationEffect(.degrees(spread ? piece.rotation : 0))
        .offset(
            x: spread ? cos(piece.angle * .pi / 180) * piece.distance : 0,
            y: spread ? sin(piece.angle * .pi / 180) * piece.distance : 0
        )
        .opacity(spread ? 0 : 1)
        .onAppear {
            withAnimation(.easeOut(duration: 0.75).delay(piece.delay)) { spread = true }
        }
    }
}

private struct CheckmarkPath: Shape {
    var progress: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let p1 = CGPoint(x: rect.minX + 1, y: rect.midY + 1)
        let p2 = CGPoint(x: rect.minX + rect.width * 0.38, y: rect.maxY - 2)
        let p3 = CGPoint(x: rect.maxX - 1, y: rect.minY + 2)

        let seg1 = dist(p1, p2)
        let seg2 = dist(p2, p3)
        let target = (seg1 + seg2) * progress

        var path = Path()
        guard target > 0 else { return path }
        path.move(to: p1)

        if target <= seg1 {
            path.addLine(to: lerp(p1, p2, t: target / seg1))
        } else {
            path.addLine(to: p2)
            path.addLine(to: lerp(p2, p3, t: min((target - seg1) / seg2, 1)))
        }
        return path
    }

    private func dist(_ a: CGPoint, _ b: CGPoint) -> CGFloat { hypot(b.x - a.x, b.y - a.y) }

    private func lerp(_ a: CGPoint, _ b: CGPoint, t: CGFloat) -> CGPoint {
        CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var progress: Double = 0
        @State private var timer: Timer?

        var body: some View {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                DownloadButton(progress: $progress) {
                    simulateDownload()
                }
            }
        }

        func simulateDownload() {
            progress = 0
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
                progress = min(progress + Double.random(in: 0.008...0.025), 1.0)
                if progress >= 1.0 { t.invalidate() }
            }
        }
    }

    return PreviewWrapper()
}
