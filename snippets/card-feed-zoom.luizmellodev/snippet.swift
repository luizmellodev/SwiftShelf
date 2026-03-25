import SwiftUI

// MARK: - Feed View

struct DemoCardFeedView: View {
    @Namespace private var zoomNamespace: Namespace.ID
    @State private var selectedCard: String?
    @Environment(\.dismiss) private var dismiss

    private let cardIds = (1...8).map { "demo-\($0)" }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVStack(spacing: 16) {
                    ForEach(cardIds, id: \.self) { id in
                        DemoCardContent {
                            selectedCard = id
                        }
                        .matchedTransitionSource(id: id, in: zoomNamespace)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical)
            }
            .navigationTitle("Reflections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .tint(.primary)
                }
            }
            .navigationDestination(item: $selectedCard) { id in
                DemoCardDetailView()
                    .navigationTransition(.zoom(sourceID: id, in: zoomNamespace))
            }
        }
    }
}

// MARK: - Card Content

private struct DemoCardContent: View {
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category pill
            RoundedRectangle(cornerRadius: 8)
                .fill(.secondary.opacity(0.12))
                .frame(width: 80, height: 20)

            // Title
            RoundedRectangle(cornerRadius: 6)
                .fill(.secondary.opacity(0.18))
                .frame(width: 180, height: 18)

            // Body lines
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.secondary.opacity(0.12))
                    .frame(height: 14)
                RoundedRectangle(cornerRadius: 4)
                    .fill(.secondary.opacity(0.12))
                    .frame(height: 14)
                RoundedRectangle(cornerRadius: 4)
                    .fill(.secondary.opacity(0.12))
                    .frame(width: 200, height: 14)
            }

            Divider()
                .overlay(.secondary.opacity(0.2))

            // Footer
            HStack {
                Circle()
                    .fill(.secondary.opacity(0.18))
                    .frame(width: 24, height: 24)

                RoundedRectangle(cornerRadius: 4)
                    .fill(.secondary.opacity(0.14))
                    .frame(width: 60, height: 12)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "heart")
                        .font(.caption)
                    RoundedRectangle(cornerRadius: 3)
                        .frame(width: 16, height: 10)
                }
                .foregroundStyle(.secondary.opacity(0.35))

                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                        .font(.caption)
                    RoundedRectangle(cornerRadius: 3)
                        .frame(width: 16, height: 10)
                }
                .foregroundStyle(.secondary.opacity(0.35))
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Detail View

private struct DemoCardDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Category pill
                RoundedRectangle(cornerRadius: 8)
                    .fill(.secondary.opacity(0.12))
                    .frame(width: 90, height: 22)

                // Title
                RoundedRectangle(cornerRadius: 6)
                    .fill(.secondary.opacity(0.18))
                    .frame(width: 220, height: 22)

                // Author row
                HStack(spacing: 10) {
                    Circle()
                        .fill(.secondary.opacity(0.18))
                        .frame(width: 36, height: 36)

                    VStack(alignment: .leading, spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.secondary.opacity(0.18))
                            .frame(width: 80, height: 14)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.secondary.opacity(0.12))
                            .frame(width: 50, height: 10)
                    }
                }

                Divider()
                    .overlay(.secondary.opacity(0.2))

                // Body lines
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<6, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.secondary.opacity(0.12))
                            .frame(maxWidth: i == 5 ? 160 : .infinity, maxHeight: 14)
                    }
                }

                // Placeholder image
                RoundedRectangle(cornerRadius: 12)
                    .fill(.secondary.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary.opacity(0.25))
                    )

                // Interaction bar
                HStack(spacing: 24) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart")
                        RoundedRectangle(cornerRadius: 3)
                            .frame(width: 20, height: 12)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                        RoundedRectangle(cornerRadius: 3)
                            .frame(width: 20, height: 12)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "eye")
                        RoundedRectangle(cornerRadius: 3)
                            .frame(width: 20, height: 12)
                    }

                    Spacer()

                    Image(systemName: "square.and.arrow.up")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary.opacity(0.35))

                Spacer(minLength: 40)
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
}

// MARK: - Preview

#Preview {
    DemoCardFeedView()
}
