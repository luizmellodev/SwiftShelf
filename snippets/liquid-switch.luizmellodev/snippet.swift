import SwiftUI

// MARK: - Tint Presets

/// Gradient presets for `LiquidSwitch`. Make your own with `LiquidSwitchTint([...])`.
public struct LiquidSwitchTint {
    public let colors: [Color]

    public init(_ colors: [Color]) {
        self.colors = colors.isEmpty ? [.accentColor] : colors
    }

    public static let aqua = LiquidSwitchTint([Color(red: 0.0, green: 0.82, blue: 1.0), Color(red: 0.18, green: 0.42, blue: 1.0)])
    public static let lime = LiquidSwitchTint([Color(red: 0.62, green: 0.94, blue: 0.3), Color(red: 0.08, green: 0.74, blue: 0.46)])
    public static let sunset = LiquidSwitchTint([Color(red: 1.0, green: 0.7, blue: 0.22), Color(red: 1.0, green: 0.27, blue: 0.45)])
    public static let grape = LiquidSwitchTint([Color(red: 0.82, green: 0.42, blue: 1.0), Color(red: 0.42, green: 0.26, blue: 0.98)])
}

// MARK: - Liquid Switch

/// A toggle that behaves like a drop of liquid.
///
/// The knob stretches along its direction of travel, squashes against the
/// wall when it lands and wobbles back into shape, while the colored fill
/// flows in behind it on a softer spring and splashes a ring on arrival.
/// Tap it, or grab the knob and fling it: the stretch follows your velocity.
public struct LiquidSwitch: View {
    @Binding var isOn: Bool
    var tint: LiquidSwitchTint
    var width: CGFloat
    var accessibilityTitle: String

    @State private var dragOffset: CGFloat = 0
    @State private var dragStretch: CGFloat = 0
    @State private var isDragging = false

    public init(isOn: Binding<Bool>, tint: LiquidSwitchTint = .aqua, width: CGFloat = 72, label: String = "Toggle") {
        self._isOn = isOn
        self.tint = tint
        self.width = width
        self.accessibilityTitle = label
    }

    private var height: CGFloat { width * 0.58 }
    private var inset: CGFloat { max(3, width * 0.045) }
    private var knob: CGFloat { height - inset * 2 }
    private var travel: CGFloat { width - knob - inset * 2 }

    /// Knob offset from its resting "off" position, including the live drag.
    private var knobX: CGFloat { rubberBand((isOn ? travel : 0) + dragOffset) }
    private var progress: CGFloat { min(max(knobX / max(travel, 1), 0), 1) }

    private let knobSpring = Animation.spring(response: 0.42, dampingFraction: 0.58)
    private let fillSpring = Animation.spring(response: 0.62, dampingFraction: 0.66)

