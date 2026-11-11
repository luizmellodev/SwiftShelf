import SwiftUI

// MARK: - Variant

/// Visual styles for `RippleButton`.
public enum RippleButtonVariant {
    /// Vivid gradient fill with white content and white ripples.
    case filled
    /// Soft tinted fill with tinted content and ripples.
    case tinted
    /// Frosted material with primary content and tinted ripples.
    case glass
}

// MARK: - Ripple Button

/// A button that answers every touch with a ripple born at the exact point
/// your finger landed, a soft glow that follows it, and a physical press-in.
///
/// Rapid taps stack ripples on top of each other instead of restarting one,
/// so drumming on it feels like dropping pebbles in water.
public struct RippleButton<Label: View>: View {
    var colors: [Color]
    var variant: RippleButtonVariant
    var cornerRadius: CGFloat
    var fillsWidth: Bool
    let action: () -> Void
    let label: Label

    @State private var ripples: [RippleButtonWaveModel] = []
    @State private var isPressed = false
    @State private var touch: CGPoint = .zero
    @State private var size: CGSize = .zero
    @State private var presses = 0

    public init(
        colors: [Color] = [Color(red: 0.33, green: 0.38, blue: 1.0), Color(red: 0.78, green: 0.3, blue: 0.95)],
        variant: RippleButtonVariant = .filled,
        cornerRadius: CGFloat = 20,
        fillsWidth: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.colors = colors.isEmpty ? [.accentColor] : colors
        self.variant = variant
        self.cornerRadius = cornerRadius
        self.fillsWidth = fillsWidth
        self.action = action
        self.label = label()
    }

    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: cornerRadius, style: .continuous) }

    private var foreground: Color {
        switch variant {
        case .filled: .white
        case .tinted: colors[0]
        case .glass: Color(.label)
        }
    }

    private var rippleColor: Color { variant == .filled ? .white : colors[0] }

    private var baseFill: AnyShapeStyle {
        switch variant {
        case .filled: AnyShapeStyle(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
        case .tinted: AnyShapeStyle(colors[0].opacity(0.14))
        case .glass: AnyShapeStyle(.ultraThinMaterial)
        }
    }

    public var body: some View {
        content
            .scaleEffect(isPressed ? 0.955 : 1)
            .shadow(color: shadowColor, radius: isPressed ? 6 : 16, y: isPressed ? 3 : 10)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.75), trigger: presses)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { action() }
    }

    private var shadowColor: Color {
        variant == .filled ? (colors.last ?? colors[0]).opacity(isPressed ? 0.3 : 0.45) : .black.opacity(isPressed ? 0.04 : 0.1)
    }

    private var content: some View {
        label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(foreground)
            .padding(.horizontal, 26)
            .frame(maxWidth: fillsWidth ? .infinity : nil, minHeight: 58)
            .background { surface }
            .clipShape(shape)
            .overlay(shape.strokeBorder(Color.white.opacity(variant == .filled ? 0.22 : 0.08), lineWidth: 1))
            .contentShape(shape)
            .onGeometryChange(for: CGSize.self) { $0.size } action: { size = $0 }
            .gesture(pressGesture)
    }

    private var surface: some View {
        ZStack {
            shape.fill(baseFill)

            // Top sheen for depth; flattens while pressed.
            shape.fill(
                LinearGradient(colors: [.white.opacity(isPressed ? 0.05 : 0.22), .white.opacity(0)],
                               startPoint: .top, endPoint: .center)
            )

            // Glow that tracks the finger.
            Circle()
                .fill(rippleColor.opacity(0.4))
                .frame(width: 110, height: 110)
                .blur(radius: 28)
                .position(touch)
                .opacity(isPressed ? 1 : 0)
                .animation(.easeOut(duration: 0.25), value: isPressed)

            ForEach(ripples) { ripple in
                RippleButtonWave(model: ripple, color: rippleColor)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: Gesture

    private var pressGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                touch = value.location
                if !isPressed {
                    isPressed = true
                    presses += 1
                    spawnRipple(at: value.startLocation)
                }
            }
            .onEnded { value in
                isPressed = false
                let bounds = CGRect(origin: .zero, size: size).insetBy(dx: -24, dy: -24)
                if bounds.contains(value.location) { action() }
            }
    }

    private func spawnRipple(at point: CGPoint) {
        let corners = [CGPoint.zero, CGPoint(x: size.width, y: 0), CGPoint(x: 0, y: size.height), CGPoint(x: size.width, y: size.height)]
        let radius = corners.map { hypot($0.x - point.x, $0.y - point.y) }.max() ?? 100
        let ripple = RippleButtonWaveModel(point: point, radius: radius)
        ripples.append(ripple)

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.9))
            ripples.removeAll { $0.id == ripple.id }
        }
    }
}

// MARK: - Ripple

private struct RippleButtonWaveModel: Identifiable {
    let id = UUID()
    let point: CGPoint
    let radius: CGFloat
}

private struct RippleButtonWave: View {
    let model: RippleButtonWaveModel
    let color: Color
    @State private var expanded = false

    var body: some View {
        ZStack {
            Circle().fill(RadialGradient(colors: [color.opacity(0.1), color.opacity(0.38)],
                                         center: .center, startRadius: 0, endRadius: model.radius))
            Circle().strokeBorder(color.opacity(0.65), lineWidth: 1.5)
        }
        .frame(width: model.radius * 2, height: model.radius * 2)
        .scaleEffect(expanded ? 1 : 0.04)
        .animation(.easeOut(duration: 0.6), value: expanded)
        .opacity(expanded ? 0 : 1)
        .animation(.easeIn(duration: 0.8), value: expanded)
        .position(model.point)
        .onAppear { expanded = true }
    }
}

// MARK: - Convenience

extension RippleButton where Label == SwiftUI.Label<Text, Image> {
    /// A ripple button with a title and an SF Symbol.
    public init(
        _ title: String,
        systemImage: String,
        colors: [Color] = [Color(red: 0.33, green: 0.38, blue: 1.0), Color(red: 0.78, green: 0.3, blue: 0.95)],
        variant: RippleButtonVariant = .filled,
        fillsWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(colors: colors, variant: variant, fillsWidth: fillsWidth, action: action) {
            SwiftUI.Label(title, systemImage: systemImage)
        }
    }
}

// MARK: - Preview

#Preview("Ripple Button") {
    VStack(spacing: 16) {
        RippleButton("Get started", systemImage: "arrow.right", fillsWidth: true) {}
        RippleButton("Sign in with passkey", systemImage: "person.badge.key.fill",
                     colors: [.teal], variant: .tinted, fillsWidth: true) {}
        HStack(spacing: 14) {
            ForEach(["heart.fill", "bookmark.fill", "square.and.arrow.up"], id: \.self) { icon in
                RippleButton(colors: [.pink], variant: .glass, cornerRadius: 29, action: {}) {
                    Image(systemName: icon)
                }
            }
        }
    }
    .padding(24)
    .frame(maxHeight: .infinity)
    .background(Color(.systemBackground))
}
