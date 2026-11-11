import SwiftUI

// MARK: - Stretchy Page Indicator

/// A liquid page indicator driven by a *continuous* progress (e.g. 1.37 means
/// 37% of the way from page 1 to page 2).
///
/// Dots grow into a capsule as their page approaches, and a gradient "ink"
/// stretches toward the next dot: its head leads during the first half of
/// the swipe and its tail catches up during the second — like a droplet.
public struct StretchyPageIndicator: View {
    let count: Int
    let progress: CGFloat
    var gradient: [Color]
    var dotSize: CGFloat
    var activeLength: CGFloat
    var spacing: CGFloat

    public init(
        count: Int,
        progress: CGFloat,
        gradient: [Color] = [.indigo, .purple],
        dotSize: CGFloat = 8,
        activeLength: CGFloat = 26,
        spacing: CGFloat = 8
    ) {
        self.count = count
        self.progress = progress
        self.gradient = gradient
        self.dotSize = dotSize
        self.activeLength = activeLength
        self.spacing = spacing
    }

    private var clamped: CGFloat { min(max(progress, 0), CGFloat(max(count - 1, 0))) }

    /// Length of dot `i` for the current progress.
    private func length(_ i: Int) -> CGFloat {
        let closeness = max(0, 1 - abs(clamped - CGFloat(i)))
        return dotSize + (activeLength - dotSize) * closeness
    }

    /// Leading edge of dot `i`.
    private func minX(_ i: Int) -> CGFloat {
        (0..<i).reduce(0) { $0 + length($1) + spacing }
    }

    private var totalWidth: CGFloat {
        minX(count - 1) + length(count - 1)
    }

    private var ink: (minX: CGFloat, maxX: CGFloat) {
        let from = Int(clamped.rounded(.down))
        let to = min(from + 1, count - 1)
        let t = clamped - CGFloat(from)
        let head = smooth(min(1, t * 2))
        let tail = smooth(max(0, t * 2 - 1))
        let leading = minX(from) + (minX(to) - minX(from)) * tail
        let trailing = (minX(from) + length(from)) + ((minX(to) + length(to)) - (minX(from) + length(from))) * head
        return (leading, trailing)
    }

    private func smooth(_ x: CGFloat) -> CGFloat { x * x * (3 - 2 * x) }

    public var body: some View {
        let ink = ink
        ZStack(alignment: .leading) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(Color.primary.opacity(0.16))
                    .frame(width: length(i), height: dotSize)
                    .offset(x: minX(i))
            }

            Capsule()
                .fill(LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing))
                .frame(width: max(ink.maxX - ink.minX, dotSize), height: dotSize)
                .offset(x: ink.minX)
                .shadow(color: (gradient.last ?? .accentColor).opacity(0.45), radius: 6, y: 2)
        }
        .frame(width: totalWidth, height: dotSize, alignment: .leading)
        .accessibilityElement()
        .accessibilityLabel("Page \(Int(clamped.rounded()) + 1) of \(count)")
    }
}

// MARK: - Onboarding Pager

public struct StretchyOnboardingPage: Identifiable {
    public let id = UUID()
    let systemImage: String
    let title: String
    let subtitle: String
    let colors: [Color]

    public init(systemImage: String, title: String, subtitle: String, colors: [Color]) {
        self.systemImage = systemImage
        self.title = title
        self.subtitle = subtitle
        self.colors = colors
    }
}

/// A complete onboarding pager: paging scroll view with parallax hero art,
/// the liquid indicator, and a "Continue" button that morphs into a wide
/// "Get started" on the last page.
public struct StretchyOnboardingPager: View {
    let pages: [StretchyOnboardingPage]
    var onFinish: () -> Void

    @State private var position: Int? = 0
    @State private var progress: CGFloat = 0

    public init(pages: [StretchyOnboardingPage], onFinish: @escaping () -> Void = {}) {
        self.pages = pages
        self.onFinish = onFinish
    }

