import SwiftUI

// MARK: - Tab Item

/// A single destination in a `GooeyTabBar`.
public struct GooeyTabBarItem: Identifiable {
    public let id: Int
    let title: String
    let systemImage: String

    public init(_ title: String, systemImage: String, id: Int? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.id = id ?? title.hashValue
    }
}

// MARK: - Gooey Tab Bar

/// A floating tab bar whose selection indicator is a blob of goo.
///
/// Three metaballs chase the selected tab on progressively softer springs;
/// a `Canvas` blurs them together and an alpha threshold snaps the blur back
/// into a crisp edge, so they stretch into one gooey shape mid-flight and
/// merge back into a single drop on arrival. Tap a tab or scrub your finger
/// along the bar; icons bounce as the drop lands.
public struct GooeyTabBar: View {
    @Binding var selection: Int
    let items: [GooeyTabBarItem]
    var colors: [Color]
    var height: CGFloat

    @State private var width: CGFloat = 0
    @State private var bounces: [Int: Int] = [:]

    public init(
        selection: Binding<Int>,
        items: [GooeyTabBarItem],
        colors: [Color] = [Color(red: 0.4, green: 0.35, blue: 1.0), Color(red: 0.95, green: 0.35, blue: 0.75)],
        height: CGFloat = 66
    ) {
        self._selection = selection
        self.items = items
        self.colors = colors.isEmpty ? [.accentColor] : colors
        self.height = height
    }

    private var slot: CGFloat { width / CGFloat(max(items.count, 1)) }
    private var blob: CGFloat { min(height - 14, slot - 6) }

    private func centerX(_ index: Int) -> CGFloat { slot * (CGFloat(index) + 0.5) }

    public var body: some View {
        ZStack {
            goo
            icons
        }
        .frame(height: height)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
        .contentShape(Capsule())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { select(index(at: $0.location.x)) }
                .onEnded { select(index(at: $0.location.x)) }
        )
        .padding(.horizontal, 6)
        .background {
            Capsule()
                .fill(.regularMaterial)
                .overlay(Capsule().strokeBorder(Color.primary.opacity(0.08), lineWidth: 1))
                .shadow(color: .black.opacity(0.16), radius: 24, y: 12)
        }
        .sensoryFeedback(.selection, trigger: selection)
    }

    // MARK: Goo

    private var goo: some View {
        LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
            .mask {
                Canvas { context, size in
                    context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                    context.addFilter(.blur(radius: blob * 0.2))
                    context.drawLayer { layer in
                        for id in 0..<3 {
                            if let symbol = layer.resolveSymbol(id: id) {
                                layer.draw(symbol, at: CGPoint(x: size.width / 2, y: size.height / 2))
                            }
                        }
                    }
                } symbols: {
                    ball(diameter: blob, spring: .spring(response: 0.3, dampingFraction: 0.68)).tag(0)
                    ball(diameter: blob * 0.78, spring: .spring(response: 0.48, dampingFraction: 0.7)).tag(1)
                    ball(diameter: blob * 0.6, spring: .spring(response: 0.66, dampingFraction: 0.72)).tag(2)
                }
            }
            .overlay {
                // Glossy highlight riding on top of the drop.
                Capsule()
                    .fill(LinearGradient(colors: [.white.opacity(0.45), .clear], startPoint: .top, endPoint: .bottom))
                    .frame(width: blob * 0.62, height: blob * 0.3)
                    .position(x: centerX(selection), y: height / 2 - blob * 0.26)
                    .animation(.spring(response: 0.3, dampingFraction: 0.68), value: selection)
                    .blendMode(.plusLighter)
            }
            .shadow(color: (colors.first ?? .purple).opacity(0.45), radius: 10, y: 5)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    /// A ball laid out across the full bar, so the canvas can draw every symbol at its center.
    private func ball(diameter: CGFloat, spring: Animation) -> some View {
        Circle()
            .frame(width: diameter, height: diameter)
            .position(x: centerX(selection), y: height / 2)
            .animation(spring, value: selection)
            .frame(width: width, height: height)
    }

    // MARK: Icons

    private var icons: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                let isSelected = index == selection
                Image(systemName: item.systemImage)
                    .font(.system(size: 21, weight: .semibold))
                    .symbolEffect(.bounce.up.byLayer, value: bounces[index, default: 0])
                    .foregroundStyle(isSelected ? Color.white : Color(.secondaryLabel))
                    .scaleEffect(isSelected ? 1.1 : 1)
                    .animation(.spring(response: 0.35, dampingFraction: 0.55).delay(isSelected ? 0.12 : 0), value: selection)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .accessibilityElement()
                    .accessibilityLabel(item.title)
                    .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
                    .accessibilityAction { select(index) }
            }
        }
    }

    // MARK: Logic

    private func index(at x: CGFloat) -> Int {
        guard slot > 0 else { return selection }
        return min(max(Int(x / slot), 0), items.count - 1)
    }

    private func select(_ index: Int) {
        guard index != selection else { return }
        selection = index
        bounces[index, default: 0] += 1
    }
}

// MARK: - Preview

private struct GooeyTabBarPreview: View {
    @State private var tab = 0
    private let items = [
        GooeyTabBarItem("Home", systemImage: "house.fill", id: 0),
        GooeyTabBarItem("Search", systemImage: "magnifyingglass", id: 1),
        GooeyTabBarItem("Create", systemImage: "plus.app.fill", id: 2),
        GooeyTabBarItem("Inbox", systemImage: "bell.fill", id: 3),
        GooeyTabBarItem("Profile", systemImage: "person.crop.circle.fill", id: 4),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            Text(items[tab].title)
                .font(.largeTitle.bold())
                .contentTransition(.opacity)
                .frame(maxHeight: .infinity)
            GooeyTabBar(selection: $tab, items: items)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
        }
        .animation(.snappy, value: tab)
    }
}

#Preview("Gooey Tab Bar") {
    GooeyTabBarPreview()
}
