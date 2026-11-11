import SwiftUI

// MARK: - Menu Item

public struct MorphMenuItem: Identifiable {
    public let id = UUID()
    let title: String
    let subtitle: String?
    let systemImage: String
    let tint: Color
    let action: () -> Void

    public init(_ title: String, subtitle: String? = nil, systemImage: String, tint: Color = .blue, action: @escaping () -> Void = {}) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
        self.action = action
    }
}

// MARK: - Morph Action Menu

/// A floating "+" button that physically morphs into a menu panel —
/// the mobile-native alternative to a hamburger menu.
///
/// The same shape grows from the corner, the "+" spins into an "×",
/// and rows rise in with a staggered blur, nearest to your thumb first.
public struct MorphActionMenu: View {
    @Binding var isOpen: Bool
    let items: [MorphMenuItem]
    var panelWidth: CGFloat

    private let buttonSize: CGFloat = 60
    private let rowHeight: CGFloat = 60

    public init(isOpen: Binding<Bool>, items: [MorphMenuItem], panelWidth: CGFloat = 272) {
        self._isOpen = isOpen
        self.items = items
        self.panelWidth = panelWidth
    }

    private var panelHeight: CGFloat { CGFloat(items.count) * rowHeight + buttonSize + 8 }
    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: buttonSize / 2, style: .continuous) }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    row(item, index: index)
                }
                Spacer(minLength: 0)
            }
            .padding(.top, 8)
            .padding(.horizontal, 8)
            .frame(width: panelWidth, height: panelHeight, alignment: .top)
            .allowsHitTesting(isOpen)

            Button(action: toggle) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .rotationEffect(.degrees(isOpen ? 135 : 0))
                    .frame(width: buttonSize, height: buttonSize)
                    .contentShape(Circle())
            }
            .buttonStyle(MorphPressStyle())
            .accessibilityLabel(isOpen ? "Close menu" : "Open menu")
        }
        .frame(width: isOpen ? panelWidth : buttonSize,
               height: isOpen ? panelHeight : buttonSize,
               alignment: .bottomTrailing)
        .foregroundStyle(Color(.systemBackground))
        .background(Color(.label), in: shape)
        .clipShape(shape)
        .shadow(color: .black.opacity(isOpen ? 0.3 : 0.2), radius: isOpen ? 30 : 12, y: isOpen ? 14 : 6)
        .sensoryFeedback(.impact(weight: .medium), trigger: isOpen)
    }

    private func row(_ item: MorphMenuItem, index: Int) -> some View {
        // Rows closest to the button appear first.
        let order = Double(items.count - 1 - index)

        return Button {
            item.action()
            toggle()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(item.tint.gradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .opacity(0.55)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .frame(height: rowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(MorphRowStyle())
        .opacity(isOpen ? 1 : 0)
        .blur(radius: isOpen ? 0 : 10)
        .offset(y: isOpen ? 0 : 18)
        .scaleEffect(isOpen ? 1 : 0.92, anchor: .bottomTrailing)
        .animation(
            isOpen
                ? .spring(response: 0.5, dampingFraction: 0.8).delay(0.06 + order * 0.045)
                : .easeOut(duration: 0.14),
            value: isOpen
        )
    }

    private func toggle() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
            isOpen.toggle()
        }
    }
}

// MARK: - Screen Modifier

public extension View {
    /// Pins a `MorphActionMenu` to the bottom-trailing corner and softly
    /// blurs/dims the screen behind it while open.
    func morphActionMenu(isOpen: Binding<Bool>, items: [MorphMenuItem]) -> some View {
        modifier(MorphActionMenuModifier(isOpen: isOpen, items: items))
    }
}

private struct MorphActionMenuModifier: ViewModifier {
    @Binding var isOpen: Bool
    let items: [MorphMenuItem]

    func body(content: Content) -> some View {
        content
            .blur(radius: isOpen ? 6 : 0)
            .overlay {
                Color.black
                    .opacity(isOpen ? 0.18 : 0)
                    .ignoresSafeArea()
                    .allowsHitTesting(isOpen)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) { isOpen = false }
                    }
            }
            .overlay(alignment: .bottomTrailing) {
                MorphActionMenu(isOpen: $isOpen, items: items)
                    .padding(20)
            }
            .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Morph Search Bar

/// A header whose search icon morphs into a full-width search field.
/// The title blurs away, the circle stretches into a capsule and
/// the keyboard comes up — all in one continuous motion.
public struct MorphSearchBar: View {
    let title: String
    @Binding var text: String
    @Binding var isExpanded: Bool
    @FocusState private var isFocused: Bool

    private let height: CGFloat = 48
    private let motion = Animation.spring(response: 0.48, dampingFraction: 0.82)

    public init(title: String, text: Binding<String>, isExpanded: Binding<Bool>) {
        self.title = title
        self._text = text
        self._isExpanded = isExpanded
    }

    public var body: some View {
        HStack(spacing: 12) {
            if !isExpanded {
                Text(title)
                    .font(.largeTitle.bold())
                    .lineLimit(1)
                    .transition(.blurReplace.combined(with: .move(edge: .leading)))
                Spacer(minLength: 0)
            }

            HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: height, height: height)

                if isExpanded {
                    TextField("Search", text: $text)
                        .focused($isFocused)
                        .submitLabel(.search)
                        .transition(.opacity)

                    if !text.isEmpty {
                        Button {
                            text = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                                .frame(width: 36, height: height)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .frame(maxWidth: isExpanded ? .infinity : height, alignment: .leading)
            .frame(height: height)
            .background(Color(.secondarySystemFill), in: Capsule())
            .contentShape(Capsule())
            .onTapGesture {
                guard !isExpanded else { return }
                withAnimation(motion) { isExpanded = true }
                isFocused = true
            }
            .accessibilityAddTraits(isExpanded ? [] : .isButton)
            .accessibilityLabel(isExpanded ? "" : "Search")

            if isExpanded {
                Button("Cancel") {
                    isFocused = false
                    withAnimation(motion) {
                        isExpanded = false
                        text = ""
                    }
                }
                .fontWeight(.medium)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .frame(height: 52)
        .animation(.snappy, value: text.isEmpty)
        .sensoryFeedback(.impact(weight: .light), trigger: isExpanded)
    }
}

// MARK: - Helpers

private struct MorphPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.86 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

private struct MorphRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.systemBackground).opacity(configuration.isPressed ? 0.12 : 0))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Morphing Controls") {
    @Previewable @State var isOpen = false
    @Previewable @State var query = ""
    @Previewable @State var searching = false

    VStack(alignment: .leading, spacing: 16) {
        MorphSearchBar(title: "Discover", text: $query, isExpanded: $searching)

        ForEach(0..<5, id: \.self) { index in
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill([Color.orange, .pink, .indigo, .teal, .mint][index].gradient)
                .frame(height: 90)
        }
        Spacer()
    }
    .padding(20)
    .morphActionMenu(isOpen: $isOpen, items: [
        .init("New note", subtitle: "Start from scratch", systemImage: "square.and.pencil", tint: .orange),
        .init("Scan document", subtitle: "Use the camera", systemImage: "doc.viewfinder", tint: .blue),
        .init("Voice memo", subtitle: "Record & transcribe", systemImage: "waveform", tint: .pink),
    ])
}
