//
//  SnackbarView.swift
//  swiftuiForge-Xcode
//

import SwiftUI

// MARK: - Snackbar Type
public enum SnackbarType {
    case success
    case error
    case warning
    case info
    case custom(backgroundColor: Color, iconColor: Color)
    
    var backgroundColor: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        case .custom(let backgroundColor, _): return backgroundColor
        }
    }
    
    var iconColor: Color {
        switch self {
        case .success, .error, .warning, .info: return .white
        case .custom(_, let iconColor): return iconColor
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        case .custom: return "bell.fill"
        }
    }
}

// MARK: - Snackbar Position
public enum SnackbarPosition {
    case top
    case bottom
    
    var alignment: Alignment {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        }
    }
    
    var edge: Edge {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        }
    }
}

// MARK: - Snackbar Configuration
public struct SnackbarConfiguration {
    let message: String
    let type: SnackbarType
    let position: SnackbarPosition
    let duration: TimeInterval
    let showIcon: Bool
    let showCloseButton: Bool
    let actionTitle: String?
    let action: (() -> Void)?
    let cornerRadius: CGFloat
    let horizontalPadding: CGFloat
    let accessibilityLabel: String?
    
    public init(
        message: String,
        type: SnackbarType = .info,
        position: SnackbarPosition = .bottom,
        duration: TimeInterval = 3.0,
        showIcon: Bool = true,
        showCloseButton: Bool = true,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        cornerRadius: CGFloat = 12,
        horizontalPadding: CGFloat = 16,
        accessibilityLabel: String? = nil
    ) {
        self.message = message
        self.type = type
        self.position = position
        self.duration = duration
        self.showIcon = showIcon
        self.showCloseButton = showCloseButton
        self.actionTitle = actionTitle
        self.action = action
        self.cornerRadius = cornerRadius
        self.horizontalPadding = horizontalPadding
        self.accessibilityLabel = accessibilityLabel
    }
}

// MARK: - Snackbar View
struct SnackbarView: View {
    let configuration: SnackbarConfiguration
    let onDismiss: () -> Void
    
    @State private var offset: CGFloat
    
    init(configuration: SnackbarConfiguration, onDismiss: @escaping () -> Void) {
        self.configuration = configuration
        self.onDismiss = onDismiss
        _offset = State(initialValue: configuration.position == .top ? -200 : 200)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if configuration.showIcon {
                Image(systemName: configuration.type.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(configuration.type.iconColor)
            }
            
            Text(configuration.message)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 8)
            
            if let actionTitle = configuration.actionTitle, let action = configuration.action {
                Button(action: {
                    action()
                    onDismiss()
                }) {
                    Text(actionTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if configuration.showCloseButton {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Dismiss")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(configuration.type.backgroundColor)
        .cornerRadius(configuration.cornerRadius)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(.horizontal, configuration.horizontalPadding)
        .offset(y: offset)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = 0
            }
            
            if configuration.duration > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + configuration.duration) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        offset = configuration.position == .top ? -200 : 200
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss()
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(configuration.accessibilityLabel ?? configuration.message)
    }
}

// MARK: - Snackbar Modifier
struct SnackbarModifier: ViewModifier {
    @Binding var isPresented: Bool
    let configuration: SnackbarConfiguration
    
    func body(content: Content) -> some View {
        ZStack(alignment: configuration.position.alignment) {
            content
            
            if isPresented {
                VStack {
                    if configuration.position == .top {
                        SnackbarView(configuration: configuration) {
                            isPresented = false
                        }
                        .padding(.top, 50)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        
                        Spacer()
                    } else {
                        Spacer()
                        
                        SnackbarView(configuration: configuration) {
                            isPresented = false
                        }
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .zIndex(999)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPresented)
    }
}

// MARK: - View Extension
extension View {
    func snackbar(isPresented: Binding<Bool>, configuration: SnackbarConfiguration) -> some View {
        modifier(SnackbarModifier(isPresented: isPresented, configuration: configuration))
    }
}

// MARK: - Snackbar Manager
@MainActor
class SnackbarManager: ObservableObject {
    @Published var isPresented = false
    @Published var configuration: SnackbarConfiguration?
    
    static let shared = SnackbarManager()
    
    private init() {}
    
    func show(_ configuration: SnackbarConfiguration) {
        self.configuration = configuration
        self.isPresented = true
    }
    
    func dismiss() {
        self.isPresented = false
    }
}

// MARK: - Preview
#Preview("Snackbar") {
    SnackbarPreviewContainer()
}

private struct SnackbarPreviewContainer: View {
    @State private var showSuccess = false
    @State private var showError = false
    @State private var showWarning = false
    @State private var showInfo = false
    @State private var showWithAction = false
    @State private var showTop = false
    @State private var showCustom = false
    @State private var showLongMessage = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Snackbar Examples")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Tap buttons to show snackbars")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 15) {
                    Button("Show Success Snackbar") {
                        showSuccess = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    
                    Button("Show Error Snackbar") {
                        showError = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    
                    Button("Show Warning Snackbar") {
                        showWarning = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    
                    Button("Show Info Snackbar") {
                        showInfo = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    
                    Button("Show With Action") {
                        showWithAction = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    
                    Button("Show at Top") {
                        showTop = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.teal)
                    
                    Button("Show Custom Style") {
                        showCustom = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.pink)
                    
                    Button("Show Long Message") {
                        showLongMessage = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                }
                .padding()
                
                Spacer()
            }
        }
        .snackbar(
            isPresented: $showSuccess,
            configuration: SnackbarConfiguration(
                message: "Success! Your changes have been saved.",
                type: .success,
                duration: 3.0
            )
        )
        .snackbar(
            isPresented: $showError,
            configuration: SnackbarConfiguration(
                message: "Error! Something went wrong.",
                type: .error,
                duration: 3.0
            )
        )
        .snackbar(
            isPresented: $showWarning,
            configuration: SnackbarConfiguration(
                message: "Warning! Please check your input.",
                type: .warning,
                duration: 3.0
            )
        )
        .snackbar(
            isPresented: $showInfo,
            configuration: SnackbarConfiguration(
                message: "Info: New features available!",
                type: .info,
                duration: 3.0
            )
        )
        .snackbar(
            isPresented: $showWithAction,
            configuration: SnackbarConfiguration(
                message: "Message sent successfully",
                type: .success,
                duration: 5.0,
                actionTitle: "Undo",
                action: {
                    print("Undo action triggered")
                }
            )
        )
        .snackbar(
            isPresented: $showTop,
            configuration: SnackbarConfiguration(
                message: "This appears at the top!",
                type: .info,
                position: .top,
                duration: 3.0
            )
        )
        .snackbar(
            isPresented: $showCustom,
            configuration: SnackbarConfiguration(
                message: "Custom colored snackbar",
                type: .custom(backgroundColor: .pink, iconColor: .white),
                duration: 3.0
            )
        )
        .snackbar(
            isPresented: $showLongMessage,
            configuration: SnackbarConfiguration(
                message: "This is a longer message to demonstrate how the snackbar handles multiple lines of text gracefully.",
                type: .info,
                duration: 4.0
            )
        )
    }
}

