export interface Snippet {
  id: string
  title: string
  author: string
  githubUsername: string
  tags: string[]
  description: string
  screenshot: string
  code: string
}

export const snippets: Snippet[] = [
  {
    id: "minimal-login.luizmellodev",
    title: "Minimal Login",
    author: "Luiz Mello",
    githubUsername: "luizmellodev",
    tags: ["login", "button", "ui"],
    description: "A minimal login screen with a beautiful gradient background and a beautiful button",
    screenshot: "/snippets/minimal-login.luizmellodev/screenshot.png",
    code: `import SwiftUI

struct MinimalLoginView: View, ViewTemplate {
    let id = "minimal_login"
    let name = "Minimal Login"
    
    var view: AnyView {
        AnyView(self)
    }
    
  @State private var email: String = ""
  @State private var password: String = ""
  
  var body: some View {
      VStack(spacing: 32) {
          // Logo and header
          VStack(spacing: 8) {
              Circle()
                  .fill(Color.blue.opacity(0.1))
                  .frame(width: 80, height: 80)
                  .overlay(
                      Circle()
                          .fill(Color.blue)
                          .frame(width: 40, height: 40)
                  )
              
              Text("Sign In")
                  .font(.title2)
                  .fontWeight(.bold)
              
              Text("Access your account")
                  .font(.caption)
                  .foregroundColor(.secondary)
          }
          
          // Form fields
          VStack(spacing: 24) {
              VStack(alignment: .leading, spacing: 8) {
                  TextField("Email", text: \$email)
                      .autocapitalization(.none)
                      .keyboardType(.emailAddress)
                      .padding(.vertical, 8)
                  
                  Divider()
              }
              
              VStack(alignment: .leading, spacing: 8) {
                  SecureField("Password", text: \$password)
                      .padding(.vertical, 8)
                  
                  Divider()
              }
              
              HStack {
                  Spacer()
                  Button(action: {
                      // Handle forgot password
                  }) {
                      Text("Forgot Password?")
                          .font(.caption)
                          .fontWeight(.medium)
                          .foregroundColor(.blue)
                  }
              }
          }
          
          // Sign in button
          Button(action: {
              // Handle sign in
          }) {
              Text("Sign In")
                  .fontWeight(.semibold)
                  .foregroundColor(.white)
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(Color.blue)
                  .cornerRadius(16)
          }
          .padding(.top, 16)
          
          // Create account prompt
          HStack(spacing: 4) {
              Text("New user?")
                  .font(.caption)
              
              Button(action: {
                  // Handle create account navigation
              }) {
                  Text("Create Account")
                      .font(.caption)
                      .fontWeight(.medium)
                      .foregroundColor(.blue)
              }
          }
          .padding(.top, 8)
      }
      .padding(.horizontal, 24)
  }
}`,
  },
  {
    id: "settings-screen.luizmellodev",
    title: "Settings Screen",
    author: "Luiz Mello",
    githubUsername: "luizmellodev",
    tags: ["settings", "navigation", "ui"],
    description: "A settings screen, simple as that.",
    screenshot: "/snippets/settings-screen.luizmellodev/screenshot.png",
    code: `import SwiftUI

struct ModernSettingsView: View, ViewTemplate {
    let id = "modernsettings"
    let name = "Modern Settings"
    
    var view: AnyView {
        AnyView(self)
    }
    
  var body: some View {
      NavigationView {
          ScrollView {
              VStack(spacing: 24) {
                  // Profile section
                  HStack(spacing: 16) {
                      Circle()
                          .fill(Color.blue.opacity(0.1))
                          .frame(width: 64, height: 64)
                          .overlay(
                              Circle()
                                  .fill(Color.blue)
                                  .frame(width: 32, height: 32)
                          )
                      
                      VStack(alignment: .leading, spacing: 4) {
                          Text("Alex Johnson")
                              .fontWeight(.bold)
                          
                          Text("alex@example.com")
                              .font(.caption)
                              .foregroundColor(.secondary)
                          
                          Button(action: {
                              // Edit profile action
                          }) {
                              Text("Edit Profile")
                                  .font(.caption)
                                  .fontWeight(.medium)
                                  .foregroundColor(.blue)
                          }
                      }
                      
                      Spacer()
                  }
                  .padding(.horizontal)
                  
                  // Account section
                  VStack(alignment: .leading, spacing: 8) {
                      Text("ACCOUNT")
                          .font(.caption)
                          .fontWeight(.medium)
                          .foregroundColor(.secondary)
                          .padding(.horizontal)
                      
                      VStack(spacing: 0) {
                          SettingsRow(title: "Personal Information")
                          SettingsRow(title: "Password")
                          SettingsRow(title: "Notifications")
                          SettingsRow(title: "Privacy", isLast: true)
                      }
                      .background(Color(.systemBackground))
                      .cornerRadius(16)
                      .padding(.horizontal)
                  }
                  
                  // Preferences section
                  VStack(alignment: .leading, spacing: 8) {
                      Text("PREFERENCES")
                          .font(.caption)
                          .fontWeight(.medium)
                          .foregroundColor(.secondary)
                          .padding(.horizontal)
                      
                      VStack(spacing: 0) {
                          SettingsRow(title: "Appearance")
                          SettingsRow(title: "Language")
                          SettingsRow(title: "Accessibility", isLast: true)
                      }
                      .background(Color(.systemBackground))
                      .cornerRadius(16)
                      .padding(.horizontal)
                  }
                  
                  // About section
                  VStack(alignment: .leading, spacing: 8) {
                      Text("ABOUT")
                          .font(.caption)
                          .fontWeight(.medium)
                          .foregroundColor(.secondary)
                          .padding(.horizontal)
                      
                      VStack(spacing: 0) {
                          SettingsRow(title: "Help Center")
                          SettingsRow(title: "Terms of Service")
                          SettingsRow(title: "Privacy Policy")
                          SettingsRow(title: "App Version", isLast: true) {
                              Text("1.0.0")
                                  .font(.caption)
                                  .foregroundColor(.secondary)
                          }
                      }
                      .background(Color(.systemBackground))
                      .cornerRadius(16)
                      .padding(.horizontal)
                  }
                  
                  // Sign out button
                  Button(action: {
                      // Sign out action
                  }) {
                      Text("Sign Out")
                          .fontWeight(.medium)
                          .foregroundColor(.red)
                          .frame(maxWidth: .infinity)
                          .padding()
                          .background(Color(.systemBackground))
                          .cornerRadius(16)
                  }
                  .padding(.horizontal)
                  .padding(.top, 8)
              }
              .padding(.vertical)
          }
          .background(Color(.systemGroupedBackground))
          .navigationTitle("Settings")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
              ToolbarItem(placement: .navigationBarTrailing) {
                  Button(action: {
                      // Close action
                  }) {
                      Image(systemName: "xmark")
                          .padding(8)
                          .background(Color(.systemGray5))
                          .clipShape(Circle())
                  }
              }
          }
      }
  }
}

struct SettingsRow<Trailing: View>: View {
  var title: String
  var isLast: Bool = false
  var trailing: Trailing
  
  init(title: String, isLast: Bool = false, @ViewBuilder trailing: @escaping () -> Trailing = { Image(systemName: "chevron.right").foregroundColor(.secondary) }) {
      self.title = title
      self.isLast = isLast
      self.trailing = trailing()
  }
  
  var body: some View {
      HStack {
          Text(title)
              .font(.subheadline)
          
          Spacer()
          
          trailing
      }
      .padding()
      .background(Color(.systemBackground))
      .overlay(
          !isLast ?
              Divider()
                  .padding(.leading)
                  .opacity(0.5)
              : nil,
          alignment: .bottom
      )
  }
}`,
  },
  {
    id: "snackbar-view.luizmellodev",
    title: "Snackbar Component",
    author: "Luiz Mello",
    githubUsername: "unknown",
    tags: ["notifications", "toast", "snackbar"],
    description: "A fully-featured snackbar/toast notification component with multiple types (success, error, warning, info), customizable positions (top/bottom), actions, and animations. Includes a global SnackbarManager for app-wide notifications.",
    screenshot: "/snippets/snackbar-view.luizmellodev/screenshot.png",
    code: `//
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
            isPresented: \$showSuccess,
            configuration: SnackbarConfiguration(
                message: "Success! Your changes have been saved.",
                type: .success,
                duration: 3.0
            )
        )
        .snackbar(
            isPresented: \$showError,
            configuration: SnackbarConfiguration(
                message: "Error! Something went wrong.",
                type: .error,
                duration: 3.0
            )
        )
        .snackbar(
            isPresented: \$showWarning,
            configuration: SnackbarConfiguration(
                message: "Warning! Please check your input.",
                type: .warning,
                duration: 3.0
            )
        )
        .snackbar(
            isPresented: \$showInfo,
            configuration: SnackbarConfiguration(
                message: "Info: New features available!",
                type: .info,
                duration: 3.0
            )
        )
        .snackbar(
            isPresented: \$showWithAction,
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
            isPresented: \$showTop,
            configuration: SnackbarConfiguration(
                message: "This appears at the top!",
                type: .info,
                position: .top,
                duration: 3.0
            )
        )
        .snackbar(
            isPresented: \$showCustom,
            configuration: SnackbarConfiguration(
                message: "Custom colored snackbar",
                type: .custom(backgroundColor: .pink, iconColor: .white),
                duration: 3.0
            )
        )
        .snackbar(
            isPresented: \$showLongMessage,
            configuration: SnackbarConfiguration(
                message: "This is a longer message to demonstrate how the snackbar handles multiple lines of text gracefully.",
                type: .info,
                duration: 4.0
            )
        )
    }
}

`,
  },
  {
    id: "verification-code.luizmellodev",
    title: "Verification Code View",
    author: "Luiz Mello",
    githubUsername: "luizmellodev",
    tags: ["input", "gradient", "ui"],
    description: "A simple but beautiful verification code view",
    screenshot: "/snippets/verification-code.luizmellodev/screenshot.png",
    code: `import SwiftUI
import Combine

struct OTPVerificationView: View, ViewTemplate {
    let id = "otpverification"
    let name = "OTP Verification"
    
    var view: AnyView {
        AnyView(self)
    }
    
  @State private var otpCode: [String] = Array(repeating: "", count: 4)
  @State private var currentField: Int = 0
  @FocusState private var fieldFocus: Int?
  
  var body: some View {
      VStack(spacing: 32) {
          // Icon
          ZStack {
              Circle()
                  .fill(Color.blue.opacity(0.1))
                  .frame(width: 80, height: 80)
              
              Image(systemName: "iphone")
                  .font(.system(size: 32))
                  .foregroundColor(.blue)
          }
          
          // Header
          VStack(spacing: 8) {
              Text("Verification Code")
                  .font(.title2)
                  .fontWeight(.bold)
              
              Text("We've sent a code to +1 (555) 123-4567")
                  .font(.caption)
                  .foregroundColor(.secondary)
                  .multilineTextAlignment(.center)
                  .padding(.horizontal)
          }
          
          // OTP Fields
          HStack(spacing: 12) {
              ForEach(0..<4, id: \\.self) { index in
                  OTPTextField(text: \$otpCode[index], isFocused: fieldFocus == index)
                      .focused(\$fieldFocus, equals: index)
                      .onChange(of: otpCode[index]) { newValue in
                          if newValue.count > 0 && index < 3 {
                              fieldFocus = index + 1
                          }
                      }
              }
          }
          .onAppear {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                  self.fieldFocus = 0
              }
          }
          
          // Resend code
          Button(action: {
              // Handle resend code
          }) {
              HStack(spacing: 4) {
                  Text("Didn't receive code?")
                      .font(.footnote)
                  
                  Text("Resend")
                      .font(.footnote)
                      .fontWeight(.medium)
                      .foregroundColor(.blue)
              }
          }
          
          // Verify button
          Button(action: {
              // Handle verification
          }) {
              Text("Verify")
                  .fontWeight(.semibold)
                  .foregroundColor(.white)
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(Color.blue)
                  .cornerRadius(16)
          }
          .padding(.top, 16)
      }
      .padding(.horizontal, 24)
  }
}

struct OTPTextField: View {
  @Binding var text: String
  var isFocused: Bool
  
  var body: some View {
      ZStack {
          RoundedRectangle(cornerRadius: 12)
              .stroke(isFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
              .frame(width: 50, height: 60)
          
          TextField("", text: \$text)
              .keyboardType(.numberPad)
              .multilineTextAlignment(.center)
              .font(.title2.bold())
              .foregroundColor(.primary)
              .frame(width: 50, height: 60)
              .onReceive(Just(text)) { _ in
                  if text.count > 1 {
                      text = String(text.prefix(1))
                  }
              }
      }
  }
}
`,
  }
]
