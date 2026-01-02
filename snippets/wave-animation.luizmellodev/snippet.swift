import SwiftUI

// MARK: - Wave Configuration
public struct WaveConfiguration {
    let amplitude: CGFloat
    let frequency: CGFloat
    let speed: Double
    let phase: CGFloat
    
    public init(
        amplitude: CGFloat = 20,
        frequency: CGFloat = 1.5,
        speed: Double = 2.0,
        phase: CGFloat = 0
    ) {
        self.amplitude = amplitude
        self.frequency = frequency
        self.speed = speed
        self.phase = phase
    }
    
    public static let `default` = WaveConfiguration()
    public static let gentle = WaveConfiguration(amplitude: 10, frequency: 1.0, speed: 3.0)
    public static let intense = WaveConfiguration(amplitude: 30, frequency: 2.0, speed: 1.5)
}

// MARK: - Wave Shape
public struct Wave: Shape {
    var offset: CGFloat
    let amplitude: CGFloat
    let frequency: CGFloat
    
    public var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let midHeight = rect.height / 2
        let wavelength = rect.width / frequency
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / wavelength
            let sine = sin((relativeX + offset) * .pi * 2)
            let y = midHeight + sine * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

// MARK: - Filled Wave Shape
public struct FilledWave: Shape {
    var offset: CGFloat
    let amplitude: CGFloat
    let frequency: CGFloat
    
    public var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let midHeight = rect.height / 2
        let wavelength = rect.width / frequency
        
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / wavelength
            let sine = sin((relativeX + offset) * .pi * 2)
            let y = midHeight + sine * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Animated Wave View
public struct AnimatedWaveView: View {
    let configuration: WaveConfiguration
    let color: Color
    let lineWidth: CGFloat
    
    @State private var offset: CGFloat = 0
    
    public init(
        configuration: WaveConfiguration = .default,
        color: Color = .blue,
        lineWidth: CGFloat = 2
    ) {
        self.configuration = configuration
        self.color = color
        self.lineWidth = lineWidth
    }
    
    public var body: some View {
        Wave(
            offset: offset,
            amplitude: configuration.amplitude,
            frequency: configuration.frequency
        )
        .stroke(color, lineWidth: lineWidth)
        .onAppear {
            withAnimation(
                .linear(duration: configuration.speed)
                .repeatForever(autoreverses: false)
            ) {
                offset = 1
            }
        }
    }
}

// MARK: - Animated Filled Wave View
public struct AnimatedFilledWaveView: View {
    let configuration: WaveConfiguration
    let colors: [Color]
    
    @State private var offset: CGFloat = 0
    
    public init(
        configuration: WaveConfiguration = .default,
        colors: [Color] = [.blue, .cyan]
    ) {
        self.configuration = configuration
        self.colors = colors
    }
    
    public var body: some View {
        FilledWave(
            offset: offset,
            amplitude: configuration.amplitude,
            frequency: configuration.frequency
        )
        .fill(
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            withAnimation(
                .linear(duration: configuration.speed)
                .repeatForever(autoreverses: false)
            ) {
                offset = 1
            }
        }
    }
}

// MARK: - Multi-Layer Wave View
public struct MultiLayerWaveView: View {
    let layers: [WaveLayer]
    
    @State private var offsets: [CGFloat]
    
    public init(layers: [WaveLayer]) {
        self.layers = layers
        self._offsets = State(initialValue: Array(repeating: 0, count: layers.count))
    }
    
    public var body: some View {
        ZStack {
            ForEach(Array(layers.enumerated()), id: \.offset) { index, layer in
                FilledWave(
                    offset: offsets[index],
                    amplitude: layer.amplitude,
                    frequency: layer.frequency
                )
                .fill(layer.color)
                .opacity(layer.opacity)
                .onAppear {
                    withAnimation(
                        .linear(duration: layer.speed)
                        .repeatForever(autoreverses: false)
                    ) {
                        offsets[index] = 1
                    }
                }
            }
        }
    }
}

public struct WaveLayer {
    let amplitude: CGFloat
    let frequency: CGFloat
    let speed: Double
    let color: Color
    let opacity: Double
    
