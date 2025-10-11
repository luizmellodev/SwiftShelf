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
    id: "animated-button.example",
    title: "Animated Button",
    author: "John Doe",
    githubUsername: "example",
    tags: ["animation", "button", "ui"],
    description: "A beautiful animated button with spring animation and haptic feedback",
    screenshot: "/snippets/animated-button.example/screenshot.png",
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
}
`,
  },
  {
    id: "colorful-shadow-button.luizmellodev",
    title: "Colorful Shadow Button",
    author: "Luiz Mello",
    githubUsername: "luizmellodev",
    tags: ["animation", "button", "ui"],
    description: "An animated button with continuously changing colorful shadow effects using gradient animations",
    screenshot: "/snippets/colorful-shadow-button.luizmellodev/screenshot.png",
    code: `import SwiftUI

struct ColorfulShadowButton: View {
    @State private var animationOffset: CGFloat = 0
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Press animation
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }) {
            Text("Tap Me")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .shadow(
                    color: getAnimatedShadowColor(),
                    radius: 20,
                    x: 0,
                    y: 8
                )
                .shadow(
                    color: getAnimatedShadowColor().opacity(0.3),
                    radius: 40,
                    x: 0,
                    y: 16
                )
        }
        .onAppear {
            startColorAnimation()
        }
    }
    
    private func getAnimatedShadowColor() -> Color {
        let colors: [Color] = [
            .red, .orange, .yellow, .green, 
            .blue, .purple, .pink, .cyan
        ]
        
        let index = Int(animationOffset) % colors.count
        let nextIndex = (index + 1) % colors.count
        
        let progress = animationOffset - CGFloat(index)
        let currentColor = colors[index]
        let nextColor = colors[nextIndex]
        
        return Color(
            red: interpolate(from: currentColor.components.red, to: nextColor.components.red, progress: progress),
            green: interpolate(from: currentColor.components.green, to: nextColor.components.green, progress: progress),
            blue: interpolate(from: currentColor.components.blue, to: nextColor.components.blue, progress: progress)
        )
    }
    
    private func startColorAnimation() {
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            animationOffset = 8.0
        }
    }
    
    private func interpolate(from: Double, to: Double, progress: Double) -> Double {
        return from + (to - from) * progress
    }
}

// Extension to get color components
extension Color {
    var components: (red: Double, green: Double, blue: Double, alpha: Double) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b), Double(a))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ColorfulShadowButton()
    }
}
`,
  },
  {
    id: "gradient-card.example",
    title: "Gradient Card",
    author: "Jane Smith",
    githubUsername: "example",
    tags: ["card", "gradient", "ui"],
    description: "A modern card component with gradient background and glassmorphism effect",
    screenshot: "/snippets/gradient-card.example/screenshot.png",
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
}
`,
  },
  {
    id: "loading-spinner.example",
    title: "Loading Spinner",
    author: "Mike Johnson",
    githubUsername: "example",
    tags: ["animation", "loading", "spinner"],
    description: "Smooth rotating loading spinner with customizable colors",
    screenshot: "/snippets/loading-spinner.example/screenshot.png",
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
}
`,
  },
  {
    id: "onboarding-swipe.luizmellodev",
    title: "Onboarding Swipe View",
    author: "Luiz Mello",
    githubUsername: "luizmellodev",
    tags: ["navigation", "animation", "gesture"],
    description: "A beautiful swipeable onboarding screen with page indicators, smooth animations, and gradient backgrounds",
    screenshot: "/snippets/onboarding-swipe.luizmellodev/screenshot.png",
    code: `import SwiftUI

struct OnboardingSwipeView: View {
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0

    let pages = [
        OnboardingPage(
            icon: "star.fill",
            title: "Welcome to SwiftShelf!",
            description: "Discover amazing Swift UI components and code snippets to accelerate your iOS development.",
            color: .blue
        ),
        OnboardingPage(
            icon: "heart.fill",
            title: "Beautiful Components",
            description: "Browse through a curated collection of modern, reusable SwiftUI components with clean code.",
            color: .pink
        ),
        OnboardingPage(
            icon: "bolt.fill",
            title: "Copy & Paste Ready",
            description: "All components are production-ready with proper documentation and easy integration.",
            color: .orange
        ),
        OnboardingPage(
            icon: "checkmark.circle.fill",
            title: "Start Building",
            description: "You're all set! Start exploring components and building amazing iOS apps.",
            color: .green
        )
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [pages[currentPage].color.opacity(0.1), pages[currentPage].color.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Main content area
                    TabView(selection: \$currentPage) {
                        ForEach(0..<pages.count, id: \\.self) { index in
                            OnboardingPageView(
                                page: pages[index],
                                geometry: geometry
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.x
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                if value.translation.x > threshold && currentPage > 0 {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        currentPage -= 1
                                    }
                                } else if value.translation.x < -threshold && currentPage < pages.count - 1 {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        currentPage += 1
                                    }
                                }

                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    dragOffset = 0
                                }
                            }
                    )
                    .offset(x: dragOffset * 0.1)

                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \\.self) { index in
                            Circle()
                                .fill(index == currentPage ? pages[currentPage].color : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentPage)
                        }
                    }
                    .padding(.bottom, 20)

                    // Action button
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        } else {
                            // Complete onboarding
                            print("Onboarding completed!")
                        }
                    }) {
                        HStack {
                            Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                                .fontWeight(.semibold)

                            if currentPage < pages.count - 1 {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [pages[currentPage].color, pages[currentPage].color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: pages[currentPage].color.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
                    .scaleEffect(currentPage == pages.count - 1 ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentPage)
                }
            }
        }
    }

    struct OnboardingPageView: View {
        let page: OnboardingPage
        let geometry: GeometryProxy

        var body: some View {
            VStack(spacing: 32) {
                Spacer()

                // Icon with animation
                ZStack {
                    Circle()
                        .fill(page.color.opacity(0.1))
                        .frame(width: 120, height: 120)

                    Image(systemName: page.icon)
                        .font(.system(size: 50, weight: .medium))
                        .foregroundColor(page.color)
                }
                .scaleEffect(1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: page)

                // Content
                VStack(spacing: 16) {
                    Text(page.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)

                    Text(page.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(.horizontal, 24)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    struct OnboardingPage {
        let icon: String
        let title: String
        let description: String
        let color: Color
    }

    // Preview
    struct OnboardingSwipeView_Previews: PreviewProvider {
        static var previews: some View {
            OnboardingSwipeView()
        }
    }
}`,
  }
]
