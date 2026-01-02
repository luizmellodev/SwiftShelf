import SwiftUI

// MARK: - Card Data Protocol
public protocol SwipeableCard: Identifiable {
    var id: UUID { get }
}

// MARK: - Swipe Direction
public enum SwipeDirection {
    case left
    case right
    case up
    case none
}

// MARK: - Card Stack Configuration
public struct CardStackConfiguration {
    let maxVisibleCards: Int
    let cardOffset: CGFloat
    let cardScale: CGFloat
    let swipeThreshold: CGFloat
    let rotationAngle: Double
    
    public init(
        maxVisibleCards: Int = 3,
        cardOffset: CGFloat = 10,
        cardScale: CGFloat = 0.05,
        swipeThreshold: CGFloat = 100,
        rotationAngle: Double = 10
    ) {
        self.maxVisibleCards = maxVisibleCards
        self.cardOffset = cardOffset
        self.cardScale = cardScale
        self.swipeThreshold = swipeThreshold
        self.rotationAngle = rotationAngle
    }
    
    public static let `default` = CardStackConfiguration()
}

// MARK: - Animated Card Stack
public struct AnimatedCardStack<Card: SwipeableCard, CardContent: View>: View {
    let cards: [Card]
    let configuration: CardStackConfiguration
    let cardContent: (Card) -> CardContent
    let onSwipeLeft: ((Card) -> Void)?
    let onSwipeRight: ((Card) -> Void)?
    let onSwipeUp: ((Card) -> Void)?
    
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    
    public init(
        cards: [Card],
        configuration: CardStackConfiguration = .default,
        @ViewBuilder cardContent: @escaping (Card) -> CardContent,
        onSwipeLeft: ((Card) -> Void)? = nil,
        onSwipeRight: ((Card) -> Void)? = nil,
        onSwipeUp: ((Card) -> Void)? = nil
    ) {
        self.cards = cards
        self.configuration = configuration
        self.cardContent = cardContent
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
        self.onSwipeUp = onSwipeUp
    }
    
    public var body: some View {
        ZStack {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                if index >= currentIndex && index < currentIndex + configuration.maxVisibleCards {
                    cardView(for: card, at: index)
                }
            }
        }
    }
    
    private func cardView(for card: Card, at index: Int) -> some View {
        let relativeIndex = index - currentIndex
        let isTopCard = relativeIndex == 0
        
        return cardContent(card)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .offset(
                x: isTopCard ? offset.width : 0,
                y: isTopCard ? offset.height : CGFloat(relativeIndex) * configuration.cardOffset
            )
            .scaleEffect(
                isTopCard ? 1.0 : 1.0 - (CGFloat(relativeIndex) * configuration.cardScale)
            )
            .rotationEffect(.degrees(isTopCard ? rotation : 0))
            .opacity(relativeIndex < configuration.maxVisibleCards ? 1.0 : 0.0)
            .zIndex(Double(cards.count - index))
            .gesture(
                isTopCard ? DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                        rotation = Double(gesture.translation.width / 20)
                    }
                    .onEnded { gesture in
                        handleSwipe(for: card, with: gesture.translation)
                    } : nil
            )
            .overlay(
                isTopCard ? swipeIndicators : nil
            )
    }
    
    private var swipeIndicators: some View {
        ZStack {
            // Like indicator (right swipe)
            if offset.width > 50 {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.green, lineWidth: 4)
                    .overlay(
                        Text("LIKE")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(.green)
                    )
                    .padding(40)
                    .rotationEffect(.degrees(-20))
                    .opacity(Double(offset.width / 100))
            }
            
            // Nope indicator (left swipe)
            if offset.width < -50 {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.red, lineWidth: 4)
                    .overlay(
                        Text("NOPE")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(.red)
                    )
                    .padding(40)
                    .rotationEffect(.degrees(20))
                    .opacity(Double(-offset.width / 100))
            }
            
            // Super like indicator (up swipe)
            if offset.height < -50 {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 4)
                    .overlay(
                        Text("SUPER")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(.blue)
                    )
                    .padding(40)
                    .opacity(Double(-offset.height / 100))
            }
        }
    }
    
    private func handleSwipe(for card: Card, with translation: CGSize) {
        let horizontalSwipe = abs(translation.width) > abs(translation.height)
        
        if horizontalSwipe {
            if translation.width > configuration.swipeThreshold {
                // Swipe right
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    offset = CGSize(width: 500, height: translation.height)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSwipeRight?(card)
                    removeCard()
                }
            } else if translation.width < -configuration.swipeThreshold {
                // Swipe left
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    offset = CGSize(width: -500, height: translation.height)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSwipeLeft?(card)
                    removeCard()
                }
            } else {
                // Return to center
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    offset = .zero
                    rotation = 0
                }
            }
        } else {
            if translation.height < -configuration.swipeThreshold {
                // Swipe up
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    offset = CGSize(width: translation.width, height: -800)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSwipeUp?(card)
                    removeCard()
                }
            } else {
                // Return to center
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    offset = .zero
                    rotation = 0
                }
            }
        }
    }
    
    private func removeCard() {
        offset = .zero
        rotation = 0
        currentIndex += 1
    }
    
    // Public methods for programmatic swiping
    public func swipeLeft() {
        guard currentIndex < cards.count else { return }
        let card = cards[currentIndex]
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            offset = CGSize(width: -500, height: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSwipeLeft?(card)
            removeCard()
        }
    }
    
    public func swipeRight() {
        guard currentIndex < cards.count else { return }
        let card = cards[currentIndex]
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            offset = CGSize(width: 500, height: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSwipeRight?(card)
            removeCard()
        }
    }
}

