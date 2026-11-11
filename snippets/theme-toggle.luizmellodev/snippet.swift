import SwiftUI
import UIKit

// MARK: - Theme Reveal Engine

/// Switches the whole window between light and dark mode with a circular
/// "ink" reveal that grows from a point on screen.
///
/// It snapshots the current window, flips `overrideUserInterfaceStyle`, then
/// punches an expanding hole in the snapshot. Because the real UI is never
/// duplicated, any SwiftUI hierarchy (with all its state) just works.
@MainActor
public enum ThemeReveal {
    private static var isAnimating = false

    /// Toggles light ⇄ dark, revealing the new theme from `origin` (global coordinates).
    public static func toggle(from origin: CGPoint, duration: TimeInterval = 0.8) {
        guard let window = keyWindow else { return }
        let next: UIUserInterfaceStyle = window.traitCollection.userInterfaceStyle == .dark ? .light : .dark
        apply(next, in: window, from: origin, duration: duration)
    }

    /// Sets a specific style, revealing it from `origin` (global coordinates).
    public static func set(_ style: UIUserInterfaceStyle, from origin: CGPoint, duration: TimeInterval = 0.8) {
        guard let window = keyWindow else { return }
        apply(style, in: window, from: origin, duration: duration)
    }

    private static func apply(_ style: UIUserInterfaceStyle, in window: UIWindow, from origin: CGPoint, duration: TimeInterval) {
        guard !isAnimating, window.traitCollection.userInterfaceStyle != style else { return }

        guard !UIAccessibility.isReduceMotionEnabled,
              let snapshot = window.snapshotView(afterScreenUpdates: false) else {
            window.overrideUserInterfaceStyle = style
            return
        }

        isAnimating = true
        window.addSubview(snapshot)
        window.overrideUserInterfaceStyle = style

        let bounds = window.bounds
        let radius = hypot(max(origin.x, bounds.width - origin.x),
                           max(origin.y, bounds.height - origin.y))

        let mask = CAShapeLayer()
        mask.fillRule = .evenOdd
        mask.path = holePath(in: bounds, center: origin, radius: radius)
        snapshot.layer.mask = mask

        let reveal = CABasicAnimation(keyPath: "path")
        reveal.fromValue = holePath(in: bounds, center: origin, radius: 0.5)
        reveal.toValue = mask.path
        reveal.duration = duration
        reveal.timingFunction = CAMediaTimingFunction(controlPoints: 0.7, 0, 0.25, 1)

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            snapshot.removeFromSuperview()
            isAnimating = false
        }
        mask.add(reveal, forKey: "reveal")
        CATransaction.commit()
    }

    private static func holePath(in rect: CGRect, center: CGPoint, radius: CGFloat) -> CGPath {
        let path = UIBezierPath(rect: rect)
        path.append(UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true))
        return path.cgPath
    }

    private static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }
}

// MARK: - Sun ⇄ Moon Morphing Icon

/// A sun that morphs into a crescent moon: the rays retract one by one while
/// a second circle eclipses the disc.
public struct SunMoonIcon: View {
    var isDark: Bool
    var size: CGFloat

    public init(isDark: Bool, size: CGFloat = 22) {
        self.isDark = isDark
        self.size = size
    }

    public var body: some View {
        let disc = isDark ? size * 0.72 : size * 0.44

        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Capsule()
                    .frame(width: size * 0.09, height: size * 0.17)
                    .offset(y: -size * 0.41)
                    .rotationEffect(.degrees(Double(index) * 45))
                    .scaleEffect(isDark ? 0.2 : 1)
                    .opacity(isDark ? 0 : 1)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.55)
                            .delay(isDark ? 0 : 0.18 + Double(index) * 0.03),
                        value: isDark
                    )
            }

            Circle()
                .frame(width: disc, height: disc)
                .mask {
                    Rectangle()
                        .overlay {
                            Circle()
                                .frame(width: disc, height: disc)
                                .offset(x: isDark ? size * 0.24 : size * 0.6,
                                        y: isDark ? -size * 0.2 : -size * 0.6)
                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                }
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(isDark ? 0 : 180))
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isDark)
    }
}

// MARK: - Theme Toggle Button

/// Circular glass button with the morphing sun/moon icon.
/// Tapping it flips the app theme with a circular reveal from the button.
public struct ThemeToggleButton: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var frame: CGRect = .zero
    @State private var taps = 0

    var size: CGFloat

    public init(size: CGFloat = 44) {
        self.size = size
    }

    public var body: some View {
        Button {
            taps += 1
            ThemeReveal.toggle(from: CGPoint(x: frame.midX, y: frame.midY))
        } label: {
            SunMoonIcon(isDark: colorScheme == .dark, size: size * 0.5)
                .foregroundStyle(.primary)
                .frame(width: size, height: size)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().strokeBorder(Color.primary.opacity(0.12), lineWidth: 1))
                .contentShape(Circle())
        }
        .buttonStyle(ThemePressStyle())
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame = $0 }
        .sensoryFeedback(.impact(weight: .medium), trigger: taps)
        .accessibilityLabel(colorScheme == .dark ? "Switch to light mode" : "Switch to dark mode")
    }
}

// MARK: - Day / Night Switch

