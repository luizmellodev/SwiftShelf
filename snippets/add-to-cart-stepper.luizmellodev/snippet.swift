import SwiftUI

// MARK: - Add To Cart Stepper

/// An "Add" pill that morphs into a `– 1 +` stepper.
///
/// The same capsule stretches open, the digits roll up or down with
/// `numericText`, a ghost "+1"/"−1" floats away on every change, and the
/// minus becomes a trash can at one item. Back at zero it folds into "Add".
/// Tapping + at the limit shakes the pill with a warning haptic.
public struct AddToCartStepper: View {
    @Binding var quantity: Int
    var maxQuantity: Int
    var colors: [Color]
    var height: CGFloat
    var addTitle: String

    @State private var ghostTrigger = 0
    @State private var ghostIsIncrement = true
    @State private var limitHits = 0

    public init(
        quantity: Binding<Int>,
        maxQuantity: Int = 9,
        colors: [Color] = [Color(red: 1.0, green: 0.55, blue: 0.2), Color(red: 1.0, green: 0.3, blue: 0.38)],
        height: CGFloat = 40,
        addTitle: String = "Add"
    ) {
        self._quantity = quantity
        self.maxQuantity = maxQuantity
        self.colors = colors.isEmpty ? [.accentColor] : colors
        self.height = height
        self.addTitle = addTitle
    }

    private let morph = Animation.spring(response: 0.42, dampingFraction: 0.74)

    public var body: some View {
        pill
            .overlay(alignment: .top) { ghost }
            .keyframeAnimator(initialValue: CGFloat(0), trigger: limitHits) { content, x in
                content.offset(x: x)
            } keyframes: { _ in
                KeyframeTrack {
                    SpringKeyframe(-7, duration: 0.07)
                    SpringKeyframe(6, duration: 0.07)
                    SpringKeyframe(-4, duration: 0.07)
                    SpringKeyframe(0, duration: 0.2, spring: .bouncy)
                }
            }
            .animation(morph, value: quantity == 0)
            .animation(.snappy(duration: 0.3), value: quantity)
            .sensoryFeedback(trigger: quantity) { old, new in feedback(old, new) }
            .sensoryFeedback(.warning, trigger: limitHits)
            .modifier(accessibility)
    }

    private var accessibility: AddToCartStepperAccessibility {
        AddToCartStepperAccessibility(quantity: quantity, increment: increment, decrement: decrement)
    }

    private func feedback(_ old: Int, _ new: Int) -> SensoryFeedback? {
        new > old ? .increase : .decrease
    }

    private var pill: some View {
        HStack(spacing: 0) {
            if quantity == 0 {
                Button(action: increment) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: height * 0.36, weight: .heavy))
                        Text(addTitle)
                    }
                    .padding(.horizontal, height * 0.45)
                    .frame(height: height)
                    .contentShape(Capsule())
                }
                .buttonStyle(AddToCartStepperPressStyle(pressedScale: 0.92))
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.6).combined(with: .opacity).animation(morph.delay(0.06)),
                    removal: .scale(scale: 0.6).combined(with: .opacity)
                ))
            } else {
                stepperButton(systemImage: quantity == 1 ? "trash" : "minus", label: quantity == 1 ? "Remove" : "Decrease", action: decrement)
                    .transition(.move(edge: .trailing).combined(with: .opacity))

                Text("\(quantity)")
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(quantity)))
                    .frame(minWidth: height * 0.55)
                    .transition(.scale(0.3).combined(with: .opacity))

                stepperButton(systemImage: "plus", label: "Increase", action: increment)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .font(.system(size: height * 0.4, weight: .bold, design: .rounded))
        .foregroundStyle(.white)
        .background {
            Capsule()
                .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(Capsule().fill(LinearGradient(colors: [.white.opacity(0.25), .clear], startPoint: .top, endPoint: .center)))
                .shadow(color: (colors.last ?? colors[0]).opacity(0.35), radius: 8, y: 4)
        }
        .clipShape(Capsule())
    }

    // MARK: Pieces

    private func stepperButton(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: height * 0.36, weight: .heavy))
                .contentTransition(.symbolEffect(.replace))
                .frame(width: height, height: height)
                .contentShape(Rectangle())
        }
        .buttonStyle(AddToCartStepperPressStyle())
        .accessibilityLabel(label)
    }

    /// A "+1" / "−1" that drifts up out of the pill.
    private var ghost: some View {
        Text(ghostIsIncrement ? "+1" : "−1")
            .font(.system(size: 13, weight: .heavy, design: .rounded))
            .foregroundStyle(colors.last ?? colors[0])
            .keyframeAnimator(initialValue: AddToCartStepperGhost(), trigger: ghostTrigger) { content, value in
                content
                    .offset(y: value.y)
                    .scaleEffect(value.scale)
                    .opacity(value.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.y) {
                    MoveKeyframe(0)
                    CubicKeyframe(-26, duration: 0.6)
                }
                KeyframeTrack(\.opacity) {
                    MoveKeyframe(0)
                    LinearKeyframe(1, duration: 0.1)
                    LinearKeyframe(1, duration: 0.25)
                    LinearKeyframe(0, duration: 0.25)
                }
                KeyframeTrack(\.scale) {
                    MoveKeyframe(0.6)
                    SpringKeyframe(1.1, duration: 0.2, spring: .bouncy)
                    LinearKeyframe(0.9, duration: 0.4)
                }
            }
            .allowsHitTesting(false)
    }

    // MARK: Logic

    private func increment() {
        guard quantity < maxQuantity else {
            limitHits += 1
            return
        }
        ghostIsIncrement = true
        ghostTrigger += 1
        quantity += 1
    }

    private func decrement() {
        guard quantity > 0 else { return }
        ghostIsIncrement = false
        ghostTrigger += 1
        quantity -= 1
    }
}

