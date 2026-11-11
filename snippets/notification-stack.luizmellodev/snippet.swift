import SwiftUI

// MARK: - Model

/// A single notification shown in a `NotificationStack`.
public struct NotificationStackMessage: Identifiable, Equatable {
    public let id = UUID()
    let app: String
    let systemImage: String
    let tint: Color
    let title: String
    let message: String
    let time: String

    public init(app: String, systemImage: String, tint: Color, title: String, message: String, time: String = "now") {
        self.app = app
        self.systemImage = systemImage
        self.tint = tint
        self.title = title
        self.message = message
        self.time = time
    }
}

// MARK: - Notification Stack

/// An iOS lock-screen style notification group.
///
/// Collapsed, the newest notification sits on top of a 3-deep stack of
/// scaled, dimmed layers. Tap to fan it out into a list with staggered
/// springs; swipe any notification sideways to dismiss it and the rest
/// glide up to fill the gap.
public struct NotificationStack: View {
    @Binding var messages: [NotificationStackMessage]
    var title: String
    var rowHeight: CGFloat
    var spacing: CGFloat
    var visibleLayers: Int

    @State private var isExpanded = false

    private let layerPeek: CGFloat = 11

    public init(
        messages: Binding<[NotificationStackMessage]>,
        title: String = "Notification Centre",
        rowHeight: CGFloat = 84,
        spacing: CGFloat = 10,
        visibleLayers: Int = 3
    ) {
        self._messages = messages
        self.title = title
        self.rowHeight = rowHeight
        self.spacing = spacing
        self.visibleLayers = max(1, visibleLayers)
    }

    private var stackHeight: CGFloat {
        guard !messages.isEmpty else { return 0 }
        if isExpanded {
            return CGFloat(messages.count) * rowHeight + CGFloat(messages.count - 1) * spacing
        }
        let layers = min(messages.count, visibleLayers)
        return rowHeight + CGFloat(layers - 1) * layerPeek
    }

    public var body: some View {
        VStack(spacing: 12) {
            header

            ZStack(alignment: .top) {
                ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                    row(message, index: index)
                }

                if messages.isEmpty {
                    Text("No Older Notifications")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .transition(.blurReplace)
                }
            }
            .frame(height: max(stackHeight, messages.isEmpty ? 40 : 0), alignment: .top)
        }
        .sensoryFeedback(.impact(weight: .light), trigger: isExpanded)
        .sensoryFeedback(.impact(weight: .medium), trigger: messages.count)
        .onChange(of: messages.count) { _, count in
            if count <= 1, isExpanded {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { isExpanded = false }
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.primary)
            Spacer()
            if isExpanded {
                Button {
                    setExpanded(false)
                } label: {
                    Label("Show less", systemImage: "chevron.up")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(.regularMaterial, in: Capsule())
                }
                .buttonStyle(.plain)
                .transition(.blurReplace.combined(with: .scale(0.8)))
            } else if messages.count > 1 {
                Text("+\(messages.count - 1)")
                    .font(.subheadline.weight(.bold))
                    .contentTransition(.numericText())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.regularMaterial, in: Capsule())
                    .transition(.blurReplace.combined(with: .scale(0.8)))
                    .accessibilityLabel("\(messages.count - 1) more notifications")
            }
        }
        .opacity(messages.isEmpty ? 0 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isExpanded)
        .animation(.snappy, value: messages.count)
    }

    // MARK: Row Placement

    private func row(_ message: NotificationStackMessage, index: Int) -> some View {
        let depth = min(index, visibleLayers - 1)
        let isHidden = !isExpanded && index >= visibleLayers
        let isFront = index == 0
        let yOffset = isExpanded
            ? CGFloat(index) * (rowHeight + spacing)
            : CGFloat(depth) * layerPeek
        let scale = isExpanded ? 1 : 1 - CGFloat(depth) * 0.055
        let order = isExpanded ? index : max(0, messages.count - 1 - index)

        return NotificationStackRow(
            message: message,
            height: rowHeight,
            showsContent: isExpanded || isFront,
            canSwipe: isExpanded || isFront,
            onTap: { if !isExpanded { setExpanded(true) } },
            onDismiss: { dismiss(message) }
        )
        .brightness(isExpanded ? 0 : -Double(depth) * 0.03)
        .scaleEffect(scale, anchor: .bottom)
        .offset(y: yOffset)
        .opacity(isHidden ? 0 : 1)
        .zIndex(Double(messages.count - index))
        .allowsHitTesting(!isHidden)
        .accessibilityHidden(!isExpanded && !isFront)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.78).delay(Double(min(order, 6)) * 0.035),
            value: isExpanded
        )
        .transition(.opacity)
    }

    // MARK: Actions

    private func setExpanded(_ expanded: Bool) {
        guard messages.count > 1 || !expanded else { return }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { isExpanded = expanded }
    }

    private func dismiss(_ message: NotificationStackMessage) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            messages.removeAll { $0.id == message.id }
        }
    }
}

