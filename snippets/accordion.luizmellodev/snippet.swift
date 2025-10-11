import SwiftUI

// MARK: - Accordion Item
public struct AccordionItem: Identifiable {
    public let id = UUID()
    let title: String
    let content: String
    let icon: String?
    let accessibilityLabel: String?
    
    public init(
        title: String,
        content: String,
        icon: String? = nil,
        accessibilityLabel: String? = nil
    ) {
        self.title = title
        self.content = content
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
    }
}

// MARK: - Accordion Style
public struct AccordionStyle {
    let backgroundColor: Color
    let headerBackgroundColor: Color
    let titleColor: Color
    let contentColor: Color
    let borderColor: Color
    let cornerRadius: CGFloat
    let showBorder: Bool
    let showDividers: Bool
    
    public init(
        backgroundColor: Color = Color(.systemBackground),
        headerBackgroundColor: Color = Color(.secondarySystemBackground),
        titleColor: Color = .primary,
        contentColor: Color = .secondary,
        borderColor: Color = Color(.separator),
        cornerRadius: CGFloat = 12,
        showBorder: Bool = true,
        showDividers: Bool = true
    ) {
        self.backgroundColor = backgroundColor
        self.headerBackgroundColor = headerBackgroundColor
        self.titleColor = titleColor
        self.contentColor = contentColor
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
        self.showBorder = showBorder
        self.showDividers = showDividers
    }
    
    static let `default` = AccordionStyle()
}

// MARK: - Single Accordion View
struct AccordionItemView: View {
    let item: AccordionItem
    let style: AccordionStyle
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    if let icon = item.icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(style.titleColor)
                            .frame(width: 24)
                    }
                    
                    Text(item.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(style.titleColor)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(style.titleColor.opacity(0.6))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)
                }
                .padding()
                .background(style.headerBackgroundColor)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel(item.accessibilityLabel ?? item.title)
            .accessibilityHint(isExpanded ? "Tap to collapse" : "Tap to expand")
            .accessibilityAddTraits(.isButton)
            
            // Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    if style.showDividers {
                        Divider()
                            .background(style.borderColor)
                    }
                    
                    Text(item.content)
                        .font(.system(size: 15))
                        .foregroundStyle(style.contentColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(style.backgroundColor)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(style.backgroundColor)
        .cornerRadius(style.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .stroke(style.borderColor, lineWidth: style.showBorder ? 1 : 0)
        )
    }
}

// MARK: - Accordion Group
struct AccordionGroup: View {
    let items: [AccordionItem]
    let style: AccordionStyle
    let allowMultipleExpanded: Bool
    @State private var expandedItems: Set<UUID>
    
    init(
        items: [AccordionItem],
        style: AccordionStyle = .default,
        allowMultipleExpanded: Bool = false,
        initiallyExpanded: Set<UUID> = []
    ) {
        self.items = items
        self.style = style
        self.allowMultipleExpanded = allowMultipleExpanded
        self._expandedItems = State(initialValue: initiallyExpanded)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(items) { item in
                AccordionItemView(
                    item: item,
                    style: style,
                    isExpanded: Binding(
                        get: { expandedItems.contains(item.id) },
                        set: { isExpanded in
                            if isExpanded {
                                if allowMultipleExpanded {
                                    expandedItems.insert(item.id)
                                } else {
                                    expandedItems = [item.id]
                                }
                            } else {
                                expandedItems.remove(item.id)
                            }
                        }
                    )
                )
            }
        }
    }
}

// MARK: - Preview
#Preview("Accordion") {
    ScrollView {
        VStack(spacing: 30) {
            // Single Accordion
            VStack(alignment: .leading, spacing: 10) {
                Text("Single Accordion")
                    .font(.headline)
                    .padding(.horizontal)
                
                SingleAccordionPreview()
                    .padding(.horizontal)
            }
            
            Divider()
            
            // Multiple Accordions (single expand)
            VStack(alignment: .leading, spacing: 10) {
                Text("Multiple Accordions (Single Expand)")
                    .font(.headline)
                    .padding(.horizontal)
                
                AccordionGroup(
                    items: [
                        AccordionItem(
                            title: "What is SwiftUI?",
                            content: "SwiftUI is Apple's modern framework for building user interfaces across all Apple platforms with the power of Swift. It uses a declarative syntax that's easy to read and natural to write.",
                            icon: "swift"
                        ),
                        AccordionItem(
                            title: "Why use SwiftUI?",
                            content: "SwiftUI offers a declarative approach, automatic state management, cross-platform support, and live previews that make development faster and more intuitive.",
                            icon: "questionmark.circle"
                        ),
                        AccordionItem(
                            title: "Is SwiftUI production-ready?",
                            content: "Yes! SwiftUI is mature and widely used in production apps. With each iOS release, Apple continues to improve its capabilities and performance.",
                            icon: "checkmark.seal"
                        )
                    ],
                    allowMultipleExpanded: false
                )
                .padding(.horizontal)
            }
            
            Divider()
            
            // Multiple Accordions (multiple expand)
            VStack(alignment: .leading, spacing: 10) {
                Text("Multiple Accordions (Multiple Expand)")
                    .font(.headline)
                    .padding(.horizontal)
                
                AccordionGroup(
                    items: [
                        AccordionItem(
                            title: "Getting Started",
                            content: "Start by creating a new SwiftUI project in Xcode. Choose the SwiftUI interface when creating your project.",
                            icon: "play.circle"
                        ),
                        AccordionItem(
                            title: "Basic Concepts",
                            content: "Learn about Views, State management, Modifiers, and the view hierarchy in SwiftUI.",
                            icon: "book"
                        ),
                        AccordionItem(
                            title: "Advanced Topics",
                            content: "Explore animations, custom layouts, combine integration, and advanced state management patterns.",
                            icon: "graduationcap"
                        )
                    ],
                    allowMultipleExpanded: true
                )
                .padding(.horizontal)
            }
            
            Divider()
            
            // Custom Style
            VStack(alignment: .leading, spacing: 10) {
                Text("Custom Style")
                    .font(.headline)
                    .padding(.horizontal)
                
                AccordionGroup(
                    items: [
                        AccordionItem(
                            title: "Privacy Policy",
                            content: "We take your privacy seriously. This policy explains how we collect, use, and protect your personal information.",
                            icon: "lock.shield"
                        ),
                        AccordionItem(
                            title: "Terms of Service",
                            content: "By using our service, you agree to these terms and conditions. Please read them carefully.",
                            icon: "doc.text"
                        )
                    ],
                    style: AccordionStyle(
                        backgroundColor: .blue.opacity(0.05),
                        headerBackgroundColor: .blue.opacity(0.1),
                        titleColor: .blue,
                        contentColor: .primary,
                        borderColor: .blue.opacity(0.3),
                        cornerRadius: 16,
                        showBorder: true,
                        showDividers: false
                    ),
                    allowMultipleExpanded: true
                )
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    .background(Color(.systemGroupedBackground))
}

// MARK: - Preview Helper
private struct SingleAccordionPreview: View {
    @State private var isExpanded = false
    
    var body: some View {
        AccordionItemView(
            item: AccordionItem(
                title: "Single Item Example",
                content: "This is a single accordion item that can be expanded and collapsed. It's perfect for FAQ sections, settings panels, or any content that needs to be hidden by default.",
                icon: "info.circle"
            ),
            style: .default,
            isExpanded: $isExpanded
        )
    }
}