    public init(
        amplitude: CGFloat,
        frequency: CGFloat,
        speed: Double,
        color: Color,
        opacity: Double = 0.5
    ) {
        self.amplitude = amplitude
        self.frequency = frequency
        self.speed = speed
        self.color = color
        self.opacity = opacity
    }
}

// MARK: - Wave Loading Indicator
public struct WaveLoadingIndicator: View {
    let color: Color
    let dotCount: Int
    let size: CGFloat
    
    @State private var animationPhases: [CGFloat]
    
    public init(
        color: Color = .blue,
        dotCount: Int = 5,
        size: CGFloat = 12
    ) {
        self.color = color
        self.dotCount = dotCount
        self.size = size
        self._animationPhases = State(initialValue: Array(repeating: 0, count: dotCount))
    }
    
    public var body: some View {
        HStack(spacing: size / 2) {
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
                    .offset(y: animationPhases[index] * -20)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1)
                        ) {
                            animationPhases[index] = 1
                        }
                    }
            }
        }
    }
}

// MARK: - Wave Progress View
public struct WaveProgressView: View {
    let progress: Double
    let color: Color
    let height: CGFloat
    
    @State private var offset: CGFloat = 0
    
    public init(
        progress: Double,
        color: Color = .blue,
        height: CGFloat = 100
    ) {
        self.progress = min(max(progress, 0), 1)
        self.color = color
        self.height = height
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 2)
                
                // Wave fill
                FilledWave(
                    offset: offset,
                    amplitude: 8,
                    frequency: 2
                )
                .fill(color)
                .frame(height: height * progress)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Percentage text
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(progress > 0.5 ? .white : color)
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(
                .linear(duration: 2.0)
                .repeatForever(autoreverses: false)
            ) {
                offset = 1
            }
        }
    }
}

// MARK: - Circular Wave View
public struct CircularWaveView: View {
    let color: Color
    let waveCount: Int
    
    @State private var scales: [CGFloat]
    @State private var opacities: [Double]
    
    public init(
        color: Color = .blue,
        waveCount: Int = 3
    ) {
        self.color = color
        self.waveCount = waveCount
        self._scales = State(initialValue: Array(repeating: 0.5, count: waveCount))
        self._opacities = State(initialValue: Array(repeating: 1.0, count: waveCount))
    }
    
    public var body: some View {
        ZStack {
            ForEach(0..<waveCount, id: \.self) { index in
                Circle()
                    .stroke(color.opacity(opacities[index]), lineWidth: 2)
                    .scaleEffect(scales[index])
                    .onAppear {
                        withAnimation(
                            .easeOut(duration: 2.0)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.4)
                        ) {
                            scales[index] = 1.5
                            opacities[index] = 0
                        }
                    }
            }
        }
    }
}

// MARK: - Wave Background View
public struct WaveBackgroundView: View {
    let colors: [Color]
    
    @State private var offset1: CGFloat = 0
    @State private var offset2: CGFloat = 0
    @State private var offset3: CGFloat = 0
    
    public init(colors: [Color] = [.blue, .purple, .pink]) {
        self.colors = colors
    }
    
    public var body: some View {
        ZStack {
            FilledWave(offset: offset1, amplitude: 30, frequency: 1.5)
                .fill(colors[0].opacity(0.3))
                .onAppear {
                    withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                        offset1 = 1
                    }
                }
            
            FilledWave(offset: offset2, amplitude: 25, frequency: 1.8)
                .fill(colors[1].opacity(0.3))
                .onAppear {
                    withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                        offset2 = 1
                    }
                }
            
            FilledWave(offset: offset3, amplitude: 20, frequency: 2.0)
                .fill(colors[2].opacity(0.3))
                .onAppear {
                    withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                        offset3 = 1
                    }
                }
        }
    }
}