// MARK: - Card Stack with Controls
public struct CardStackWithControls<Card: SwipeableCard, CardContent: View>: View {
    let cards: [Card]
    let configuration: CardStackConfiguration
    let cardContent: (Card) -> CardContent
    let onSwipeLeft: ((Card) -> Void)?
    let onSwipeRight: ((Card) -> Void)?
    let onSwipeUp: ((Card) -> Void)?
    
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    
    public init(
        cards: [Card],
        configuration: CardStackConfiguration = .default,
        @ViewBuilder cardContent: @escaping (Card) -> CardContent,
        onSwipeLeft: ((Card) -> Void)? = nil,
        onSwipeRight: ((Card) -> Void)? = nil,
        onSwipeUp: ((Card) -> Void)? = nil
    ) {
        self.cards = cards
        self.configuration = configuration
        self.cardContent = cardContent
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
        self.onSwipeUp = onSwipeUp
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Card Stack
            ZStack {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    if index >= currentIndex && index < currentIndex + configuration.maxVisibleCards {
                        cardView(for: card, at: index)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 500)
            
            // Control Buttons
            HStack(spacing: 30) {
                // Nope Button
                Button(action: {
                    handleButtonSwipe(direction: .left)
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.red)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(currentIndex >= cards.count)
                
                // Super Like Button
                Button(action: {
                    handleButtonSwipe(direction: .up)
                }) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.blue)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(currentIndex >= cards.count)
                
                // Like Button
                Button(action: {
                    handleButtonSwipe(direction: .right)
                }) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.green)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(currentIndex >= cards.count)
            }
            .padding(.bottom)
        }
    }
    
    private func cardView(for card: Card, at index: Int) -> some View {
        let relativeIndex = index - currentIndex
        let isTopCard = relativeIndex == 0
        
        return cardContent(card)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .offset(
                x: isTopCard ? offset.width : 0,
                y: isTopCard ? offset.height : CGFloat(relativeIndex) * configuration.cardOffset
            )
            .scaleEffect(
                isTopCard ? 1.0 : 1.0 - (CGFloat(relativeIndex) * configuration.cardScale)
            )
            .rotationEffect(.degrees(isTopCard ? rotation : 0))
            .opacity(relativeIndex < configuration.maxVisibleCards ? 1.0 : 0.0)
            .zIndex(Double(cards.count - index))
            .gesture(
                isTopCard ? DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                        rotation = Double(gesture.translation.width / 20)
                    }
                    .onEnded { gesture in
                        handleSwipe(for: card, with: gesture.translation)
                    } : nil
            )
    }
    
    private func handleSwipe(for card: Card, with translation: CGSize) {
        let horizontalSwipe = abs(translation.width) > abs(translation.height)
        
        if horizontalSwipe {
            if translation.width > configuration.swipeThreshold {
                animateSwipe(direction: .right, card: card)
            } else if translation.width < -configuration.swipeThreshold {
                animateSwipe(direction: .left, card: card)
            } else {
                resetCard()
            }
        } else {
            if translation.height < -configuration.swipeThreshold {
                animateSwipe(direction: .up, card: card)
            } else {
                resetCard()
            }
        }
    }
    
    private func handleButtonSwipe(direction: SwipeDirection) {
        guard currentIndex < cards.count else { return }
        let card = cards[currentIndex]
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        animateSwipe(direction: direction, card: card)
    }
    
    private func animateSwipe(direction: SwipeDirection, card: Card) {
        let targetOffset: CGSize
        
        switch direction {
        case .left:
            targetOffset = CGSize(width: -500, height: 0)
        case .right:
            targetOffset = CGSize(width: 500, height: 0)
        case .up:
            targetOffset = CGSize(width: 0, height: -800)
        case .none:
            targetOffset = .zero
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            offset = targetOffset
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            switch direction {
            case .left:
                onSwipeLeft?(card)
            case .right:
                onSwipeRight?(card)
            case .up:
                onSwipeUp?(card)
            case .none:
                break
            }
            removeCard()
        }
    }
    
    private func resetCard() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            offset = .zero
            rotation = 0
        }
    }
    
    private func removeCard() {
        offset = .zero
        rotation = 0
        currentIndex += 1
    }
}