private struct AddToCartStepperAccessibility: ViewModifier {
    let quantity: Int
    let increment: () -> Void
    let decrement: () -> Void

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(quantity == 0 ? "Add to cart" : "Quantity in cart")
            .accessibilityValue(quantity == 0 ? "" : "\(quantity)")
            .accessibilityAddTraits(quantity == 0 ? AccessibilityTraits.isButton : [])
            .accessibilityAction { increment() }
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: increment()
                case .decrement: decrement()
                @unknown default: break
                }
            }
    }
}

private struct AddToCartStepperGhost {
    var y: CGFloat = 0
    var opacity: Double = 0
    var scale: CGFloat = 1
}

private struct AddToCartStepperPressStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.78

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

// MARK: - Cart Badge

/// A bag icon with a count badge that pops every time the count changes.
/// Pair it with `AddToCartStepper` in a toolbar.
public struct AddToCartBadgeIcon: View {
    let count: Int
    var systemImage: String
    var tint: Color

    public init(count: Int, systemImage: String = "bag.fill", tint: Color = Color(red: 1.0, green: 0.3, blue: 0.38)) {
        self.count = count
        self.systemImage = systemImage
        self.tint = tint
    }

    public var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.primary)
            .symbolEffect(.bounce.down, value: count)
            .frame(width: 40, height: 40)
            .overlay(alignment: .topTrailing) {
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText(value: Double(count)))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .frame(minWidth: 18, minHeight: 18)
                        .background(tint, in: Capsule())
                        .overlay(Capsule().strokeBorder(Color(.systemBackground), lineWidth: 2))
                        .keyframeAnimator(initialValue: CGFloat(1), trigger: count) { content, scale in
                            content.scaleEffect(scale)
                        } keyframes: { _ in
                            KeyframeTrack {
                                SpringKeyframe(1.45, duration: 0.12, spring: .snappy)
                                SpringKeyframe(0.9, duration: 0.12)
                                SpringKeyframe(1.0, duration: 0.3, spring: .bouncy)
                            }
                        }
                        .offset(x: 4, y: -2)
                        .transition(.scale(0.2).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.6), value: count)
            .accessibilityElement()
            .accessibilityLabel("Cart")
            .accessibilityValue("\(count) items")
    }
}

// MARK: - Preview

private struct AddToCartStepperPreview: View {
    @State private var avocado = 0
    @State private var berries = 2

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Groceries").font(.title2.bold())
                Spacer()
                AddToCartBadgeIcon(count: avocado + berries)
            }
            row("Hass avocado", price: "$1.80", color: .green, quantity: $avocado)
            row("Blueberries", price: "$4.50", color: .indigo, quantity: $berries)
        }
        .padding(20)
        .frame(maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    private func row(_ title: String, price: String, color: Color, quantity: Binding<Int>) -> some View {
        HStack(spacing: 14) {
            Circle().fill(color.gradient).frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(price).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            AddToCartStepper(quantity: quantity)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview("Add To Cart Stepper") {
    AddToCartStepperPreview()
}
