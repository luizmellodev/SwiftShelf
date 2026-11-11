import SwiftUI
import UIKit

// MARK: - Action

/// An action revealed by swiping a `SwipeActionsRow`.
public struct SwipeActionsRowAction: Identifiable {
    public let id = UUID()
    let title: String
    let systemImage: String
    let tint: Color
    /// Destructive actions slide the row away before running, so the parent
    /// can remove it and let the list collapse smoothly.
    let isDestructive: Bool
    let handler: () -> Void

    public init(_ title: String, systemImage: String, tint: Color, isDestructive: Bool = false, handler: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
        self.isDestructive = isDestructive
        self.handler = handler
    }
}

// MARK: - Swipe Actions Row

/// A custom list row with swipe-to-reveal actions on either side.
///
/// Action pills grow with the drag and their icons pop in with a bouncy
/// stagger. Past the last action the row rubber-bands; drag far enough and
/// the primary action snaps to fill the gap with a haptic — let go to
/// commit. Works inside a `ScrollView`: the pan only begins for horizontal
/// swipes, so vertical scrolling is never blocked.
public struct SwipeActionsRow<Content: View>: View {
    let leading: [SwipeActionsRowAction]
    let trailing: [SwipeActionsRowAction]
    var actionWidth: CGFloat
    var allowsFullSwipe: Bool
    var cornerRadius: CGFloat
    let content: Content

    @State private var offset: CGFloat = 0
    @State private var restingOffset: CGFloat = 0
    @State private var rowWidth: CGFloat = 360
    @State private var isFullSwipe = false
    @State private var commitCount = 0

    private let gap: CGFloat = 8

    /// - Parameters:
    ///   - leading: Actions revealed by swiping right. The first one is the full-swipe action.
    ///   - trailing: Actions revealed by swiping left. The first one is the full-swipe action.
    public init(
        leading: [SwipeActionsRowAction] = [],
        trailing: [SwipeActionsRowAction] = [],
        actionWidth: CGFloat = 76,
        allowsFullSwipe: Bool = true,
        cornerRadius: CGFloat = 22,
        @ViewBuilder content: () -> Content
    ) {
        self.leading = leading
        self.trailing = trailing
        self.actionWidth = actionWidth
        self.allowsFullSwipe = allowsFullSwipe
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    private var revealedActions: [SwipeActionsRowAction] { offset < 0 ? trailing : leading }
    private func maxReveal(for actions: [SwipeActionsRowAction]) -> CGFloat { CGFloat(actions.count) * actionWidth }
    private var fullSwipeThreshold: CGFloat { rowWidth * 0.6 }

    public var body: some View {
        ZStack {
            actionsLayer
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .offset(x: offset)
                .onTapGesture { if offset != 0 { close() } }
                .gesture(
                    SwipeActionsRowPan(
                        onChanged: dragChanged,
                        onEnded: dragEnded
                    )
                )
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { rowWidth = $0 }
        .sensoryFeedback(.impact(weight: .medium), trigger: isFullSwipe) { _, full in full }
        .sensoryFeedback(.success, trigger: commitCount)
        .sensoryFeedback(.selection, trigger: restingOffset)
        .accessibilityElement(children: .combine)
        .accessibilityActions {
            ForEach(leading + trailing) { action in
                Button(action.title) { perform(action) }
            }
        }
    }

    // MARK: Actions Layer

    private var actionsLayer: some View {
        let actions = revealedActions
        let revealed = abs(offset)
        let available = max(0, revealed - gap)
        let isTrailing = offset < 0

        return HStack(spacing: gap) {
            // The first action sits on the outer edge, like the system `swipeActions`.
            let ordered = isTrailing ? Array(actions.reversed()) : actions
            ForEach(Array(ordered.enumerated()), id: \.element.id) { position, action in
                let isPrimary = action.id == actions.first?.id
                let outerRank = isTrailing ? ordered.count - 1 - position : position
                let share = actions.isEmpty ? 0 : (available - gap * CGFloat(actions.count - 1)) / CGFloat(actions.count)
                let width = isFullSwipe ? (isPrimary ? available : 0) : max(0, share)
                let threshold = actionWidth * (0.35 + 0.45 * CGFloat(actions.count - 1 - outerRank))
                let iconShown = isFullSwipe ? isPrimary : revealed > threshold

                actionPill(action, width: width, iconShown: iconShown)
                    .opacity(isFullSwipe && !isPrimary ? 0 : 1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: isTrailing ? .trailing : .leading)
        .animation(.spring(response: 0.32, dampingFraction: 0.75), value: isFullSwipe)
        .opacity(offset == 0 ? 0 : 1)
    }

    private func actionPill(_ action: SwipeActionsRowAction, width: CGFloat, iconShown: Bool) -> some View {
        Button { perform(action) } label: {
            VStack(spacing: 4) {
                Image(systemName: action.systemImage)
                    .font(.system(size: 18, weight: .bold))
                Text(action.title)
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
                    .fixedSize()
            }
            .foregroundStyle(.white)
            .scaleEffect(iconShown ? 1 : 0.3)
            .opacity(iconShown ? 1 : 0)
            .animation(.spring(response: 0.38, dampingFraction: 0.5), value: iconShown)
            .frame(width: max(width, 0))
            .frame(maxHeight: .infinity)
            .background(action.tint.gradient, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .buttonStyle(SwipeActionsRowPillStyle())
        .accessibilityHidden(true)
    }

    // MARK: Gesture Handling

    private func dragChanged(_ translation: CGFloat) {
        let raw = restingOffset + translation
        let actions = raw < 0 ? trailing : leading
        guard !actions.isEmpty else {
            offset = rubberBand(raw, limit: 0)
            return
        }
        let limit = maxReveal(for: actions) + gap
        let full = allowsFullSwipe && abs(raw) > fullSwipeThreshold
        if full != isFullSwipe { isFullSwipe = full }
        offset = full ? raw : rubberBand(raw, limit: limit)
    }

    private func dragEnded(_ translation: CGFloat, _ velocity: CGFloat) {
        let actions = offset < 0 ? trailing : leading
        let limit = maxReveal(for: actions) + gap

        if isFullSwipe, let primary = actions.first {
            perform(primary)
            return
        }

        let projected = offset + velocity * 0.12
        let shouldOpen = !actions.isEmpty
            && abs(projected) > limit * 0.5
            && (projected < 0) == (offset < 0)

        withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
            offset = shouldOpen ? (offset < 0 ? -limit : limit) : 0
        }
        restingOffset = offset
    }

    /// iOS-style rubber banding past `limit`.
    private func rubberBand(_ value: CGFloat, limit: CGFloat) -> CGFloat {
        let magnitude = abs(value)
        guard magnitude > limit else { return value }
        let extra = magnitude - limit
        let dimension = max(rowWidth, 1)
        let banded = (1 - 1 / (extra * 0.55 / dimension + 1)) * dimension
        return (limit + banded) * (value < 0 ? -1 : 1)
    }

    private func perform(_ action: SwipeActionsRowAction) {
        commitCount += 1
        if action.isDestructive {
            let direction: CGFloat = offset > 0 ? 1 : -1
            withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                offset = direction * (rowWidth + 40)
                isFullSwipe = true
            } completion: {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    action.handler()
                }
            }
        } else {
            action.handler()
            close()
        }
    }

    private func close() {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.8)) {
            offset = 0
            isFullSwipe = false
        }
        restingOffset = 0
    }
}

// MARK: - Helpers

private struct SwipeActionsRowPillStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? -0.08 : 0)
    }
}

