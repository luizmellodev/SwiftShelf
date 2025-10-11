import SwiftUI

struct ColorfulShadowButton: View {
    @State private var animationOffset: CGFloat = 0
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Press animation
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }) {
            Text("Tap Me")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .shadow(
                    color: getAnimatedShadowColor(),
                    radius: 20,
                    x: 0,
                    y: 8
                )
                .shadow(
                    color: getAnimatedShadowColor().opacity(0.3),
                    radius: 40,
                    x: 0,
                    y: 16
                )
        }
        .onAppear {
            startColorAnimation()
        }
    }
    
    private func getAnimatedShadowColor() -> Color {
        let colors: [Color] = [
            .red, .orange, .yellow, .green, 
            .blue, .purple, .pink, .cyan
        ]
        
        let index = Int(animationOffset) % colors.count
        let nextIndex = (index + 1) % colors.count
        
        let progress = animationOffset - CGFloat(index)
        let currentColor = colors[index]
        let nextColor = colors[nextIndex]
        
        return Color(
            red: interpolate(from: currentColor.components.red, to: nextColor.components.red, progress: progress),
            green: interpolate(from: currentColor.components.green, to: nextColor.components.green, progress: progress),
            blue: interpolate(from: currentColor.components.blue, to: nextColor.components.blue, progress: progress)
        )
    }
    
    private func startColorAnimation() {
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            animationOffset = 8.0
        }
    }
    
    private func interpolate(from: Double, to: Double, progress: Double) -> Double {
        return from + (to - from) * progress
    }
}

// Extension to get color components
extension Color {
    var components: (red: Double, green: Double, blue: Double, alpha: Double) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b), Double(a))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ColorfulShadowButton()
    }
}
