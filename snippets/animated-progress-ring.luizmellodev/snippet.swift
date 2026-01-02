import SwiftUI

// MARK: - Progress Ring Style
public struct ProgressRingStyle {
    let lineWidth: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    let lineCap: CGLineCap
    let showPercentage: Bool
    let showLabel: Bool
    let fontSize: CGFloat
    let fontWeight: Font.Weight
    
    public init(
        lineWidth: CGFloat = 20,
        backgroundColor: Color = Color(.systemGray5),
        foregroundColor: Color = .blue,
        lineCap: CGLineCap = .round,
        showPercentage: Bool = true,
        showLabel: Bool = false,
        fontSize: CGFloat = 32,
        fontWeight: Font.Weight = .bold
    ) {
        self.lineWidth = lineWidth
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.lineCap = lineCap
        self.showPercentage = showPercentage
        self.showLabel = showLabel
        self.fontSize = fontSize
        self.fontWeight = fontWeight
    }
    
    public static let `default` = ProgressRingStyle()
    public static let thin = ProgressRingStyle(lineWidth: 10)
    public static let thick = ProgressRingStyle(lineWidth: 30)
}

// MARK: - Animated Progress Ring
public struct AnimatedProgressRing: View {
    let progress: Double
    let size: CGFloat
    let style: ProgressRingStyle
    let label: String?
    let animationDuration: Double
    
    @State private var animatedProgress: Double = 0
    
    public init(
        progress: Double,
        size: CGFloat = 200,
        style: ProgressRingStyle = .default,
        label: String? = nil,
        animationDuration: Double = 1.0
    ) {
        self.progress = min(max(progress, 0), 1)
        self.size = size
        self.style = style
        self.label = label
        self.animationDuration = animationDuration
    }
    
