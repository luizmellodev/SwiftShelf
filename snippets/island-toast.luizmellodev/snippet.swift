import SwiftUI
import UIKit

// MARK: - Model

public enum IslandToastStyle: Equatable {
    case success, error, info

    var tint: Color {
        switch self {
        case .success: Color(red: 0.2, green: 0.85, blue: 0.45)
        case .error: Color(red: 1.0, green: 0.3, blue: 0.32)
        case .info: Color(red: 0.25, green: 0.6, blue: 1.0)
        }
    }

    var systemImage: String {
        switch self {
        case .success: "checkmark"
        case .error: "exclamationmark"
        case .info: "bell.fill"
        }
    }

    var feedback: SensoryFeedback {
        switch self {
        case .success: .success
        case .error: .error
        case .info: .impact(weight: .light)
        }
    }
}

/// One toast. Two items are equal when they share an `id`, so re-presenting
/// a new item while one is visible morphs the content in place.
public struct IslandToastItem: Identifiable, Equatable {
    public let id = UUID()
    let style: IslandToastStyle
    let title: String
    let subtitle: String?
    let systemImage: String?
    let actionTitle: String?
    let action: (() -> Void)?
    let duration: TimeInterval

    public init(
        _ style: IslandToastStyle,
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        actionTitle: String? = nil,
        duration: TimeInterval = 3.2,
        action: (() -> Void)? = nil
    ) {
        self.style = style
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.duration = duration
        self.action = action
    }

    public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

// MARK: - Modifier

public extension View {
    /// Presents a Dynamic-Island-style toast whenever `item` becomes non-nil.
    /// The toast grows out of the island, auto-collapses after its duration,
    /// and can be flicked up to dismiss. `item` is reset to `nil` afterwards.
    ///
    /// It lives in its own pass-through window above the status bar, so it
    /// sits over navigation bars and sheets just like the real island.
    func islandToast(item: Binding<IslandToastItem?>) -> some View {
        modifier(IslandToastModifier(item: item))
    }
}

private struct IslandToastModifier: ViewModifier {
    @Binding var item: IslandToastItem?

    func body(content: Content) -> some View {
        content
            .onChange(of: item, initial: true) { _, newValue in
                IslandToastHost.shared.request(newValue) { dismissed in
                    if item?.id == dismissed { item = nil }
                }
            }
    }
}

// MARK: - Window Host

@MainActor @Observable
private final class IslandToastHost {
    static let shared = IslandToastHost()

    var requested: IslandToastItem?
    var topInset: CGFloat = 11
    /// Where the expanded toast settles: just below the status bar, which the system
    /// always draws above app windows.
    var expandedTop: CGFloat = 62
    var islandSize = CGSize(width: 126, height: 37)
    @ObservationIgnored var hitRect: CGRect?
    @ObservationIgnored var onDismiss: ((UUID) -> Void)?
    @ObservationIgnored private var window: IslandToastWindow?

    func request(_ item: IslandToastItem?, onDismiss: @escaping (UUID) -> Void) {
        if item != nil {
            self.onDismiss = onDismiss
            installWindowIfNeeded()
            window?.isHidden = false
        }
        requested = item
    }

    func finished(_ id: UUID) {
        hitRect = nil
        if requested == nil || requested?.id == id {
            requested = nil
            window?.isHidden = true
        }
        onDismiss?(id)
    }

    private func installWindowIfNeeded() {
        guard window == nil else { return }
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        guard let scene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first else { return }

        // Devices with a Dynamic Island have a ~59pt+ top inset; the island sits 11pt from the top.
        let safeTop = scene.windows.first(where: \.isKeyWindow)?.safeAreaInsets.top ?? 0
        let hasIsland = safeTop >= 51
        topInset = hasIsland ? 11 : max(safeTop, 8) + 4
        expandedTop = hasIsland ? safeTop + 2 : topInset
        islandSize = hasIsland ? CGSize(width: 126, height: 37) : CGSize(width: 120, height: 36)

        let window = IslandToastWindow(windowScene: scene)
        window.host = self
        window.windowLevel = .statusBar + 1
        window.backgroundColor = .clear
        let controller = UIHostingController(rootView: IslandToastOverlay(host: self))
        controller.view.backgroundColor = .clear
        window.rootViewController = controller
        window.isHidden = false
        self.window = window
    }
}

/// Only the toast itself receives touches; everything else falls through.
private final class IslandToastWindow: UIWindow {
    weak var host: IslandToastHost?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let rect = host?.hitRect, rect.insetBy(dx: -6, dy: -6).contains(point) else { return nil }
        return super.hitTest(point, with: event)
    }
}

// MARK: - Overlay

private struct IslandToastOverlay: View {
    let host: IslandToastHost

