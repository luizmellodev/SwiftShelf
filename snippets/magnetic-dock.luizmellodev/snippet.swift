import SwiftUI

// MARK: - Magnetic Dock
//
// A macOS-style dock bar that magnifies icons based on finger proximity.
// Drag or tap anywhere on the dock to trigger the magnification effect.

struct MagneticDock: View {
    private let items: [(icon: String, color: Color, label: String)] = [
        ("phone.fill", .green, "Phone"),
        ("message.fill", .green, "Messages"),
        ("safari.fill", .blue, "Safari"),
        ("envelope.fill", .blue, "Mail"),
        ("camera.fill", Color(.systemGray2), "Camera"),
    ]

    @State private var touchX: CGFloat? = nil

    private let itemSize: CGFloat = 52
    private let spacing: CGFloat = 14
    private let hPadding: CGFloat = 16
    private let magnifyRadius: CGFloat = 72
    private let maxScale: CGFloat = 1.65

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(items.indices, id: \.self) { i in
                let cx = hPadding + CGFloat(i) * (itemSize + spacing) + itemSize / 2
                let scale = scaleFor(cx)
                let t = (scale - 1) / (maxScale - 1)

                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 14 + 6 * t)
                        .fill(items[i].color.gradient)
                        .overlay(
                            Image(systemName: items[i].icon)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(.white)
                        )
                        .frame(width: itemSize, height: itemSize)
                        .scaleEffect(scale, anchor: .bottom)

                    Text(items[i].label)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                        .opacity(t > 0.3 ? 1 : 0)
                }
                .animation(.spring(response: 0.25, dampingFraction: 0.65), value: scale)
            }
        }
        .padding(.horizontal, hPadding)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28))
        .coordinateSpace(name: "dock")
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("dock"))
                .onChanged { v in touchX = v.location.x }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        touchX = nil
                    }
                }
        )
    }

    private func scaleFor(_ cx: CGFloat) -> CGFloat {
        guard let tx = touchX else { return 1 }
        let d = abs(tx - cx)
        guard d < magnifyRadius else { return 1 }
        let t = 1 - d / magnifyRadius
        let smooth = t * t * (3 - 2 * t)
        return 1 + (maxScale - 1) * smooth
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.indigo, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.5)
        .ignoresSafeArea()

        VStack {
            Spacer()
            MagneticDock()
                .padding(.bottom, 48)
        }
    }
}
