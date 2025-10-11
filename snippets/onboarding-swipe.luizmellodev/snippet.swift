import SwiftUI

struct OnboardingSwipeView: View {
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    
    let pages = [
        OnboardingPage(
            icon: "star.fill",
            title: "Welcome to SwiftShelf",
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
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
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
                        ForEach(0..<pages.count, id: \.self) { index in
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