    @State private var shown: IslandToastItem?
    @State private var expanded = false
    @State private var drag: CGFloat = 0
    @State private var countdown: CGFloat = 1
    @State private var feedbackTick = 0
    @State private var containerWidth: CGFloat = 393

    private var morph: Animation { .spring(response: 0.5, dampingFraction: 0.74) }

    var body: some View {
        ZStack(alignment: .top) {
            if let shown {
                toast(shown)
                    .padding(.top, expanded ? host.expandedTop : host.topInset)
                    .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .top)))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { containerWidth = $0 }
        .ignoresSafeArea()
        .onChange(of: host.requested?.id, initial: true) { _, _ in present(host.requested) }
        .task(id: shown?.id) {
            guard let item = shown else { return }
            countdown = 1
            try? await Task.sleep(for: .milliseconds(450))
            withAnimation(.linear(duration: item.duration)) { countdown = 0 }
            try? await Task.sleep(for: .seconds(item.duration))
            guard !Task.isCancelled, shown?.id == item.id else { return }
            collapse()
        }
        .sensoryFeedback(trigger: feedbackTick) { _, _ in shown?.style.feedback }
    }

    // MARK: Toast

    private func toast(_ item: IslandToastItem) -> some View {
        let width = expanded ? min(containerWidth - 22, 520) : host.islandSize.width
        let height = expanded ? 78 : host.islandSize.height
        let pull = min(drag, 0)
        let stretch = max(drag, 0)

        return ZStack {
            content(item)
                .opacity(expanded ? 1 : 0)
                .blur(radius: expanded ? 0 : 8)
                .scaleEffect(expanded ? 1 : 0.85)
                .id(item.id)
                .transition(.blurReplace)
        }
        .frame(width: width, height: height + stretch * 0.25)
        .background {
            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                .fill(.black)
                .overlay {
                    // A faint tinted rim so the toast reads as "alive" over dark UI too.
                    RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                        .strokeBorder(item.style.tint.opacity(expanded ? 0.28 : 0), lineWidth: 1)
                }
                .shadow(color: .black.opacity(expanded ? 0.35 : 0), radius: 22, y: 12)
        }
        .scaleEffect(1 + pull / 600, anchor: .top)
        .offset(y: pull)
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { host.hitRect = $0 }
        .gesture(
            DragGesture(minimumDistance: 4)
                .onChanged { value in
                    let y = value.translation.height
                    drag = y < 0 ? y : sqrt(y) * 4 // rubber-band downward
                }
                .onEnded { value in
                    if value.translation.height < -24 || value.predictedEndTranslation.height < -80 {
                        collapse()
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { drag = 0 }
                    }
                }
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityAction(named: "Dismiss") { collapse() }
    }

    private func content(_ item: IslandToastItem) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(item.style.tint.opacity(0.22))
                Circle()
                    .trim(from: 0, to: countdown)
                    .stroke(item.style.tint, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .padding(1.25)
                Image(systemName: item.systemImage ?? item.style.systemImage)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(item.style.tint)
                    .symbolEffect(.bounce, value: expanded)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .lineLimit(1)

            Spacer(minLength: 4)

            if let actionTitle = item.actionTitle {
                Button {
                    item.action?()
                    collapse()
                } label: {
                    Text(actionTitle)
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(item.style.tint, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.leading, 17)
        .padding(.trailing, 16)
    }

    // MARK: Choreography

    private func present(_ item: IslandToastItem?) {
        guard let item else {
            if shown != nil { collapse() }
            return
        }
        guard item.id != shown?.id else { return }
        drag = 0

        if shown == nil {
            // Appear at island size (black on black — it "emerges" from the island)...
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                expanded = false
                shown = item
            }
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(60))
                // ...then blossom into the full toast.
                withAnimation(morph) { expanded = true }
                feedbackTick += 1
            }
        } else {
            withAnimation(morph) {
                shown = item
                expanded = true
            }
            feedbackTick += 1
        }
    }

    private func collapse() {
        guard let item = shown, expanded else { return }
        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            expanded = false
            drag = 0
        }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(380))
            guard shown?.id == item.id, !expanded else { return }
            withAnimation(.easeOut(duration: 0.18)) { shown = nil }
            host.finished(item.id)
        }
    }
}

// MARK: - Preview

#Preview("Island Toast") {
    @Previewable @State var toast: IslandToastItem?

    VStack(spacing: 14) {
        Button("Success") {
            toast = .init(.success, title: "Payment sent", subtitle: "$24.90 to Mia Chen", actionTitle: "View")
        }
        Button("Error") {
            toast = .init(.error, title: "Upload failed", subtitle: "Check your connection", actionTitle: "Retry")
        }
        Button("Info") {
            toast = .init(.info, title: "New message", subtitle: "Leo: are we still on for 7?", systemImage: "message.fill")
        }
    }
    .buttonStyle(.borderedProminent)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .islandToast(item: $toast)
}
