import SwiftUI

// MARK: - Bank Card Flip
//
// A credit card that flips in 3D on tap, revealing the back (CVV side).
// Uses rotation3DEffect with a FlipModifier that auto-hides each face
// at the 90° midpoint for a seamless two-sided effect.

struct BankCardFlip: View {
    @State private var flipped = false

    var body: some View {
        ZStack {
            CardFace()
                .modifier(FlipModifier(angle: flipped ? 180 : 0))

            CardBack()
                .modifier(FlipModifier(angle: flipped ? 0 : -180))
        }
        .animation(.spring(response: 0.65, dampingFraction: 0.78), value: flipped)
        .onTapGesture { flipped.toggle() }
    }
}

// MARK: - Flip Modifier

private struct FlipModifier: ViewModifier, Animatable {
    var angle: Double

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), perspective: 0.35)
            .opacity(abs(angle) <= 90 ? 1 : 0)
    }
}

// MARK: - Card Front

private struct CardFace: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.13, green: 0.13, blue: 0.28), Color(red: 0.25, green: 0.1, blue: 0.45)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 220, height: 220)
                .offset(x: 160, y: -60)

            Circle()
                .fill(.white.opacity(0.04))
                .frame(width: 160, height: 160)
                .offset(x: -40, y: 120)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.85, green: 0.72, blue: 0.35), Color(red: 0.95, green: 0.85, blue: 0.55)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.yellow.opacity(0.4), lineWidth: 0.5)
                        )

                    Spacer()

                    HStack(spacing: -10) {
                        Circle()
                            .fill(Color.red.opacity(0.85))
                            .frame(width: 30, height: 30)
                        Circle()
                            .fill(Color.orange.opacity(0.85))
                            .frame(width: 30, height: 30)
                    }
                }

                Spacer()

                Text("4512  3456  7890  1234")
                    .font(.system(size: 17, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.9))
                    .tracking(2)

                Spacer().frame(height: 18)

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("CARD HOLDER")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("John Appleseed")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 3) {
                        Text("EXPIRES")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("08 / 28")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
            }
            .padding(24)
        }
        .frame(width: 340, height: 210)
        .shadow(color: .black.opacity(0.35), radius: 24, y: 12)
    }
}

// MARK: - Card Back

private struct CardBack: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.18, green: 0.1, blue: 0.32), Color(red: 0.12, green: 0.12, blue: 0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 0) {
                Spacer().frame(height: 28)

                Rectangle()
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                    .frame(height: 46)

                Spacer().frame(height: 20)

                HStack(spacing: 10) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white.opacity(0.9))
                            .frame(height: 36)

                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(0..<4) { _ in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(red: 0.5, green: 0.6, blue: 0.9).opacity(0.25))
                                    .frame(height: 4)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                    }

                    VStack(spacing: 3) {
                        Text("CVV")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.5))
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.white.opacity(0.12))
                                .frame(width: 54, height: 36)
                            Text("• • •")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                HStack {
                    Spacer()
                    Text("SWIFT BANK")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.35))
                        .tracking(3)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 340, height: 210)
        .shadow(color: .black.opacity(0.35), radius: 24, y: 12)
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.mint.opacity(0.3), .teal.opacity(0.3)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        VStack(spacing: 16) {
            BankCardFlip()
            Text("Tap to flip")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
