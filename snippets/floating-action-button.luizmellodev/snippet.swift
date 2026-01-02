import SwiftUI

// MARK: - FAB Action Item
public struct FABActionItem: Identifiable {
    public let id = UUID()
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    public init(
        icon: String,
        label: String,
        color: Color = .blue,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.label = label
        self.color = color
        self.action = action
    }
}

// MARK: - FAB Style
public enum FABStyle {
    case circular
    case rounded
    case pill
    
    var cornerRadius: CGFloat {
        switch self {
        case .circular: return 30
        case .rounded: return 16
        case .pill: return 25
        }
    }
}

// MARK: - FAB Position
public enum FABPosition {
    case bottomRight
    case bottomLeft
    case topRight
    case topLeft
    
    var alignment: Alignment {
        switch self {
        case .bottomRight: return .bottomTrailing
        case .bottomLeft: return .bottomLeading
        case .topRight: return .topTrailing
        case .topLeft: return .topLeading
        }
    }
}

// MARK: - Floating Action Button
public struct FloatingActionButton: View {
    let icon: String
    let actions: [FABActionItem]
    let style: FABStyle
    let position: FABPosition
    let mainColor: Color
    let size: CGFloat
    
    @State private var isExpanded = false
    @State private var rotation: Double = 0
    @State private var showOverlay = false
    
    public init(
        icon: String = "plus",
        actions: [FABActionItem],
        style: FABStyle = .circular,
        position: FABPosition = .bottomRight,
        mainColor: Color = .blue,
        size: CGFloat = 60
    ) {
        self.icon = icon
        self.actions = actions
        self.style = style
        self.position = position
        self.mainColor = mainColor
        self.size = size
    }
    
    public var body: some View {
        ZStack(alignment: position.alignment) {
            // Overlay
            if showOverlay {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            isExpanded = false
                            rotation = 0
                            showOverlay = false
                        }
                    }
                    .transition(.opacity)
            }
            
            VStack(spacing: 16) {
                if position == .bottomRight || position == .bottomLeft {
                    actionButtons
                    mainButton
                } else {
                    mainButton
                    actionButtons
                }
            }
            .padding(position == .bottomRight || position == .bottomLeft ? .bottom : .top, 20)
            .padding(position == .bottomRight || position == .topRight ? .trailing : .leading, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: position.alignment)
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        if isExpanded {
            VStack(alignment: position == .bottomRight || position == .topRight ? .trailing : .leading, spacing: 12) {
                ForEach(Array(actions.enumerated()), id: \.element.id) { index, item in
                    actionButton(item: item, index: index)
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.3).combined(with: .opacity).combined(with: .move(edge: position == .bottomRight || position == .bottomLeft ? .bottom : .top)),
                                removal: .scale(scale: 0.3).combined(with: .opacity)
                            )
                        )
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.65)
                            .delay(Double(index) * 0.05),
                            value: isExpanded
                        )
                }
            }
        }
    }
    
    private func actionButton(item: FABActionItem, index: Int) -> some View {
        HStack(spacing: 0) {
            if position == .bottomRight || position == .topRight {
                Text(item.label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .opacity(isExpanded ? 1 : 0)
                    .scaleEffect(isExpanded ? 1 : 0.8)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.7)
                        .delay(Double(index) * 0.05 + 0.1),
                        value: isExpanded
                    )
                    .padding(.trailing, 12)
            }
            
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isExpanded = false
                    rotation = 0
                    showOverlay = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    item.action()
                }
            }) {
                Image(systemName: item.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(item.color)
                            .shadow(color: item.color.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            if position == .bottomLeft || position == .topLeft {
                Text(item.label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .opacity(isExpanded ? 1 : 0)
                    .scaleEffect(isExpanded ? 1 : 0.8)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.7)
                        .delay(Double(index) * 0.05 + 0.1),
                        value: isExpanded
                    )
                    .padding(.leading, 12)
            }
        }
    }
    
    private var mainButton: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isExpanded.toggle()
                rotation = isExpanded ? 45 : 0
                showOverlay = isExpanded
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(
                    RoundedRectangle(cornerRadius: style.cornerRadius)
                        .fill(mainColor)
                        .shadow(color: mainColor.opacity(0.4), radius: 12, x: 0, y: 6)
                )
                .rotationEffect(.degrees(rotation))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Speed Dial FAB (Alternative Style)