/// A horizontal-only pan. Unlike `DragGesture`, it refuses to begin for
/// vertical swipes, so an enclosing `ScrollView` keeps scrolling normally.
private struct SwipeActionsRowPan: UIGestureRecognizerRepresentable {
    let onChanged: (CGFloat) -> Void
    let onEnded: (CGFloat, CGFloat) -> Void

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer()
        recognizer.delegate = context.coordinator
        return recognizer
    }

    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        let translation = recognizer.translation(in: recognizer.view).x
        switch recognizer.state {
        case .began, .changed:
            onChanged(translation)
        case .ended, .cancelled, .failed:
            onEnded(translation, recognizer.velocity(in: recognizer.view).x)
        default:
            break
        }
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
            let velocity = pan.velocity(in: pan.view)
            return abs(velocity.x) > abs(velocity.y) * 1.2
        }
    }
}

// MARK: - Preview

#Preview("Swipe Actions Row") {
    @Previewable @State var mails = ["Weekly design sync", "Your receipt from Shelf", "Flight check-in is open", "New comment on Bento Grid"]

    ScrollView {
        VStack(spacing: 10) {
            ForEach(mails, id: \.self) { mail in
                SwipeActionsRow(
                    leading: [.init("Read", systemImage: "envelope.open.fill", tint: .blue) {}],
                    trailing: [
                        .init("Delete", systemImage: "trash.fill", tint: .red, isDestructive: true) {
                            mails.removeAll { $0 == mail }
                        },
                        .init("Flag", systemImage: "flag.fill", tint: .orange) {},
                    ]
                ) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mail).font(.headline)
                        Text("Swipe me either way").font(.subheadline).foregroundStyle(.secondary)
                    }
                    .padding(16)
                }
                .transition(.opacity.combined(with: .scale(0.9, anchor: .top)))
            }
        }
        .padding(20)
    }
    .background(Color(.systemGroupedBackground))
}
