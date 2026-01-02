import SwiftUI

// MARK: - Gradient Border Style
public struct GradientBorderStyle {
    let gradientColors: [Color]
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
    let animated: Bool
    let animationSpeed: Double
    
    public init(
        gradientColors: [Color] = [.blue, .purple, .pink],
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 16,
        animated: Bool = true,
        animationSpeed: Double = 3.0
    ) {
        self.gradientColors = gradientColors
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
        self.animated = animated
        self.animationSpeed = animationSpeed
    }
    
    public static let `default` = GradientBorderStyle()
    public static let rainbow = GradientBorderStyle(
        gradientColors: [.red, .orange, .yellow, .green, .blue, .purple]
    )
    public static let fire = GradientBorderStyle(
        gradientColors: [.red, .orange, .yellow]
    )
    public static let ocean = GradientBorderStyle(
        gradientColors: [.blue, .cyan, .teal]
    )
    public static let sunset = GradientBorderStyle(
        gradientColors: [.orange, .pink, .purple]
    )
}

// MARK: - Gradient Border Card
public struct GradientBorderCard<Content: View>: View {
    let style: GradientBorderStyle
    let content: Content
    
    @State private var rotation: Double = 0
    
    public init(
        style: GradientBorderStyle = .default,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(style.lineWidth)
            .background(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: style.gradientColors),
                            center: .center,
                            angle: .degrees(rotation)
                        ),
                        lineWidth: style.lineWidth
                    )
            )
            .onAppear {
                if style.animated {
                    withAnimation(
                        .linear(duration: style.animationSpeed)
                        .repeatForever(autoreverses: false)
                    ) {
                        rotation = 360
                    }
                }
            }
    }
}

// MARK: - Animated Gradient Border Card
public struct AnimatedGradientBorderCard<Content: View>: View {
    let gradientColors: [Color]
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
    let content: Content
    
    @State private var startPoint: UnitPoint = .topLeading
    @State private var endPoint: UnitPoint = .bottomTrailing
    
    public init(
        gradientColors: [Color] = [.blue, .purple, .pink],
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.gradientColors = gradientColors
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(lineWidth)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: startPoint,
                            endPoint: endPoint
                        ),
                        lineWidth: lineWidth
                    )
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                ) {
                    startPoint = .bottomTrailing
                    endPoint = .topLeading
                }
            }
    }
}

// MARK: - Glowing Border Card
public struct GlowingBorderCard<Content: View>: View {
    let color: Color
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
    let glowRadius: CGFloat
    let content: Content
    
    @State private var glowIntensity: CGFloat = 0.3
    
    public init(
        color: Color = .blue,
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 16,
        glowRadius: CGFloat = 10,
        @ViewBuilder content: () -> Content
    ) {
        self.color = color
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
        self.glowRadius = glowRadius
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(lineWidth)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: lineWidth)
                    .shadow(color: color.opacity(glowIntensity), radius: glowRadius)
                    .shadow(color: color.opacity(glowIntensity * 0.7), radius: glowRadius * 1.5)
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    glowIntensity = 0.8
                }
            }
    }
}

// MARK: - Dashed Gradient Border Card
public struct DashedGradientBorderCard<Content: View>: View {
    let gradientColors: [Color]
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
    let dashPattern: [CGFloat]
    let content: Content
    
    @State private var rotation: Double = 0
    
    public init(
        gradientColors: [Color] = [.blue, .purple, .pink],
        lineWidth: CGFloat = 3,
        cornerRadius: CGFloat = 16,
        dashPattern: [CGFloat] = [10, 5],
        @ViewBuilder content: () -> Content
    ) {
        self.gradientColors = gradientColors
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
        self.dashPattern = dashPattern
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(lineWidth)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: gradientColors),
                            center: .center,
                            angle: .degrees(rotation)
                        ),
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            dash: dashPattern
                        )
                    )
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 3.0)
                    .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Shimmer Border Card
public struct ShimmerBorderCard<Content: View>: View {
    let color: Color
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
    let content: Content
    
    @State private var phase: CGFloat = 0
    
    public init(
        color: Color = .blue,
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.color = color
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(lineWidth)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.3),
                                color,
                                color.opacity(0.3)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: lineWidth
                    )
                    .mask(
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(lineWidth: lineWidth)
                                .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                        }
                    )
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 2.0)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

// MARK: - Pulsing Border Card
public struct PulsingBorderCard<Content: View>: View {
    let color: Color
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
    let content: Content
    
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    public init(
        color: Color = .blue,
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.color = color
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            // Pulsing outer border
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(color.opacity(opacity), lineWidth: lineWidth)
                .scaleEffect(scale)
            
            // Main content with border
            content
                .padding(lineWidth)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color(.systemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(color, lineWidth: lineWidth)
                )
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: false)
            ) {
                scale = 1.1
                opacity = 0
            }
        }
    }
}

// MARK: - Neon Border Card
public struct NeonBorderCard<Content: View>: View {
    let color: Color
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
    let content: Content
    
    @State private var intensity: CGFloat = 0.5
    
    public init(
        color: Color = .cyan,
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.color = color
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(lineWidth)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: lineWidth)
                    .shadow(color: color.opacity(intensity), radius: 5)
                    .shadow(color: color.opacity(intensity), radius: 10)
                    .shadow(color: color.opacity(intensity * 0.7), radius: 15)
                    .shadow(color: color.opacity(intensity * 0.5), radius: 20)
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    intensity = 1.0
                }
            }
    }
}

