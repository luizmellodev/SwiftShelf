import SwiftUI

// MARK: - Skeleton Style
public struct SkeletonStyle {
    let baseColor: Color
    let highlightColor: Color
    let cornerRadius: CGFloat
    let animationDuration: Double
    
    public init(
        baseColor: Color = Color(.systemGray5),
        highlightColor: Color = Color(.systemGray4),
        cornerRadius: CGFloat = 8,
        animationDuration: Double = 1.5
    ) {
        self.baseColor = baseColor
        self.highlightColor = highlightColor
        self.cornerRadius = cornerRadius
        self.animationDuration = animationDuration
    }
    
    public static let `default` = SkeletonStyle()
    public static let rounded = SkeletonStyle(cornerRadius: 12)
    public static let circular = SkeletonStyle(cornerRadius: 999)
}

// MARK: - Skeleton Shimmer Effect
struct SkeletonShimmer: ViewModifier {
    let style: SkeletonStyle
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: style.baseColor, location: 0),
                            .init(color: style.highlightColor, location: 0.5),
                            .init(color: style.baseColor, location: 1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
            .onAppear {
                withAnimation(
                    .linear(duration: style.animationDuration)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

extension View {
    public func skeleton(
        isLoading: Bool,
        style: SkeletonStyle = .default
    ) -> some View {
        Group {
            if isLoading {
                self
                    .hidden()
                    .overlay(
                        RoundedRectangle(cornerRadius: style.cornerRadius)
                            .fill(style.baseColor)
                            .modifier(SkeletonShimmer(style: style))
                    )
            } else {
                self
            }
        }
    }
}

// MARK: - Skeleton Views
public struct SkeletonText: View {
    let lines: Int
    let style: SkeletonStyle
    let lastLineWidth: CGFloat?
    
    public init(
        lines: Int = 1,
        style: SkeletonStyle = .default,
        lastLineWidth: CGFloat? = nil
    ) {
        self.lines = lines
        self.style = style
        self.lastLineWidth = lastLineWidth
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<lines, id: \.self) { index in
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(style.baseColor)
                    .frame(
                        height: 16,
                        alignment: .leading
                    )
                    .frame(
                        maxWidth: (index == lines - 1 && lastLineWidth != nil) ? lastLineWidth : .infinity,
                        alignment: .leading
                    )
                    .modifier(SkeletonShimmer(style: style))
            }
        }
    }
}

public struct SkeletonCircle: View {
    let size: CGFloat
    let style: SkeletonStyle
    
    public init(
        size: CGFloat = 60,
        style: SkeletonStyle = .circular
    ) {
        self.size = size
        self.style = style
    }
    
    public var body: some View {
        Circle()
            .fill(style.baseColor)
            .frame(width: size, height: size)
            .modifier(SkeletonShimmer(style: style))
    }
}

public struct SkeletonRectangle: View {
    let width: CGFloat?
    let height: CGFloat
    let style: SkeletonStyle
    
    public init(
        width: CGFloat? = nil,
        height: CGFloat = 200,
        style: SkeletonStyle = .default
    ) {
        self.width = width
        self.height = height
        self.style = style
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: style.cornerRadius)
            .fill(style.baseColor)
            .frame(width: width, height: height)
            .modifier(SkeletonShimmer(style: style))
    }
}

// MARK: - Skeleton Card
public struct SkeletonCard: View {
    let style: SkeletonStyle
    let showImage: Bool
    let imageHeight: CGFloat
    let titleLines: Int
    let subtitleLines: Int
    