    public var body: some View {
        ZStack(alignment: .leading) {
            track
            liquidFill
            splash
            knobView
        }
        .frame(width: width, height: height)
        .contentShape(Capsule())
        .onTapGesture {
            withAnimation(knobSpring) { isOn.toggle() }
        }
        .gesture(dragGesture)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.9), trigger: isOn)
        .accessibilityElement()
        .accessibilityLabel(accessibilityTitle)
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityAddTraits(.isToggle)
        .accessibilityAction { withAnimation(knobSpring) { isOn.toggle() } }
    }

    // MARK: Layers

    private var track: some View {
        Capsule()
            .fill(Color(.tertiarySystemFill))
            .overlay(Capsule().strokeBorder(Color.primary.opacity(0.06), lineWidth: 1))
            .overlay(alignment: .top) {
                // Recessed inner shadow so the track feels carved in.
                Capsule()
                    .stroke(Color.black.opacity(0.12), lineWidth: 2)
                    .blur(radius: 2)
                    .offset(y: 1)
                    .clipShape(Capsule())
            }
    }

    /// The fill trails the knob on a softer spring, so it visibly "pours" behind it.
    private var liquidFill: some View {
        Capsule()
            .fill(LinearGradient(colors: tint.colors, startPoint: .leading, endPoint: .trailing))
            .overlay(alignment: .top) {
                Capsule()
                    .fill(LinearGradient(colors: [.white.opacity(0.45), .white.opacity(0)], startPoint: .top, endPoint: .bottom))
                    .frame(height: height * 0.42)
                    .padding(.horizontal, height * 0.18)
                    .padding(.top, 2)
            }
            .frame(width: knob + inset * 2 + knobX)
            .opacity(Double(min(progress * 1.8, 1)))
            .shadow(color: (tint.colors.last ?? .blue).opacity(0.45 * Double(progress)), radius: 10, y: 3)
            .animation(fillSpring, value: isOn)
    }

    /// A ring that ripples out of the knob when it lands in the "on" position.
    private var splash: some View {
        let on = isOn
        return Circle()
            .strokeBorder(tint.colors.last ?? .blue, lineWidth: 2)
            .frame(width: knob, height: knob)
            .keyframeAnimator(initialValue: LiquidSwitchSplash(), trigger: isOn) { content, value in
                content
                    .scaleEffect(value.scale)
                    .opacity(on ? value.opacity : 0)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    MoveKeyframe(1)
                    LinearKeyframe(1, duration: 0.2)
                    CubicKeyframe(1.9, duration: 0.45)
                }
                KeyframeTrack(\.opacity) {
                    MoveKeyframe(0)
                    LinearKeyframe(0, duration: 0.2)
                    LinearKeyframe(0.7, duration: 0.03)
                    CubicKeyframe(0, duration: 0.42)
                }
            }
            .offset(x: inset + travel)
            .allowsHitTesting(false)
    }

    private var knobView: some View {
        let anchor: UnitPoint = isOn ? .trailing : .leading
        return Circle()
            .fill(.white)
            .overlay {
                Circle()
                    .fill(LinearGradient(colors: [.white, Color(white: 0.9)], startPoint: .top, endPoint: .bottom))
                    .padding(knob * 0.08)
            }
            .overlay {
                Circle()
                    .fill(tint.colors.first ?? .blue)
                    .frame(width: knob * 0.22, height: knob * 0.22)
                    .scaleEffect(isOn ? 1 : 0.01)
                    .opacity(isOn ? 0.9 : 0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.5).delay(isOn ? 0.18 : 0), value: isOn)
            }
            .frame(width: knob, height: knob)
            .shadow(color: .black.opacity(0.22), radius: 4, y: 2)
            .shadow(color: .black.opacity(0.08), radius: 1, y: 0.5)
            // Live stretch from drag velocity
            .scaleEffect(x: 1 + dragStretch, y: 1 - dragStretch * 0.45)
            // Squash & stretch choreography on every flip
            .keyframeAnimator(initialValue: LiquidSwitchWobble(), trigger: isOn) { content, value in
                content.scaleEffect(x: value.stretchX, y: value.stretchY, anchor: anchor)
            } keyframes: { _ in
                KeyframeTrack(\.stretchX) {
                    CubicKeyframe(1.42, duration: 0.13)
                    SpringKeyframe(0.8, duration: 0.12, spring: .snappy)
                    SpringKeyframe(1.1, duration: 0.12)
                    SpringKeyframe(1.0, duration: 0.35, spring: .bouncy)
                }
                KeyframeTrack(\.stretchY) {
                    CubicKeyframe(0.76, duration: 0.13)
                    SpringKeyframe(1.14, duration: 0.12, spring: .snappy)
                    SpringKeyframe(0.95, duration: 0.12)
                    SpringKeyframe(1.0, duration: 0.35, spring: .bouncy)
                }
            }
            .offset(x: inset + knobX)
            .animation(knobSpring, value: isOn)
    }

    // MARK: Gesture

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 3)
            .onChanged { value in
                isDragging = true
                dragOffset = value.translation.width
                withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.7)) {
                    dragStretch = min(abs(value.velocity.width) / 2800, 0.32)
                }
            }
            .onEnded { value in
                let projected = (isOn ? travel : 0) + value.translation.width + value.velocity.width * 0.06
                let next = projected > travel / 2
                withAnimation(knobSpring) {
                    dragOffset = 0
                    dragStretch = 0
                    isDragging = false
                    isOn = next
                }
            }
    }

    private func rubberBand(_ x: CGFloat) -> CGFloat {
        if x < 0 { return x * 0.2 }
        if x > travel { return travel + (x - travel) * 0.2 }
        return x
    }
}

// MARK: - Animation Values

private struct LiquidSwitchWobble {
    var stretchX: CGFloat = 1
    var stretchY: CGFloat = 1
}

private struct LiquidSwitchSplash {
    var scale: CGFloat = 1
    var opacity: Double = 0
}

// MARK: - Preview

private struct LiquidSwitchPreviewRow: View {
    let title: String
    let icon: String
    let tint: LiquidSwitchTint
    @State var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(LinearGradient(colors: tint.colors, startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            Text(title).font(.headline)
            Spacer()
            LiquidSwitch(isOn: $isOn, tint: tint, label: title)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview("Liquid Switch") {
    VStack(spacing: 14) {
        LiquidSwitchPreviewRow(title: "Wi-Fi", icon: "wifi", tint: .aqua, isOn: true)
        LiquidSwitchPreviewRow(title: "Eco mode", icon: "leaf.fill", tint: .lime, isOn: false)
        LiquidSwitchPreviewRow(title: "Night shift", icon: "moon.stars.fill", tint: .sunset, isOn: false)
        LiquidSwitchPreviewRow(title: "Focus", icon: "sparkles", tint: .grape, isOn: true)
    }
    .padding(20)
    .frame(maxHeight: .infinity)
    .background(Color(.systemBackground))
}