// MARK: - Row

private struct NotificationStackRow: View {
    let message: NotificationStackMessage
    let height: CGFloat
    let showsContent: Bool
    let canSwipe: Bool
    let onTap: () -> Void
    let onDismiss: () -> Void

    @State private var dragX: CGFloat = 0
    @State private var isLeaving = false
    @State private var rowWidth: CGFloat = 360

    private let dismissDistance: CGFloat = 110

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: message.systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(message.tint.gradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(message.title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Text(message.time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(message.message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .opacity(showsContent ? 1 : 0)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: height, alignment: .top)
        // Pin the text color so the card stays legible even when a parent sets a white foreground.
        .foregroundStyle(Color(.label))
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.12), radius: 14, y: 6)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { rowWidth = $0 }
        .offset(x: dragX)
        .rotationEffect(.degrees(Double(dragX / rowWidth) * 4), anchor: .bottom)
        .opacity(1 - min(abs(dragX) / (rowWidth * 1.2), 0.6))
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onTapGesture(perform: onTap)
        .gesture(swipe, isEnabled: canSwipe && !isLeaving)
        .sensoryFeedback(.selection, trigger: abs(dragX) > dismissDistance) { _, crossed in crossed }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(message.app). \(message.title). \(message.message)")
        .accessibilityAction(named: "Dismiss", onDismiss)
    }

    private var swipe: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                dragX = value.translation.width
            }
            .onEnded { value in
                let predicted = value.predictedEndTranslation.width
                if abs(dragX) > dismissDistance || abs(predicted) > dismissDistance * 2.4 {
                    isLeaving = true
                    let direction: CGFloat = (abs(dragX) > dismissDistance ? dragX : predicted) < 0 ? -1 : 1
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
                        dragX = direction * (rowWidth + 80)
                    } completion: {
                        onDismiss()
                    }
                } else {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.62)) { dragX = 0 }
                }
            }
    }
}

// MARK: - Sample Data

public extension NotificationStackMessage {
    static let samples: [NotificationStackMessage] = [
        .init(app: "Messages", systemImage: "message.fill", tint: .green, title: "Maya", message: "Dinner at 8? I found a tiny ramen place near the park 🍜", time: "now"),
        .init(app: "Calendar", systemImage: "calendar", tint: .red, title: "Design review", message: "Starts in 15 minutes · Studio B", time: "2m ago"),
        .init(app: "Fitness", systemImage: "figure.run", tint: .orange, title: "Close your rings", message: "You're 12 minutes away from your exercise goal.", time: "18m ago"),
        .init(app: "Shelf", systemImage: "square.stack.3d.up.fill", tint: .indigo, title: "New component", message: "Notification Stack was added to your shelf.", time: "1h ago"),
        .init(app: "Weather", systemImage: "cloud.sun.fill", tint: .blue, title: "Clearing up", message: "Sunny from 3 PM. High of 24°.", time: "2h ago"),
    ]
}

// MARK: - Preview

#Preview("Notification Stack") {
    @Previewable @State var messages = NotificationStackMessage.samples

    ZStack(alignment: .top) {
        MeshGradient(
            width: 3, height: 3,
            points: [[0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.6, 0.45], [1, 0.5], [0, 1], [0.5, 1], [1, 1]],
            colors: [.indigo, .purple, .pink, .blue, .purple, .orange, .teal, .indigo, .pink]
        )
        .ignoresSafeArea()

        VStack(spacing: 24) {
            Text("9:41")
                .font(.system(size: 86, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            NotificationStack(messages: $messages)
            Spacer()
        }
        .padding(16)
    }
}
