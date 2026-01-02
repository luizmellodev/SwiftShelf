import SwiftUI

// MARK: - Shimmer Button Style
public struct ShimmerButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let shimmerColor: Color
    let cornerRadius: CGFloat
    let height: CGFloat
    let fontSize: CGFloat
    let fontWeight: Font.Weight
    let shadowRadius: CGFloat
    let shimmerSpeed: Double
    
    public init(
        backgroundColor: Color = .blue,
        foregroundColor: Color = .white,
        shimmerColor: Color = .white.opacity(0.6),
        cornerRadius: CGFloat = 12,
        height: CGFloat = 56,
        fontSize: CGFloat = 17,
        fontWeight: Font.Weight = .semibold,
        shadowRadius: CGFloat = 8,
        shimmerSpeed: Double = 2.0
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.shimmerColor = shimmerColor
        self.cornerRadius = cornerRadius
        self.height = height
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.shadowRadius = shadowRadius
        self.shimmerSpeed = shimmerSpeed
    }
    
    public static let `default` = ShimmerButtonStyle()
    public static let success = ShimmerButtonStyle(backgroundColor: .green)
    public static let danger = ShimmerButtonStyle(backgroundColor: .red)
    public static let warning = ShimmerButtonStyle(backgroundColor: .orange)
    public static let gradient = ShimmerButtonStyle(
        backgroundColor: .purple,
        shimmerColor: .pink.opacity(0.6)
    )
}

// MARK: - Shimmer Effect Modifier
struct ShimmerEffect: ViewModifier {
    let shimmerColor: Color
    let speed: Double
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            shimmerColor,
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                    .mask(content)
                }
            )
            .onAppear {
                withAnimation(
                    .linear(duration: speed)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer(color: Color, speed: Double = 2.0) -> some View {
        modifier(ShimmerEffect(shimmerColor: color, speed: speed))
    }
}

// MARK: - Shimmer Button
public struct ShimmerButton: View {
    let title: String
    let icon: String?
    let style: ShimmerButtonStyle
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var scale: CGFloat = 1.0
    
    public init(
        _ title: String,
        icon: String? = nil,
        style: ShimmerButtonStyle = .default,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 0.95
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: style.fontSize, weight: style.fontWeight))
                }
                
                Text(title)
                    .font(.system(size: style.fontSize, weight: style.fontWeight))
            }
            .foregroundStyle(style.foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: style.height)
            .background(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(style.backgroundColor)
                    .shimmer(color: style.shimmerColor, speed: style.shimmerSpeed)
            )
            .shadow(
                color: style.backgroundColor.opacity(0.3),
                radius: style.shadowRadius,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(scale)
    }
}

// MARK: - Gradient Shimmer Button
public struct GradientShimmerButton: View {
    let title: String
    let icon: String?
    let gradientColors: [Color]
    let foregroundColor: Color
    let cornerRadius: CGFloat
    let height: CGFloat
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var gradientRotation: Double = 0
    
    public init(
        _ title: String,
        icon: String? = nil,
        gradientColors: [Color] = [.purple, .pink, .orange],
        foregroundColor: Color = .white,
        cornerRadius: CGFloat = 12,
        height: CGFloat = 56,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.gradientColors = gradientColors
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.height = height
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 0.95
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                AngularGradient(
                    gradient: Gradient(colors: gradientColors),
                    center: .center,
                    angle: .degrees(gradientRotation)
                )
                .blur(radius: 8)
            )
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: gradientColors[0].opacity(0.5), radius: 15, x: 0, y: 8)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                gradientRotation = 360
            }
        }
    }
}

// MARK: - Pulse Shimmer Button
public struct PulseShimmerButton: View {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.6
    
    public init(
        _ title: String,
        icon: String? = nil,
        color: Color = .blue,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 0.95
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
                action()
            }
        }) {
            ZStack {
                // Pulse effect
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.3))
                    .scaleEffect(pulseScale)
                    .opacity(pulseOpacity)
                
                // Main button
                HStack(spacing: 8) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 17, weight: .semibold))
                    }
                    
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                        .shimmer(color: .white.opacity(0.5), speed: 2.0)
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(scale)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.1
                pulseOpacity = 0
            }
        }
    }
}

// MARK: - Preview
#Preview("Shimmer Buttons") {
    ScrollView {
        VStack(spacing: 30) {
            Text("Shimmer Buttons")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack(spacing: 20) {
                // Default Shimmer Button
                VStack(alignment: .leading, spacing: 8) {
                    Text("Default Shimmer")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    ShimmerButton("Continue", icon: "arrow.right") {
                        print("Default button tapped")
                    }
                }
                
                // Success Style
                VStack(alignment: .leading, spacing: 8) {
                    Text("Success Style")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    ShimmerButton(
                        "Complete",
                        icon: "checkmark.circle.fill",
                        style: .success
                    ) {
                        print("Success button tapped")
                    }
                }
                
                // Danger Style
                VStack(alignment: .leading, spacing: 8) {
                    Text("Danger Style")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    ShimmerButton(
                        "Delete",
                        icon: "trash.fill",
                        style: .danger
                    ) {
                        print("Danger button tapped")
                    }
                }
                
                // Gradient Shimmer Button
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gradient Shimmer")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    GradientShimmerButton(
                        "Get Started",
                        icon: "sparkles"
                    ) {
                        print("Gradient button tapped")
                    }
                }
                
                // Custom Gradient
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Gradient")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    GradientShimmerButton(
                        "Premium",
                        icon: "crown.fill",
                        gradientColors: [.blue, .purple, .pink]
                    ) {
                        print("Premium button tapped")
                    }
                }
                
                // Pulse Shimmer Button
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pulse Shimmer")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    PulseShimmerButton(
                        "Subscribe",
                        icon: "bell.fill",
                        color: .indigo
                    ) {
                        print("Pulse button tapped")
                    }
                }
                
                // Custom Style
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Style")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    ShimmerButton(
                        "Custom Button",
                        icon: "star.fill",
                        style: ShimmerButtonStyle(
                            backgroundColor: .teal,
                            shimmerColor: .cyan.opacity(0.7),
                            cornerRadius: 20,
                            height: 64,
                            fontSize: 18,
                            shimmerSpeed: 1.5
                        )
                    ) {
                        print("Custom button tapped")
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    .background(Color(.systemGroupedBackground))
}

