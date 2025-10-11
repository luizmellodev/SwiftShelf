import SwiftUI

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
