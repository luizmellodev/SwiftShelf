import SwiftUI

// MARK: - Typewriter Text
//
// Reveals text character by character with a blinking cursor.
// Tap to replay the animation.

struct TypewriterText: View {
    let fullText: String
    var speed: Double = 0.06
    var font: Font = .title2.weight(.medium)

    @State private var displayed = ""
    @State private var cursorVisible = true
    @State private var finished = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 1) {
            Text(displayed)
                .font(font)

            Rectangle()
                .fill(.primary)
                .frame(width: 2, height: fontHeight)
                .opacity(cursorVisible ? 1 : 0)
                .animation(
                    .easeInOut(duration: 0.48).repeatForever(autoreverses: true),
                    value: cursorVisible
                )
        }
        .onAppear {
            startTyping()
            cursorVisible = false
        }
        .onTapGesture {
            replay()
        }
    }

    private var fontHeight: CGFloat {
        switch font {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline: return 17
        default: return 17
        }
    }

    private func startTyping() {
        displayed = ""
        finished = false
        for (i, char) in fullText.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + speed * Double(i)) {
                displayed.append(char)
                if displayed.count == fullText.count {
                    finished = true
                }
            }
        }
    }

    private func replay() {
        guard finished else { return }
        startTyping()
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 28) {
        TypewriterText(fullText: "Hello, SwiftUI! 👋", speed: 0.07)
        TypewriterText(fullText: "Building beautiful interfaces.", speed: 0.05)
        TypewriterText(
            fullText: "Tap to replay.",
            speed: 0.08,
            font: .callout
        )
    }
    .padding(32)
    .frame(maxWidth: .infinity, alignment: .leading)
}