// MARK: - Preview
#Preview("Animated Card Stack") {
    CardStackPreview()
}

// MARK: - Preview Card Model
private struct PreviewCard: SwipeableCard {
    let id = UUID()
    let title: String
    let subtitle: String
    let color: Color
    let icon: String
}

private struct CardStackPreview: View {
    let sampleCards = [
        PreviewCard(title: "SwiftUI", subtitle: "Modern UI Framework", color: .blue, icon: "swift"),
        PreviewCard(title: "Animations", subtitle: "Smooth & Beautiful", color: .purple, icon: "sparkles"),
        PreviewCard(title: "Gestures", subtitle: "Interactive Design", color: .green, icon: "hand.tap"),
        PreviewCard(title: "Components", subtitle: "Reusable Code", color: .orange, icon: "square.stack.3d.up"),
        PreviewCard(title: "Performance", subtitle: "Fast & Efficient", color: .red, icon: "bolt.fill"),
        PreviewCard(title: "Accessibility", subtitle: "For Everyone", color: .teal, icon: "accessibility")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Swipe Cards")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            CardStackWithControls(
                cards: sampleCards,
                cardContent: { card in
                    VStack(spacing: 20) {
                        Image(systemName: card.icon)
                            .font(.system(size: 80))
                            .foregroundStyle(card.color)
                        
                        Text(card.title)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Text(card.subtitle)
                            .font(.system(size: 18))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(card.color.opacity(0.1))
                },
                onSwipeLeft: { card in
                    print("Swiped left on: \(card.title)")
                },
                onSwipeRight: { card in
                    print("Swiped right on: \(card.title)")
                },
                onSwipeUp: { card in
                    print("Super liked: \(card.title)")
                }
            )
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