// MARK: - View Modifiers
public struct GradientBorderModifier: ViewModifier {
    let style: GradientBorderStyle
    
    @State private var rotation: Double = 0
    
    public init(style: GradientBorderStyle = .default) {
        self.style = style
    }
    
    public func body(content: Content) -> some View {
        content
            .padding(style.lineWidth)
            .background(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: style.gradientColors),
                            center: .center,
                            angle: .degrees(rotation)
                        ),
                        lineWidth: style.lineWidth
                    )
            )
            .onAppear {
                if style.animated {
                    withAnimation(
                        .linear(duration: style.animationSpeed)
                        .repeatForever(autoreverses: false)
                    ) {
                        rotation = 360
                    }
                }
            }
    }
}

public struct GlowingBorderModifier: ViewModifier {
    let color: Color
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
    let glowRadius: CGFloat
    
    @State private var glowIntensity: CGFloat = 0.3
    
    public init(
        color: Color = .blue,
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 16,
        glowRadius: CGFloat = 10
    ) {
        self.color = color
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
        self.glowRadius = glowRadius
    }
    
    public func body(content: Content) -> some View {
        content
            .padding(lineWidth)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: lineWidth)
                    .shadow(color: color.opacity(glowIntensity), radius: glowRadius)
                    .shadow(color: color.opacity(glowIntensity * 0.7), radius: glowRadius * 1.5)
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    glowIntensity = 0.8
                }
            }
    }
}

public struct NeonBorderModifier: ViewModifier {
    let color: Color
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
    
    @State private var intensity: CGFloat = 0.5
    
    public init(
        color: Color = .cyan,
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 16
    ) {
        self.color = color
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
    }
    
    public func body(content: Content) -> some View {
        content
            .padding(lineWidth)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: lineWidth)
                    .shadow(color: color.opacity(intensity), radius: 5)
                    .shadow(color: color.opacity(intensity), radius: 10)
                    .shadow(color: color.opacity(intensity * 0.7), radius: 15)
                    .shadow(color: color.opacity(intensity * 0.5), radius: 20)
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    intensity = 1.0
                }
            }
    }
}

// MARK: - View Extensions
public extension View {
    func gradientBorder(style: GradientBorderStyle = .default) -> some View {
        modifier(GradientBorderModifier(style: style))
    }
    
    func glowingBorder(
        color: Color = .blue,
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 16,
        glowRadius: CGFloat = 10
    ) -> some View {
        modifier(GlowingBorderModifier(
            color: color,
            lineWidth: lineWidth,
            cornerRadius: cornerRadius,
            glowRadius: glowRadius
        ))
    }
    
    func neonBorder(
        color: Color = .cyan,
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 16
    ) -> some View {
        modifier(NeonBorderModifier(
            color: color,
            lineWidth: lineWidth,
            cornerRadius: cornerRadius
        ))
    }
}

// MARK: - Preview
#Preview("Gradient Border Cards") {
    ScrollView {
        VStack(spacing: 30) {
            Text("Gradient Border Cards")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            // Standard Gradient Border
            VStack(alignment: .leading, spacing: 12) {
                Text("Animated Gradient Border")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                GradientBorderCard(style: .default) {
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundStyle(.blue)
                        
                        Text("Premium Feature")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Unlock exclusive content with our premium subscription")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                }
            }
            .padding(.horizontal)
            
            // Rainbow Border
            VStack(alignment: .leading, spacing: 12) {
                Text("Rainbow Border")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                GradientBorderCard(style: .rainbow) {
                    HStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.yellow)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("VIP Member")
                                .font(.headline)
                            Text("Exclusive benefits")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .padding(.horizontal)
            
            // Glowing Border
            VStack(alignment: .leading, spacing: 12) {
                Text("Glowing Border")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                GlowingBorderCard(color: .purple) {
                    VStack(spacing: 8) {
                        Text("🎉")
                            .font(.system(size: 50))
                        
                        Text("Special Offer")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("50% off for a limited time")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
            }
            .padding(.horizontal)
            
            // Dashed Gradient Border
            VStack(alignment: .leading, spacing: 12) {
                Text("Dashed Gradient Border")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                DashedGradientBorderCard(gradientColors: [.orange, .pink, .red]) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Limited Edition")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text("Exclusive Item")
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        Text("$99")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                    }
                    .padding()
                }
            }
            .padding(.horizontal)
            
            // Pulsing Border
            VStack(alignment: .leading, spacing: 12) {
                Text("Pulsing Border")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                PulsingBorderCard(color: .green) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.green)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Success!")
                                .font(.headline)
                            Text("Your payment was processed")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .padding(.horizontal)
            
            // Neon Border
            VStack(alignment: .leading, spacing: 12) {
                Text("Neon Border")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                NeonBorderCard(color: .cyan) {
                    VStack(spacing: 12) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 35))
                            .foregroundStyle(.cyan)
                        
                        Text("Power Mode")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("Boost your performance")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
            }
            .padding(.horizontal)
            
            // Linear Animated Border
            VStack(alignment: .leading, spacing: 12) {
                Text("Linear Animated Border")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                AnimatedGradientBorderCard(gradientColors: [.blue, .teal, .green]) {
                    VStack(spacing: 8) {
                        Text("💎")
                            .font(.system(size: 40))
                        
                        Text("Premium Plan")
                            .font(.headline)
                        
                        Text("$29.99/month")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    .background(Color(.systemGroupedBackground))
}

