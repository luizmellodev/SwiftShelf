import SwiftUI

// MARK: - Dock Item

/// A single app in a `MagneticDock`.
public struct MagneticDockItem: Identifiable {
    public let id: String
    public var title: String
    public var systemImage: String
    public var colors: [Color]
    public var badge: Int?

    public init(_ title: String, systemImage: String, colors: [Color], badge: Int? = nil, id: String? = nil) {
        self.id = id ?? title
        self.title = title
        self.systemImage = systemImage
        self.colors = colors.isEmpty ? [.accentColor] : colors
        self.badge = badge
    }
}

// MARK: - Magnetic Dock

/// A glassy, finger-driven dock whose icons magnify around your touch.
///
/// Slide a finger along it and icons swell on a smooth Gaussian falloff,
/// lifting out of the glass while their neighbours make room, so the dock
/// stretches around the finger instead of sliding out from under it. A label
/// bubble rides above the hovered icon and morphs between names, with a
/// haptic tick every time you cross an icon. Lift your finger to launch: the
/// chosen icon does a classic dock bounce and gains a running dot. Drag up
/// and away from the dock to cancel.
public struct MagneticDock: View {
    let items: [MagneticDockItem]
    var running: Binding<Set<String>>?
    var iconSize: CGFloat
    var magnification: CGFloat
    var onLaunch: (MagneticDockItem) -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var width: CGFloat = 0
    @State private var touch: CGPoint?
    @State private var isCancelled = false
    @State private var hovered: Int?
    @State private var localRunning: Set<String> = []
    @State private var bounces: [String: Int] = [:]
    @State private var launches = 0

    private let spacing: CGFloat = 10
    private let inset: CGFloat = 10
    private let dotArea: CGFloat = 9
    private let bubbleArea: CGFloat = 46
    private let cancelDistance: CGFloat = 70

    /// - Parameters:
    ///   - items: Apps shown in the dock, left to right.
    ///   - running: Optional binding to the ids of "running" apps (shown with a dot).
    ///     Launching inserts into it. Without a binding the dock tracks this itself.
    ///   - iconSize: Resting icon size in points.
    ///   - magnification: Peak scale of the icon under the finger.
    ///   - onLaunch: Called when the finger lifts over an icon.
    public init(
        items: [MagneticDockItem],
        running: Binding<Set<String>>? = nil,
        iconSize: CGFloat = 50,
        magnification: CGFloat = 1.8,
        onLaunch: @escaping (MagneticDockItem) -> Void = { _ in }
    ) {
        self.items = items
        self.running = running
        self.iconSize = iconSize
        self.magnification = max(1, magnification)
        self.onLaunch = onLaunch
    }

    // MARK: Geometry

    private var restWidth: CGFloat {
        CGFloat(items.count) * iconSize + CGFloat(max(items.count - 1, 0)) * spacing + inset * 2
    }
    private var restLeft: CGFloat { (width - restWidth) / 2 }
    private var dockHeight: CGFloat { inset + iconSize + dotArea + 6 }
    private var lift: CGFloat { iconSize * 0.25 }
    private var height: CGFloat { bubbleArea + lift + iconSize * (magnification - 1) * 1.25 + dockHeight }

    /// The finger position that drives magnification (nil when idle or cancelled).
    private var activeX: CGFloat? { isCancelled ? nil : touch?.x }

    private struct Layout {
        /// Scale used for layout (how much room each icon takes).
        var scales: [CGFloat]
        /// Scale actually drawn; may exceed `scales` when the screen is too narrow to stretch further.
        var visual: [CGFloat]
        var left: CGFloat
        var width: CGFloat
    }