/// A pill switch that turns a sunny sky into a starry night.
/// The knob slides, the moon eclipses the sun, clouds sink and stars twinkle in.
public struct DayNightSwitch: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var frame: CGRect = .zero

    var width: CGFloat

    public init(width: CGFloat = 88) {
        self.width = width
    }

    private var isDark: Bool { colorScheme == .dark }
    private var height: CGFloat { width * 0.46 }
    private var knob: CGFloat { height - 8 }
    private var knobLeft: CGFloat { 4 + knob / 2 }
    private var knobRight: CGFloat { width - 4 - knob / 2 }

    public var body: some View {
        let knobX = isDark ? knobRight : knobLeft

        ZStack {
            // Sky
            Capsule()
                .fill(
                    LinearGradient(
                        colors: isDark
                            ? [Color(red: 0.07, green: 0.09, blue: 0.22), Color(red: 0.18, green: 0.16, blue: 0.38)]
                            : [Color(red: 0.36, green: 0.67, blue: 0.98), Color(red: 0.55, green: 0.82, blue: 1.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Halo rings around the knob
            ForEach(1..<4, id: \.self) { ring in
                Circle()
                    .fill(.white.opacity(0.09))
                    .frame(width: knob + CGFloat(ring) * height * 0.42,
                           height: knob + CGFloat(ring) * height * 0.42)
                    .position(x: knobX, y: height / 2)
            }

            // Stars
            ForEach(Self.stars.indices, id: \.self) { index in
                let star = Self.stars[index]
                Circle()
                    .fill(.white)
                    .frame(width: star.size, height: star.size)
                    .phaseAnimator([0.35, 1.0]) { content, phase in
                        content.opacity(phase)
                    } animation: { _ in
                        .easeInOut(duration: star.twinkle)
                    }
                    .position(x: width * star.x, y: height * star.y)
                    .offset(y: isDark ? 0 : -height * 0.6)
                    .opacity(isDark ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(isDark ? Double(index) * 0.04 : 0), value: isDark)
            }

            // Clouds
            ZStack {
                cloud(scale: 1.0).offset(x: width * 0.24, y: height * 0.28)
                cloud(scale: 0.75).offset(x: width * 0.06, y: height * 0.36)
                    .opacity(0.85)
            }
            .offset(y: isDark ? height * 0.9 : 0)
            .opacity(isDark ? 0 : 1)

            // Knob: sun with a moon sliding over it
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(red: 1, green: 0.86, blue: 0.3), Color(red: 1, green: 0.62, blue: 0.13)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))

                Circle()
                    .fill(LinearGradient(colors: [Color(white: 0.96), Color(white: 0.76)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay {
                        ZStack {
                            crater(0.26).offset(x: -knob * 0.12, y: -knob * 0.14)
                            crater(0.17).offset(x: knob * 0.18, y: knob * 0.08)
                            crater(0.12).offset(x: -knob * 0.06, y: knob * 0.24)
                        }
                    }
                    .offset(x: isDark ? 0 : knob)
            }
            .frame(width: knob, height: knob)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
            .position(x: knobX, y: height / 2)
        }
        .frame(width: width, height: height)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(.black.opacity(0.08), lineWidth: 1))
        .animation(.spring(response: 0.55, dampingFraction: 0.72), value: isDark)
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame = $0 }
        .contentShape(Capsule())
        .onTapGesture {
            let destination = isDark ? knobLeft : knobRight
            ThemeReveal.toggle(from: CGPoint(x: frame.minX + destination, y: frame.midY))
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: isDark)
        .accessibilityElement()
        .accessibilityLabel("Dark mode")
        .accessibilityValue(isDark ? "On" : "Off")
        .accessibilityAddTraits(.isButton)
    }

    private func cloud(scale: CGFloat) -> some View {
        let unit = height * 0.32 * scale
        return ZStack {
            Circle().frame(width: unit * 1.3, height: unit * 1.3).offset(x: -unit * 0.5, y: unit * 0.1)
            Circle().frame(width: unit * 1.7, height: unit * 1.7).offset(y: -unit * 0.2)
            Circle().frame(width: unit * 1.2, height: unit * 1.2).offset(x: unit * 0.6, y: unit * 0.15)
        }
        .foregroundStyle(.white)
    }

    private func crater(_ ratio: CGFloat) -> some View {
        Circle()
            .fill(Color(white: 0.68))
            .frame(width: knob * ratio, height: knob * ratio)
    }

    private struct StarSpec {
        let x: CGFloat, y: CGFloat, size: CGFloat, twinkle: Double
    }

    private static let stars: [StarSpec] = [
        .init(x: 0.14, y: 0.28, size: 2.5, twinkle: 1.1),
        .init(x: 0.26, y: 0.62, size: 1.8, twinkle: 1.6),
        .init(x: 0.38, y: 0.24, size: 1.5, twinkle: 0.9),
        .init(x: 0.46, y: 0.7, size: 2.2, twinkle: 1.3),
        .init(x: 0.2, y: 0.82, size: 1.3, twinkle: 1.8),
        .init(x: 0.52, y: 0.42, size: 1.4, twinkle: 1.2),
    ]
}

// MARK: - Helpers

private struct ThemePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Theme Toggle") {
    NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Good evening")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Your shelf")
                            .font(.largeTitle.bold())
                    }
                    Spacer()
                    ThemeToggleButton()
                }

                HStack {
                    Text("Dark mode")
                        .font(.headline)
                    Spacer()
                    DayNightSwitch()
                }
                .padding(18)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                ForEach(0..<4, id: \.self) { index in
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill([Color.orange, .pink, .indigo, .teal][index].gradient)
                            .frame(width: 52, height: 52)
                        VStack(alignment: .leading, spacing: 6) {
                            Capsule().fill(.primary.opacity(0.8)).frame(width: 140, height: 10)
                            Capsule().fill(.secondary.opacity(0.5)).frame(width: 90, height: 8)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
    }
}