    public init(
        style: SkeletonStyle = .default,
        showImage: Bool = true,
        imageHeight: CGFloat = 200,
        titleLines: Int = 1,
        subtitleLines: Int = 2
    ) {
        self.style = style
        self.showImage = showImage
        self.imageHeight = imageHeight
        self.titleLines = titleLines
        self.subtitleLines = subtitleLines
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showImage {
                SkeletonRectangle(height: imageHeight, style: style)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                SkeletonText(lines: titleLines, style: style)
                SkeletonText(lines: subtitleLines, style: style, lastLineWidth: 200)
            }
            .padding(.horizontal, showImage ? 0 : 16)
            .padding(.vertical, showImage ? 0 : 16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(style.cornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Skeleton List Item
public struct SkeletonListItem: View {
    let style: SkeletonStyle
    let showAvatar: Bool
    let avatarSize: CGFloat
    let titleLines: Int
    let subtitleLines: Int
    
    public init(
        style: SkeletonStyle = .default,
        showAvatar: Bool = true,
        avatarSize: CGFloat = 50,
        titleLines: Int = 1,
        subtitleLines: Int = 1
    ) {
        self.style = style
        self.showAvatar = showAvatar
        self.avatarSize = avatarSize
        self.titleLines = titleLines
        self.subtitleLines = subtitleLines
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            if showAvatar {
                SkeletonCircle(size: avatarSize, style: .circular)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                SkeletonText(lines: titleLines, style: style)
                if subtitleLines > 0 {
                    SkeletonText(lines: subtitleLines, style: style, lastLineWidth: 150)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(style.cornerRadius)
    }
}

// MARK: - Skeleton Grid
public struct SkeletonGrid: View {
    let columns: Int
    let rows: Int
    let spacing: CGFloat
    let itemHeight: CGFloat
    let style: SkeletonStyle
    
    public init(
        columns: Int = 2,
        rows: Int = 3,
        spacing: CGFloat = 16,
        itemHeight: CGFloat = 200,
        style: SkeletonStyle = .default
    ) {
        self.columns = columns
        self.rows = rows
        self.spacing = spacing
        self.itemHeight = itemHeight
        self.style = style
    }
    
    public var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns),
            spacing: spacing
        ) {
            ForEach(0..<(columns * rows), id: \.self) { _ in
                SkeletonRectangle(height: itemHeight, style: style)
            }
        }
    }
}

// MARK: - Skeleton Profile Header
public struct SkeletonProfileHeader: View {
    let style: SkeletonStyle
    
    public init(style: SkeletonStyle = .default) {
        self.style = style
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            SkeletonCircle(size: 100, style: .circular)
            
            VStack(spacing: 8) {
                SkeletonText(lines: 1, style: style, lastLineWidth: 150)
                SkeletonText(lines: 1, style: style, lastLineWidth: 200)
            }
            
            HStack(spacing: 20) {
                ForEach(0..<3, id: \.self) { _ in
                    VStack(spacing: 4) {
                        SkeletonText(lines: 1, style: style, lastLineWidth: 50)
                        SkeletonText(lines: 1, style: style, lastLineWidth: 60)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(style.cornerRadius)
    }
}

// MARK: - Skeleton Comment
public struct SkeletonComment: View {
    let style: SkeletonStyle
    
    public init(style: SkeletonStyle = .default) {
        self.style = style
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            SkeletonCircle(size: 40, style: .circular)
            
            VStack(alignment: .leading, spacing: 8) {
                SkeletonText(lines: 1, style: style, lastLineWidth: 120)
                SkeletonText(lines: 2, style: style)
                
                HStack(spacing: 16) {
                    SkeletonText(lines: 1, style: style, lastLineWidth: 60)
                    SkeletonText(lines: 1, style: style, lastLineWidth: 60)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(style.cornerRadius)
    }
}

// MARK: - Preview
#Preview("Skeleton Loaders") {
    ScrollView {
        VStack(spacing: 30) {
            Text("Skeleton Loaders")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            // Skeleton Text
            VStack(alignment: .leading, spacing: 12) {
                Text("Skeleton Text")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                SkeletonText(lines: 3, lastLineWidth: 180)
            }
            .padding(.horizontal)
            
            Divider()
            
            // Skeleton Cards
            VStack(alignment: .leading, spacing: 12) {
                Text("Skeleton Cards")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 16) {
                    SkeletonCard()
                    SkeletonCard(showImage: false, titleLines: 2, subtitleLines: 3)
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Skeleton List Items
            VStack(alignment: .leading, spacing: 12) {
                Text("Skeleton List Items")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { _ in
                        SkeletonListItem()
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Skeleton Grid
            VStack(alignment: .leading, spacing: 12) {
                Text("Skeleton Grid")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                SkeletonGrid(columns: 2, rows: 2, itemHeight: 150)
            }
            .padding(.horizontal)
            
            Divider()
            
            // Skeleton Profile
            VStack(alignment: .leading, spacing: 12) {
                Text("Skeleton Profile Header")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                SkeletonProfileHeader()
            }
            .padding(.horizontal)
            
            Divider()
            
            // Skeleton Comments
            VStack(alignment: .leading, spacing: 12) {
                Text("Skeleton Comments")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 12) {
                    ForEach(0..<2, id: \.self) { _ in
                        SkeletonComment()
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Custom Skeleton with Modifier
            VStack(alignment: .leading, spacing: 12) {
                Text("Custom Skeleton (with modifier)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                SkeletonModifierPreview()
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    .background(Color(.systemGroupedBackground))
}

// MARK: - Preview Helper
private struct SkeletonModifierPreview: View {
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .skeleton(isLoading: isLoading, style: .circular)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("John Doe")
                        .font(.headline)
                        .skeleton(isLoading: isLoading)
                    
                    Text("Software Developer")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .skeleton(isLoading: isLoading)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            Button(isLoading ? "Show Content" : "Show Skeleton") {
                withAnimation {
                    isLoading.toggle()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