public struct SpeedDialFAB: View {
    let actions: [FABActionItem]
    let mainColor: Color
    
    @State private var isExpanded = false
    @State private var showOverlay = false
    
    public init(
        actions: [FABActionItem],
        mainColor: Color = .blue
    ) {
        self.actions = actions
        self.mainColor = mainColor
    }
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if showOverlay {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            isExpanded = false
                            showOverlay = false
                        }
                    }
                    .transition(.opacity)
            }
            
            VStack(alignment: .trailing, spacing: 16) {
                if isExpanded {
                    ForEach(Array(actions.enumerated()), id: \.element.id) { index, item in
                        HStack(spacing: 12) {
                            Text(item.label)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                )
                            
                            Button(action: {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    isExpanded = false
                                    showOverlay = false
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    item.action()
                                }
                            }) {
                                Image(systemName: item.icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 48, height: 48)
                                    .background(
                                        Circle()
                                            .fill(item.color)
                                            .shadow(color: item.color.opacity(0.3), radius: 6, x: 0, y: 3)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.5).combined(with: .opacity),
                                removal: .scale(scale: 0.5).combined(with: .opacity)
                            )
                        )
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.7)
                            .delay(Double(index) * 0.05),
                            value: isExpanded
                        )
                    }
                }
                
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                        showOverlay = isExpanded
                    }
                }) {
                    Image(systemName: isExpanded ? "xmark" : "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(mainColor)
                                .shadow(color: mainColor.opacity(0.4), radius: 12, x: 0, y: 6)
                        )
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showOverlay)
    }
}

// MARK: - Preview
#Preview("Floating Action Button") {
    TabView {
        // Standard FAB
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack {
                Text("Standard FAB")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            
            FloatingActionButton(
                actions: [
                    FABActionItem(
                        icon: "camera.fill",
                        label: "Camera",
                        color: .blue
                    ) {
                        print("Camera tapped")
                    },
                    FABActionItem(
                        icon: "photo.fill",
                        label: "Gallery",
                        color: .purple
                    ) {
                        print("Gallery tapped")
                    },
                    FABActionItem(
                        icon: "doc.fill",
                        label: "Document",
                        color: .orange
                    ) {
                        print("Document tapped")
                    },
                    FABActionItem(
                        icon: "link",
                        label: "Link",
                        color: .green
                    ) {
                        print("Link tapped")
                    }
                ],
                mainColor: .blue
            )
        }
        .tabItem {
            Label("Standard", systemImage: "circle.fill")
        }
        
        // Bottom Left FAB
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack {
                Text("Bottom Left FAB")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            
            FloatingActionButton(
                icon: "plus",
                actions: [
                    FABActionItem(
                        icon: "message.fill",
                        label: "Message",
                        color: .blue
                    ) {
                        print("Message tapped")
                    },
                    FABActionItem(
                        icon: "phone.fill",
                        label: "Call",
                        color: .green
                    ) {
                        print("Call tapped")
                    },
                    FABActionItem(
                        icon: "video.fill",
                        label: "Video",
                        color: .purple
                    ) {
                        print("Video tapped")
                    }
                ],
                position: .bottomLeft,
                mainColor: .indigo
            )
        }
        .tabItem {
            Label("Left", systemImage: "arrow.left.circle.fill")
        }
        
        // Speed Dial FAB
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack {
                Text("Speed Dial FAB")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            
            SpeedDialFAB(
                actions: [
                    FABActionItem(
                        icon: "person.badge.plus",
                        label: "Add Contact",
                        color: .blue
                    ) {
                        print("Add contact tapped")
                    },
                    FABActionItem(
                        icon: "calendar.badge.plus",
                        label: "New Event",
                        color: .red
                    ) {
                        print("New event tapped")
                    },
                    FABActionItem(
                        icon: "note.text.badge.plus",
                        label: "Create Note",
                        color: .orange
                    ) {
                        print("Create note tapped")
                    },
                    FABActionItem(
                        icon: "folder.badge.plus",
                        label: "New Folder",
                        color: .purple
                    ) {
                        print("New folder tapped")
                    }
                ],
                mainColor: .teal
            )
        }
        .tabItem {
            Label("Speed Dial", systemImage: "dial.fill")
        }
    }
}