    public var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    style.backgroundColor,
                    lineWidth: style.lineWidth
                )
            
            // Progress circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    style.foregroundColor,
                    style: StrokeStyle(
                        lineWidth: style.lineWidth,
                        lineCap: style.lineCap
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: animationDuration), value: animatedProgress)
            
            // Center content
            VStack(spacing: 4) {
                if style.showPercentage {
                    Text("\(Int(animatedProgress * 100))%")
                        .font(.system(size: style.fontSize, weight: style.fontWeight))
                        .foregroundStyle(.primary)
                }
                
                if style.showLabel, let label = label {
                    Text(label)
                        .font(.system(size: style.fontSize * 0.4, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.easeInOut(duration: animationDuration)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Gradient Progress Ring
public struct GradientProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let gradientColors: [Color]
    let showPercentage: Bool
    let label: String?
    let animationDuration: Double
    
    @State private var animatedProgress: Double = 0
    
    public init(
        progress: Double,
        size: CGFloat = 200,
        lineWidth: CGFloat = 20,
        gradientColors: [Color] = [.blue, .purple, .pink],
        showPercentage: Bool = true,
        label: String? = nil,
        animationDuration: Double = 1.0
    ) {
        self.progress = min(max(progress, 0), 1)
        self.size = size
        self.lineWidth = lineWidth
        self.gradientColors = gradientColors
        self.showPercentage = showPercentage
        self.label = label
        self.animationDuration = animationDuration
    }
    
    public var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    Color(.systemGray5),
                    lineWidth: lineWidth
                )
            
            // Gradient progress circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * animatedProgress)
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: animationDuration), value: animatedProgress)
            
            // Center content
            VStack(spacing: 4) {
                if showPercentage {
                    Text("\(Int(animatedProgress * 100))%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.primary)
                }
                
                if let label = label {
                    Text(label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.easeInOut(duration: animationDuration)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Multi-Layer Progress Ring
public struct MultiLayerProgressRing: View {
    let layers: [ProgressLayer]
    let size: CGFloat
    let animationDuration: Double
    
    @State private var animatedLayers: [AnimatedLayer] = []
    
    public init(
        layers: [ProgressLayer],
        size: CGFloat = 200,
        animationDuration: Double = 1.0
    ) {
        self.layers = layers
        self.size = size
        self.animationDuration = animationDuration
    }
    
    public var body: some View {
        ZStack {
            ForEach(Array(animatedLayers.enumerated()), id: \.element.id) { index, layer in
                let layerSize = size - (CGFloat(index) * (layer.lineWidth + 10))
                
                Circle()
                    .trim(from: 0, to: layer.progress)
                    .stroke(
                        layer.color,
                        style: StrokeStyle(
                            lineWidth: layer.lineWidth,
                            lineCap: .round
                        )
                    )
                    .frame(width: layerSize, height: layerSize)
                    .rotationEffect(.degrees(-90))
                    .animation(
                        .easeInOut(duration: animationDuration).delay(Double(index) * 0.1),
                        value: layer.progress
                    )
            }
            
            // Center label
            if let firstLayer = animatedLayers.first {
                VStack(spacing: 4) {
                    Text("\(Int(firstLayer.progress * 100))%")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    if let label = firstLayer.label {
                        Text(label)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            animatedLayers = layers.map { layer in
                AnimatedLayer(
                    id: layer.id,
                    progress: layer.progress,
                    color: layer.color,
                    lineWidth: layer.lineWidth,
                    label: layer.label
                )
            }
        }
        .onChange(of: layers) { oldValue, newValue in
            withAnimation(.easeInOut(duration: animationDuration)) {
                animatedLayers = newValue.map { layer in
                    AnimatedLayer(
                        id: layer.id,
                        progress: layer.progress,
                        color: layer.color,
                        lineWidth: layer.lineWidth,
                        label: layer.label
                    )
                }
            }
        }
    }
}

// MARK: - Progress Layer Models
public struct ProgressLayer: Identifiable, Equatable {
    public let id = UUID()
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    let label: String?
    
    public init(
        progress: Double,
        color: Color,
        lineWidth: CGFloat = 15,
        label: String? = nil
    ) {
        self.progress = min(max(progress, 0), 1)
        self.color = color
        self.lineWidth = lineWidth
        self.label = label
    }
    
    public static func == (lhs: ProgressLayer, rhs: ProgressLayer) -> Bool {
        lhs.progress == rhs.progress &&
        lhs.color == rhs.color &&
        lhs.lineWidth == rhs.lineWidth &&
        lhs.label == rhs.label
    }
}

struct AnimatedLayer: Identifiable {
    let id: UUID
    var progress: Double
    let color: Color
    let lineWidth: CGFloat
    let label: String?
}

// MARK: - Segmented Progress Ring
public struct SegmentedProgressRing: View {
    let progress: Double
    let segments: Int
    let size: CGFloat
    let lineWidth: CGFloat
    let color: Color
    let animationDuration: Double
    
    @State private var animatedProgress: Double = 0
    
    public init(
        progress: Double,
        segments: Int = 12,
        size: CGFloat = 200,
        lineWidth: CGFloat = 20,
        color: Color = .blue,
        animationDuration: Double = 1.0
    ) {
        self.progress = min(max(progress, 0), 1)
        self.segments = segments
        self.size = size
        self.lineWidth = lineWidth
        self.color = color
        self.animationDuration = animationDuration
    }
    
    public var body: some View {
        ZStack {
            ForEach(0..<segments, id: \.self) { index in
                let segmentProgress = Double(index) / Double(segments)
                let isActive = segmentProgress < animatedProgress
                
                Circle()
                    .trim(
                        from: segmentProgress,
                        to: segmentProgress + (1.0 / Double(segments)) - 0.02
                    )
                    .stroke(
                        isActive ? color : Color(.systemGray5),
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(
                        .easeInOut(duration: animationDuration).delay(Double(index) * 0.05),
                        value: animatedProgress
                    )
            }
            
            // Center percentage
            Text("\(Int(animatedProgress * 100))%")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.primary)
        }
        .frame(width: size, height: size)
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.easeInOut(duration: animationDuration)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Dotted Progress Ring
public struct DottedProgressRing: View {
    let progress: Double
    let size: CGFloat
    let dotCount: Int
    let dotSize: CGFloat
    let color: Color
    let animationDuration: Double
    
    @State private var animatedProgress: Double = 0
    
    public init(
        progress: Double,
        size: CGFloat = 200,
        dotCount: Int = 20,
        dotSize: CGFloat = 12,
        color: Color = .blue,
        animationDuration: Double = 1.0
    ) {
        self.progress = min(max(progress, 0), 1)
        self.size = size
        self.dotCount = dotCount
        self.dotSize = dotSize
        self.color = color
        self.animationDuration = animationDuration
    }
    
    public var body: some View {
        ZStack {
            ForEach(0..<dotCount, id: \.self) { index in
                let angle = (Double(index) / Double(dotCount)) * 360 - 90
                let dotProgress = Double(index) / Double(dotCount)
                let isActive = dotProgress < animatedProgress
                
                Circle()
                    .fill(isActive ? color : Color(.systemGray5))
                    .frame(width: dotSize, height: dotSize)
                    .offset(y: -(size / 2 - dotSize))
                    .rotationEffect(.degrees(angle))
                    .scaleEffect(isActive ? 1.0 : 0.7)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.6)
                        .delay(Double(index) * 0.03),
                        value: animatedProgress
                    )
            }
            
            // Center percentage
            Text("\(Int(animatedProgress * 100))%")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)
        }
        .frame(width: size, height: size)
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.easeInOut(duration: animationDuration)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Preview
#Preview("Animated Progress Rings") {
    ScrollView {
        VStack(spacing: 40) {
            Text("Progress Rings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            // Standard Progress Ring
            VStack(spacing: 12) {
                Text("Standard Ring")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                AnimatedProgressRing(
                    progress: 0.75,
                    style: ProgressRingStyle(showLabel: true),
                    label: "Completed"
                )
            }
            
            Divider()
            
            // Gradient Progress Ring
            VStack(spacing: 12) {
                Text("Gradient Ring")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                GradientProgressRing(
                    progress: 0.65,
                    gradientColors: [.blue, .purple, .pink],
                    label: "Progress"
                )
            }
            
            Divider()
            
            // Multi-Layer Ring
            VStack(spacing: 12) {
                Text("Multi-Layer Ring")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                MultiLayerProgressRing(
                    layers: [
                        ProgressLayer(progress: 0.8, color: .blue, label: "Main"),
                        ProgressLayer(progress: 0.6, color: .green),
                        ProgressLayer(progress: 0.4, color: .orange)
                    ],
                    size: 220
                )
            }
            
            Divider()
            
            // Segmented Ring
            VStack(spacing: 12) {
                Text("Segmented Ring")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                SegmentedProgressRing(
                    progress: 0.7,
                    segments: 16,
                    color: .purple
                )
            }
            
            Divider()
            
            // Dotted Ring
            VStack(spacing: 12) {
                Text("Dotted Ring")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                DottedProgressRing(
                    progress: 0.85,
                    dotCount: 24,
                    color: .teal
                )
            }
            
            Divider()
            
            // Interactive Demo
            VStack(spacing: 12) {
                Text("Interactive Demo")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                InteractiveProgressDemo()
            }
            
            Spacer()
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}

// MARK: - Interactive Demo
private struct InteractiveProgressDemo: View {
    @State private var progress: Double = 0.5
    
    var body: some View {
        VStack(spacing: 20) {
            AnimatedProgressRing(
                progress: progress,
                size: 180,
                style: ProgressRingStyle(
                    lineWidth: 25,
                    foregroundColor: .blue,
                    showLabel: true
                ),
                label: "Progress"
            )
            
            VStack(spacing: 8) {
                Slider(value: $progress, in: 0...1)
                    .tint(.blue)
                
                HStack {
                    Button("0%") { withAnimation { progress = 0 } }
                    Button("25%") { withAnimation { progress = 0.25 } }
                    Button("50%") { withAnimation { progress = 0.5 } }
                    Button("75%") { withAnimation { progress = 0.75 } }
                    Button("100%") { withAnimation { progress = 1.0 } }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