    private var current: Int { min(max(Int(progress.rounded()), 0), pages.count - 1) }
    private var isLast: Bool { current == pages.count - 1 }
    private var colors: [Color] { pages.isEmpty ? [.indigo, .purple] : pages[current].colors }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Skip") { go(to: pages.count - 1) }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .opacity(isLast ? 0 : 1)
                    .disabled(isLast)
            }
            .padding(.horizontal, 24)
            .frame(height: 44)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        StretchyOnboardingPageView(page: page)
                            .containerRelativeFrame(.horizontal)
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .scrollPosition(id: $position)
            .onScrollGeometryChange(for: CGFloat.self) { geo in
                geo.containerSize.width > 0 ? geo.contentOffset.x / geo.containerSize.width : 0
            } action: { _, value in
                progress = value
            }

            VStack(spacing: 28) {
                StretchyPageIndicator(count: pages.count, progress: progress, gradient: colors)
                    .animation(.easeInOut(duration: 0.35), value: current)

                continueButton
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .background {
            // Soft page-tinted glow that crossfades as you swipe.
            RadialGradient(
                colors: [colors[0].opacity(0.22), .clear],
                center: .top,
                startRadius: 10,
                endRadius: 520
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: current)
        }
        .sensoryFeedback(.selection, trigger: current)
    }

    // MARK: Button

    private var continueButton: some View {
        Button {
            if isLast { onFinish() } else { go(to: current + 1) }
        } label: {
            HStack(spacing: 8) {
                Text(isLast ? "Get started" : "Continue")
                    .id(isLast)
                    .transition(.blurReplace)
                Image(systemName: isLast ? "sparkles" : "arrow.right")
                    .contentTransition(.symbolEffect(.replace))
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: isLast ? .infinity : 180)
            .frame(height: 56)
            .background {
                Capsule()
                    .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                    .shadow(color: (colors.last ?? .accentColor).opacity(0.4), radius: 16, y: 8)
            }
            .contentShape(Capsule())
        }
        .buttonStyle(StretchyOnboardingPressStyle())
        .animation(.spring(response: 0.5, dampingFraction: 0.72), value: isLast)
        .sensoryFeedback(.impact(weight: .medium), trigger: isLast) { _, new in new }
    }

    private func go(to index: Int) {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.86)) { position = index }
    }
}

// MARK: - Page

private struct StretchyOnboardingPageView: View {
    let page: StretchyOnboardingPage

    var body: some View {
        VStack(spacing: 36) {
            Spacer(minLength: 0)

            hero
                .visualEffect { content, proxy in
                    let x = proxy.frame(in: .scrollView(axis: .horizontal)).minX
                    let width = max(proxy.size.width, 1)
                    return content
                        .offset(x: -x * 0.55)
                        .scaleEffect(1 - min(abs(x) / width, 1) * 0.25)
                        .rotationEffect(.degrees(Double(x / width) * -12))
                }

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .multilineTextAlignment(.center)
                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            .visualEffect { content, proxy in
                let x = proxy.frame(in: .scrollView(axis: .horizontal)).minX
                let width = max(proxy.size.width, 1)
                return content
                    .offset(x: -x * 0.2)
                    .opacity(1 - min(abs(x) / width, 1) * 1.4)
            }

            Spacer(minLength: 0)
        }
    }

    private var hero: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: page.colors.map { $0.opacity(0.18) }, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 270, height: 270)

            Circle()
                .fill(LinearGradient(colors: page.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 180, height: 180)
                .shadow(color: (page.colors.last ?? .accentColor).opacity(0.45), radius: 30, y: 16)
                .overlay {
                    Circle()
                        .strokeBorder(.white.opacity(0.35), lineWidth: 1)
                }

            Image(systemName: page.systemImage)
                .font(.system(size: 76, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)

            // Small orbiting accents for depth
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(page.colors[i % page.colors.count].gradient)
                    .frame(width: [18, 12, 24][i], height: [18, 12, 24][i])
                    .offset(x: [-118, 112, 96][i], y: [-70, -96, 92][i])
            }
        }
        .frame(height: 280)
    }
}

private struct StretchyOnboardingPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Stretchy Page Indicator") {
    StretchyOnboardingPager(pages: [
        .init(systemImage: "sparkles", title: "Welcome to Shelf", subtitle: "Save the things you love and find them in a flash.", colors: [.indigo, .purple]),
        .init(systemImage: "square.stack.3d.up.fill", title: "Collect anything", subtitle: "Links, notes and photos — beautifully organised.", colors: [.pink, .orange]),
        .init(systemImage: "bolt.heart.fill", title: "Stay in sync", subtitle: "Everything follows you across all of your devices.", colors: [.teal, .blue]),
    ])
}