// MARK: - Audio Wave Visualizer
public struct AudioWaveVisualizer: View {
    let barCount: Int
    let color: Color
    let spacing: CGFloat
    
    @State private var amplitudes: [CGFloat]
    
    public init(
        barCount: Int = 20,
        color: Color = .blue,
        spacing: CGFloat = 4
    ) {
        self.barCount = barCount
        self.color = color
        self.spacing = spacing
        self._amplitudes = State(initialValue: Array(repeating: 0.3, count: barCount))
    }
    
    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: 3)
                    .frame(height: 60 * amplitudes[index])
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: Double.random(in: 0.3...0.8))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.05)
                        ) {
                            amplitudes[index] = CGFloat.random(in: 0.3...1.0)
                        }
                    }
            }
        }
    }
}

// MARK: - Preview
#Preview("Wave Animations") {
    ScrollView {
        VStack(spacing: 40) {
            Text("Wave Animations")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            // Simple Wave
            VStack(alignment: .leading, spacing: 12) {
                Text("Simple Wave")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                AnimatedWaveView(
                    configuration: .default,
                    color: .blue,
                    lineWidth: 3
                )
                .frame(height: 100)
            }
            .padding(.horizontal)
            
            // Filled Wave
            VStack(alignment: .leading, spacing: 12) {
                Text("Filled Wave")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                AnimatedFilledWaveView(
                    configuration: WaveConfiguration(amplitude: 25, frequency: 2.0, speed: 2.5),
                    colors: [.purple, .pink]
                )
                .frame(height: 150)
            }
            .padding(.horizontal)
            
            // Multi-Layer Waves
            VStack(alignment: .leading, spacing: 12) {
                Text("Multi-Layer Waves")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                MultiLayerWaveView(layers: [
                    WaveLayer(amplitude: 30, frequency: 1.5, speed: 3.0, color: .blue, opacity: 0.3),
                    WaveLayer(amplitude: 25, frequency: 1.8, speed: 2.5, color: .cyan, opacity: 0.4),
                    WaveLayer(amplitude: 20, frequency: 2.0, speed: 2.0, color: .teal, opacity: 0.5)
                ])
                .frame(height: 150)
            }
            .padding(.horizontal)
            
            // Wave Loading Indicator
            VStack(alignment: .leading, spacing: 12) {
                Text("Wave Loading Indicator")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                WaveLoadingIndicator(color: .blue, dotCount: 5, size: 12)
                    .frame(height: 60)
            }
            .padding(.horizontal)
            
            // Wave Progress
            VStack(alignment: .leading, spacing: 12) {
                Text("Wave Progress")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 16) {
                    WaveProgressView(progress: 0.3, color: .red, height: 80)
                    WaveProgressView(progress: 0.6, color: .orange, height: 80)
                    WaveProgressView(progress: 0.9, color: .green, height: 80)
                }
            }
            .padding(.horizontal)
            
            // Circular Wave
            VStack(alignment: .leading, spacing: 12) {
                Text("Circular Wave")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                CircularWaveView(color: .purple, waveCount: 3)
                    .frame(width: 100, height: 100)
            }
            .padding(.horizontal)
            
            // Audio Visualizer
            VStack(alignment: .leading, spacing: 12) {
                Text("Audio Wave Visualizer")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                AudioWaveVisualizer(barCount: 25, color: .green, spacing: 3)
                    .frame(height: 80)
            }
            .padding(.horizontal)
            
            // Wave Background
            VStack(alignment: .leading, spacing: 12) {
                Text("Wave Background")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                ZStack {
                    WaveBackgroundView(colors: [.blue, .purple, .pink])
                    
                    VStack(spacing: 8) {
                        Text("Beautiful")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Wave Background")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 200)
                .cornerRadius(16)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    .background(Color(.systemGroupedBackground))
}