    private func layout() -> Layout {
        let ones = Array(repeating: CGFloat(1), count: items.count)
        guard let x = activeX, width > 0 else { return Layout(scales: ones, visual: ones, left: restLeft, width: restWidth) }

        // Gaussian falloff measured against *resting* centres, so it never feeds back on itself.
        let sigma = (iconSize + spacing) * 0.95
        let raw = items.indices.map { i -> CGFloat in
            let d = x - restCenter(i)
            return (magnification - 1) * exp(-(d * d) / (2 * sigma * sigma))
        }
        // Never stretch wider than the screen allows; past that, icons overlap a little instead.
        let room = max(0, width - 16 - restWidth)
        let extra = raw.reduce(0, +) * iconSize
        let grow = extra > room && extra > 0 ? raw.map { $0 * room / extra } : raw
        let scales = grow.map { 1 + $0 }
        let total = restWidth + grow.reduce(0, +) * iconSize

        // Keep the point under the finger fixed while the dock grows around it.
        let r = x - restLeft
        var offset = r
        if r > inset {
            var rest = inset, actual = inset
            for i in items.indices {
                let w = iconSize * scales[i]
                if r <= rest + iconSize { offset = actual + (r - rest) / iconSize * w; break }
                rest += iconSize; actual += w
                if i < items.count - 1 {
                    if r <= rest + spacing { offset = actual + (r - rest); break }
                    rest += spacing; actual += spacing
                } else {
                    offset = actual + (r - rest)
                }
            }
        }
        var left = x - offset
        left = min(max(left, 8), max(8, width - 8 - total))
        return Layout(scales: scales, visual: raw.map { 1 + $0 }, left: left, width: total)
    }

    private func restCenter(_ i: Int) -> CGFloat {
        restLeft + inset + CGFloat(i) * (iconSize + spacing) + iconSize / 2
    }

    private func center(_ i: Int, in l: Layout) -> CGFloat {
        var x = l.left + inset
        for j in 0..<i { x += iconSize * l.scales[j] + spacing }
        return x + iconSize * l.scales[i] / 2
    }

    private func index(at x: CGFloat) -> Int? {
        let r = x - restLeft
        guard r > -spacing, r < restWidth + spacing, !items.isEmpty else { return nil }
        let i = Int(((r - inset + spacing / 2) / (iconSize + spacing)).rounded(.down))
        return min(max(i, 0), items.count - 1)
    }

    private var runningIDs: Set<String> { running?.wrappedValue ?? localRunning }

    // MARK: Body

    public var body: some View {
        let l = layout()
        let animation: Animation = activeX == nil
            ? .spring(response: 0.5, dampingFraction: 0.62)
            : .interactiveSpring(response: 0.22, dampingFraction: 0.8)

        ZStack(alignment: .topLeading) {
            dock(l)
                .offset(x: l.left, y: height - dockHeight)
            bubble(l)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height, alignment: .topLeading)
        .animation(animation, value: activeX)
        .coordinateSpace(name: "magneticDock")
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
        .sensoryFeedback(.selection, trigger: hovered) { _, new in new != nil }
        .sensoryFeedback(.impact(weight: .medium, intensity: 0.9), trigger: launches)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Dock")
    }

    // MARK: Dock

