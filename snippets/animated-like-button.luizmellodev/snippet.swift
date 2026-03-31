import SwiftUI

// MARK: - Animated Like Button
//
// A heart button that bursts into particles when liked.
// Tap to toggle. Inspired by Twitter/Instagram like interactions.

struct AnimatedLikeButton: View {
    @State private var isLiked = false
    @State private var bouncing = false
    @State private var particles: [LikeParticle] = []
    @State private var likeCount = 42

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                ForEach(particles) { p in
                    Circle()
                        .fill(p.color)
                        .frame(width: p.size, height: p.size)
                        .offset(x: p.offsetX, y: p.offsetY)
                        .opacity(p.opacity)
                }

                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(isLiked ? .red : .secondary)
                    .scaleEffect(bouncing ? 1.4 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.4), value: bouncing)
            }
            .frame(width: 64, height: 64)
            .onTapGesture { handleTap() }

            Text("\(likeCount)")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
                .contentTransition(.numericText(value: Double(likeCount)))
                .animation(.spring(response: 0.3), value: likeCount)
        }
    }

    private func handleTap() {
        isLiked.toggle()
        likeCount += isLiked ? 1 : -1

        guard isLiked else { return }

        bouncing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { bouncing = false }
        emitParticles()
    }

    private func emitParticles() {
        let colors: [Color] = [.red, .pink, .orange, .yellow, .purple]
        let count = 12
        particles = (0..<count).map { i in
            let angle = Double(i) / Double(count) * 2 * .pi
            return LikeParticle(
                color: colors[i % colors.count],
                size: CGFloat.random(in: 4...8),
                targetX: cos(angle) * CGFloat.random(in: 28...44),
                targetY: sin(angle) * CGFloat.random(in: 28...44)
            )
        }

        withAnimation(.easeOut(duration: 0.55)) {
            for i in particles.indices {
                particles[i].offsetX = particles[i].targetX
                particles[i].offsetY = particles[i].targetY
                particles[i].opacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { particles = [] }
    }
}

private struct LikeParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let targetX: CGFloat
    let targetY: CGFloat
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    var opacity: Double = 1
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        AnimatedLikeButton()
    }
}
