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
    id: "animated-button",
    title: "Animated Button",
    author: "John Doe",
    githubUsername: "johndoe",
    tags: ["animation", "button", "ui"],
    description: "A beautiful animated button with spring animation and haptic feedback",
    screenshot: "/ios-app-with-animated-blue-button.jpg",
    code: `import SwiftUI

struct AnimatedButton: View {
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed.toggle()
            }
        }) {
            Text("Tap Me")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .scaleEffect(isPressed ? 1.2 : 1.0)
        }
    }
}`,
  },
  {
    id: "gradient-card",
    title: "Gradient Card",
    author: "Jane Smith",
    githubUsername: "janesmith",
    tags: ["card", "gradient", "ui"],
    description: "A modern card component with gradient background and glassmorphism effect",
    screenshot: "/ios-app-with-gradient-card-component-purple-and-pi.jpg",
    code: `import SwiftUI

struct GradientCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text("Gradient Card")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Beautiful gradient background with glassmorphism")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [.purple, .pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}`,
  },
  {
    id: "loading-spinner",
    title: "Loading Spinner",
    author: "Mike Johnson",
    githubUsername: "mikejohnson",
    tags: ["animation", "loading", "spinner"],
    description: "Smooth rotating loading spinner with customizable colors",
    screenshot: "/ios-app-with-circular-loading-spinner-animation.jpg",
    code: `import SwiftUI

struct LoadingSpinner: View {
    @State private var isRotating = false
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color.blue, lineWidth: 4)
            .frame(width: 50, height: 50)
            .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
            .animation(
                Animation.linear(duration: 1)
                    .repeatForever(autoreverses: false),
                value: isRotating
            )
            .onAppear {
                isRotating = true
            }
    }
}`,
  },
  {
    id: "profile-header",
    title: "Profile Header",
    author: "Sarah Williams",
    githubUsername: "sarahwilliams",
    tags: ["profile", "header", "ui"],
    description: "Clean profile header with avatar, name, and stats",
    screenshot: "/ios-app-profile-header-with-avatar-and-user-stats.jpg",
    code: `import SwiftUI

struct ProfileHeader: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Sarah Williams")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("iOS Developer")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 40) {
                VStack {
                    Text("128")
                        .font(.headline)
                    Text("Posts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("1.2K")
                        .font(.headline)
                    Text("Followers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("342")
                        .font(.headline)
                    Text("Following")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}`,
  },
  {
    id: "search-bar",
    title: "Search Bar",
    author: "Alex Chen",
    githubUsername: "alexchen",
    tags: ["search", "input", "ui"],
    description: "Modern search bar with icon and clear button",
    screenshot: "/ios-app-with-search-bar-input-field.jpg",
    code: `import SwiftUI

struct SearchBar: View {
    @State private var searchText = ""
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}`,
  },
  {
    id: "toggle-switch",
    title: "Custom Toggle",
    author: "Emma Davis",
    githubUsername: "emmadavis",
    tags: ["toggle", "switch", "ui"],
    description: "Animated custom toggle switch with smooth transitions",
    screenshot: "/ios-app-with-custom-toggle-switch-green.jpg",
    code: `import SwiftUI

struct CustomToggle: View {
    @State private var isOn = false
    
    var body: some View {
        HStack {
            Text("Dark Mode")
                .font(.headline)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .green))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}`,
  },
  {
    id: "calendar-picker",
    title: "Calendar Date Picker",
    author: "David Park",
    githubUsername: "davidpark",
    tags: ["calendar", "picker", "ui"],
    description: "Beautiful calendar date picker with month navigation",
    screenshot: "/ios-app-with-calendar-date-picker-showing-month-vi.jpg",
    code: `import SwiftUI

struct CalendarPicker: View {
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Date")
                .font(.title2)
                .fontWeight(.bold)
            
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            
            Text("Selected: \\(selectedDate.formatted(date: .long, time: .omitted))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}`,
  },
  {
    id: "pill-button",
    title: "Pill Button",
    author: "Lisa Anderson",
    githubUsername: "lisaanderson",
    tags: ["button", "ui", "modern"],
    description: "Rounded pill-shaped button with icon support",
    screenshot: "/ios-app-with-rounded-pill-button-blue.jpg",
    code: `import SwiftUI

struct PillButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
    }
}

PillButton(title: "Continue", icon: "arrow.right") {
    print("Button tapped")
}`,
  },
  {
    id: "floating-action-button",
    title: "Floating Action Button",
    author: "Tom Wilson",
    githubUsername: "tomwilson",
    tags: ["button", "ui", "animation"],
    description: "Material Design inspired floating action button with shadow",
    screenshot: "/ios-app-with-floating-action-button-bottom-right-c.jpg",
    code: `import SwiftUI

struct FloatingActionButton: View {
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            Color.clear
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()) {
                            isPressed.toggle()
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            .rotationEffect(.degrees(isPressed ? 45 : 0))
                    }
                    .padding()
                }
            }
        }
    }
}`,
  },
  {
    id: "slide-animation",
    title: "Slide In Animation",
    author: "Rachel Kim",
    githubUsername: "rachelkim",
    tags: ["animation", "transition", "motion"],
    description: "Smooth slide-in animation for views and cards",
    screenshot: "/ios-app-with-card-sliding-in-from-bottom-animation.jpg",
    code: `import SwiftUI

struct SlideInView: View {
    @State private var isShowing = false
    
    var body: some View {
        VStack {
            Button("Show Card") {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isShowing.toggle()
                }
            }
            
            Spacer()
            
            if isShowing {
                VStack(spacing: 16) {
                    Text("Welcome!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("This card slides in smoothly")
                        .foregroundColor(.secondary)
                }
                .padding(32)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding()
    }
}`,
  },
  {
    id: "bounce-animation",
    title: "Bounce Animation",
    author: "Chris Martinez",
    githubUsername: "chrismartinez",
    tags: ["animation", "motion", "interaction"],
    description: "Playful bounce animation with spring physics",
    screenshot: "/ios-app-with-bouncing-icon-animation.jpg",
    code: `import SwiftUI

struct BounceAnimation: View {
    @State private var isBouncing = false
    
    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .scaleEffect(isBouncing ? 1.3 : 1.0)
                .animation(
                    Animation.spring(response: 0.3, dampingFraction: 0.3)
                        .repeatForever(autoreverses: true),
                    value: isBouncing
                )
            
            Button("Start Bounce") {
                isBouncing.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}`,
  },
  {
    id: "login-screen",
    title: "Login Screen",
    author: "Jennifer Lee",
    githubUsername: "jenniferlee",
    tags: ["ui", "screen", "auth"],
    description: "Complete login screen with email and password fields",
    screenshot: "/ios-login-screen-with-email-password-fields-and-bl.jpg",
    code: `import SwiftUI

struct LoginScreen: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Sign in to continue")
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.top, 32)
            
            Button(action: {}) {
                Text("Sign In")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
            
            Button("Forgot Password?") {}
                .font(.subheadline)
                .foregroundColor(.blue)
            
            Spacer()
            
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.secondary)
                Button("Sign Up") {}
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
        }
        .padding(32)
    }
}`,
  },
  {
    id: "settings-screen",
    title: "Settings Screen",
    author: "Michael Brown",
    githubUsername: "michaelbrown",
    tags: ["ui", "screen", "settings"],
    description: "Modern settings screen with grouped sections",
    screenshot: "/ios-settings-screen-with-sections-and-toggle-switc.jpg",
    code: `import SwiftUI

struct SettingsScreen: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Preferences") {
                    Toggle("Notifications", isOn: $notificationsEnabled)
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section("Account") {
                    NavigationLink("Profile") {
                        Text("Profile View")
                    }
                    NavigationLink("Privacy") {
                        Text("Privacy View")
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    Button("Terms of Service") {}
                    Button("Privacy Policy") {}
                }
                
                Section {
                    Button("Sign Out") {}
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}`,
  },
  {
    id: "chat-interface",
    title: "Chat Interface",
    author: "Amanda White",
    githubUsername: "amandawhite",
    tags: ["ui", "screen", "component"],
    description: "Clean chat interface with message bubbles",
    screenshot: "/ios-chat-interface-with-message-bubbles-blue-and-g.jpg",
    code: `import SwiftUI

struct ChatInterface: View {
    @State private var messageText = ""
    @State private var messages = [
        Message(text: "Hey! How are you?", isFromUser: false),
        Message(text: "I'm good! How about you?", isFromUser: true),
        Message(text: "Doing great, thanks!", isFromUser: false)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(messages) { message in
                        HStack {
                            if message.isFromUser { Spacer() }
                            
                            Text(message.text)
                                .padding(12)
                                .background(message.isFromUser ? Color.blue : Color(.systemGray5))
                                .foregroundColor(message.isFromUser ? .white : .primary)
                                .cornerRadius(16)
                            
                            if !message.isFromUser { Spacer() }
                        }
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Message", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        messages.append(Message(text: messageText, isFromUser: true))
        messageText = ""
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
}`,
  },
  {
    id: "onboarding-screen",
    title: "Onboarding Screen",
    author: "Kevin Zhang",
    githubUsername: "kevinzhang",
    tags: ["ui", "screen", "navigation"],
    description: "Swipeable onboarding screen with page indicators",
    screenshot: "/ios-onboarding-screen-with-illustration-and-page-d.jpg",
    code: `import SwiftUI

struct OnboardingScreen: View {
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(icon: "star.fill", title: "Welcome", description: "Get started with our amazing app"),
        OnboardingPage(icon: "heart.fill", title: "Features", description: "Discover powerful features"),
        OnboardingPage(icon: "checkmark.circle.fill", title: "Ready", description: "You're all set to begin")
    ]
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \\.self) { index in
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: pages[index].icon)
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text(pages[index].title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(pages[index].description)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
            Button(action: {}) {
                Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}`,
  },
  {
    id: "icon-button",
    title: "Icon Button",
    author: "Sophia Garcia",
    githubUsername: "sophiagarcia",
    tags: ["button", "icon", "ui"],
    description: "Circular icon button with multiple style variants",
    screenshot: "/ios-app-with-circular-icon-buttons-different-color.jpg",
    code: `import SwiftUI

struct IconButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(Circle())
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

struct IconButtonExamples: View {
    var body: some View {
        HStack(spacing: 20) {
            IconButton(icon: "heart.fill", color: .red) {}
            IconButton(icon: "star.fill", color: .yellow) {}
            IconButton(icon: "bell.fill", color: .blue) {}
        }
    }
}`,
  },
  {
    id: "fade-animation",
    title: "Fade Animation",
    author: "Daniel Rodriguez",
    githubUsername: "danielrodriguez",
    tags: ["animation", "transition", "motion"],
    description: "Smooth fade in/out animation with opacity control",
    screenshot: "/ios-app-with-fading-text-animation.jpg",
    code: `import SwiftUI

struct FadeAnimation: View {
    @State private var isVisible = true
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Fade Animation")
                .font(.title)
                .fontWeight(.bold)
                .opacity(isVisible ? 1 : 0)
                .animation(.easeInOut(duration: 1), value: isVisible)
            
            Button(isVisible ? "Fade Out" : "Fade In") {
                isVisible.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}`,
  },
]