    private func dock(_ l: Layout) -> some View {
        HStack(alignment: .bottom, spacing: spacing) {
            ForEach(Array(items.enumerated()), id: \.element.id) { i, item in
                cell(item, slot: l.scales[i], scale: l.visual[i])
            }
        }
        .padding(.horizontal, inset)
        .padding(.top, inset)
        .padding(.bottom, 6)
        .frame(width: l.width, height: dockHeight, alignment: .bottom)
        .background { glass(l) }
        .contentShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("magneticDock"))
                .onChanged(track)
                .onEnded(release)
        )
    }

    private func glass(_ l: Layout) -> some View {
        let shape = RoundedRectangle(cornerRadius: 26, style: .continuous)
        let dark = colorScheme == .dark
        return shape
            .fill(.ultraThinMaterial)
            .overlay {
                // Soft spotlight that follows the finger through the glass.
                if let x = activeX {
                    Circle()
                        .fill(RadialGradient(colors: [.white.opacity(dark ? 0.22 : 0.6), .clear],
                                             center: .center, startRadius: 0, endRadius: 70))
                        .frame(width: 140, height: 140)
                        .position(x: x - l.left, y: dockHeight * 0.65)
                        .blendMode(dark ? .plusLighter : .normal)
                        .transition(.opacity)
                }
            }
            .clipShape(shape)
            .overlay {
                shape.strokeBorder(
                    LinearGradient(colors: [.white.opacity(dark ? 0.28 : 0.7), .white.opacity(dark ? 0.05 : 0.15)],
                                   startPoint: .top, endPoint: .bottom),
                    lineWidth: 1
                )
            }
            .shadow(color: .black.opacity(dark ? 0.45 : 0.18), radius: 24, y: 12)
            .accessibilityHidden(true)
    }

    private func cell(_ item: MagneticDockItem, slot: CGFloat, scale: CGFloat) -> some View {
        let isRunning = runningIDs.contains(item.id)
        let t = magnification > 1 ? (scale - 1) / (magnification - 1) : 0
        let still = reduceMotion

        return VStack(spacing: 4) {
            icon(item)
                .keyframeAnimator(initialValue: MagneticDockBounce(), trigger: bounces[item.id, default: 0]) { content, v in
                    content
                        .scaleEffect(x: still ? 1 : v.stretchX, y: still ? 1 : v.stretchY, anchor: .bottom)
                        .offset(y: still ? 0 : v.y)
                        .brightness(still ? v.flash : 0)
                } keyframes: { _ in
                    KeyframeTrack(\.y) {
                        CubicKeyframe(-30, duration: 0.2)
                        CubicKeyframe(0, duration: 0.18)
                        CubicKeyframe(-17, duration: 0.17)
                        CubicKeyframe(0, duration: 0.15)
                        CubicKeyframe(-7, duration: 0.12)
                        SpringKeyframe(0, duration: 0.25, spring: .bouncy)
                    }
                    KeyframeTrack(\.stretchY) {
                        CubicKeyframe(1.08, duration: 0.2)
                        CubicKeyframe(0.86, duration: 0.18)
                        CubicKeyframe(1.04, duration: 0.17)
                        CubicKeyframe(0.93, duration: 0.15)
                        SpringKeyframe(1, duration: 0.37, spring: .bouncy)
                    }
                    KeyframeTrack(\.stretchX) {
                        CubicKeyframe(0.94, duration: 0.2)
                        CubicKeyframe(1.12, duration: 0.18)
                        CubicKeyframe(0.97, duration: 0.17)
                        CubicKeyframe(1.06, duration: 0.15)
                        SpringKeyframe(1, duration: 0.37, spring: .bouncy)
                    }
                    KeyframeTrack(\.flash) {
                        CubicKeyframe(0.25, duration: 0.15)
                        CubicKeyframe(0, duration: 0.5)
                    }
                }
                .shadow(color: (item.colors.last ?? .black).opacity(0.25 + 0.2 * t), radius: 4 + 8 * t, y: 3 + 6 * t)
                .scaleEffect(scale, anchor: .bottom)
                .offset(y: -lift * t)
                .frame(width: iconSize * slot, height: iconSize, alignment: .bottom)
                .zIndex(Double(scale))

            Circle()
                .fill(Color.primary.opacity(0.7))
                .frame(width: 5, height: 5)
                .scaleEffect(isRunning ? 1 : 0.01)
                .opacity(isRunning ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(isRunning ? 0.55 : 0), value: isRunning)
        }
        .zIndex(Double(scale))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.title)
        .accessibilityValue(accessibilityValue(item, isRunning: isRunning))
        .accessibilityHint("Opens \(item.title)")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { launch(item) }
    }

    private func accessibilityValue(_ item: MagneticDockItem, isRunning: Bool) -> String {
        var parts: [String] = []
        if isRunning { parts.append("Running") }
        if let badge = item.badge, badge > 0 { parts.append("\(badge) new") }
        return parts.joined(separator: ", ")
    }

    private func icon(_ item: MagneticDockItem) -> some View {
        let shape = RoundedRectangle(cornerRadius: iconSize * 0.26, style: .continuous)
        return shape
            .fill(LinearGradient(colors: item.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                // Glossy top highlight.
                shape.fill(LinearGradient(colors: [.white.opacity(0.35), .clear], startPoint: .top, endPoint: .center))
            }
            .overlay {
                Image(systemName: item.systemImage)
                    .font(.system(size: iconSize * 0.44, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 1.5, y: 1)
            }
            .overlay { shape.strokeBorder(.white.opacity(0.22), lineWidth: 0.75) }
            .overlay(alignment: .topTrailing) {
                if let badge = item.badge, badge > 0 {
                    Text(badge > 99 ? "99+" : "\(badge)")
                        .font(.system(size: iconSize * 0.24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .frame(minWidth: iconSize * 0.36, minHeight: iconSize * 0.36)
                        .background(Color.red, in: Capsule())
                        .overlay(Capsule().strokeBorder(.white.opacity(0.9), lineWidth: 1.5))
                        .offset(x: iconSize * 0.12, y: -iconSize * 0.12)
                }
            }
            .frame(width: iconSize, height: iconSize)
    }

    // MARK: Label Bubble

    @ViewBuilder
    private func bubble(_ l: Layout) -> some View {
        let shown = hovered != nil && activeX != nil
        let i = min(hovered ?? 0, max(items.count - 1, 0))
        if !items.isEmpty {
            let scale = l.visual[i]
            let t = magnification > 1 ? (scale - 1) / (magnification - 1) : 0
            let iconTop = height - 6 - dotArea - iconSize * scale - lift * t

            VStack(spacing: -1) {
                ZStack {
                    Text(items[i].title)
                        .id(items[i].id)
                        .transition(.blurReplace.combined(with: .scale(0.85)))
                }
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.thickMaterial, in: Capsule())
                .overlay(Capsule().strokeBorder(Color.primary.opacity(0.08), lineWidth: 1))

                MagneticDockTail()
                    .fill(.thickMaterial)
                    .frame(width: 14, height: 7)
            }
            .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
            .fixedSize()
            .animation(.snappy(duration: 0.28), value: hovered)
            .scaleEffect(shown ? 1 : 0.5, anchor: .bottom)
            .opacity(shown ? 1 : 0)
            .position(x: center(i, in: l), y: iconTop - 30)
            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: shown)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }

    // MARK: Interaction

    private func track(_ value: DragGesture.Value) {
        touch = value.location
        isCancelled = value.location.y < height - dockHeight - cancelDistance
        let next = isCancelled ? nil : index(at: value.location.x)
        if next != hovered { hovered = next }
    }

    private func release(_ value: DragGesture.Value) {
        if !isCancelled, let i = hovered, items.indices.contains(i) {
            launch(items[i])
        }
        hovered = nil
        touch = nil
        isCancelled = false
    }

    private func launch(_ item: MagneticDockItem) {
        bounces[item.id, default: 0] += 1
        launches += 1
        if let running {
            running.wrappedValue.insert(item.id)
        } else {
            localRunning.insert(item.id)
        }
        onLaunch(item)
    }
}

// MARK: - Helpers

private struct MagneticDockBounce {
    var y: CGFloat = 0
    var stretchX: CGFloat = 1
    var stretchY: CGFloat = 1
    var flash: Double = 0
}

private struct MagneticDockTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.midX - rect.width * 0.12, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control: CGPoint(x: rect.midX + rect.width * 0.12, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var running: Set<String> = ["Safari"]

    ZStack {
        MeshGradient(
            width: 3, height: 3,
            points: [[0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.6, 0.45], [1, 0.5], [0, 1], [0.5, 1], [1, 1]],
            colors: [.indigo, .purple, .pink, .blue, .purple, .orange, .teal, .indigo, .pink]
        )
        .opacity(0.55)
        .ignoresSafeArea()

        VStack {
            Spacer()
            MagneticDock(
                items: [
                    MagneticDockItem("Phone", systemImage: "phone.fill", colors: [.green, .mint]),
                    MagneticDockItem("Messages", systemImage: "message.fill", colors: [.green, .teal], badge: 3),
                    MagneticDockItem("Safari", systemImage: "safari.fill", colors: [.cyan, .blue]),
                    MagneticDockItem("Music", systemImage: "music.note", colors: [.pink, .red]),
                    MagneticDockItem("Camera", systemImage: "camera.fill", colors: [Color(.systemGray3), Color(.systemGray)]),
                ],
                running: $running
            )
            .padding(.bottom, 24)
        }
    }
}
