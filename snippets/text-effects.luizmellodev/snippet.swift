import SwiftUI

// MARK: - Glyph Blur Renderer (iOS 18+)

/// A `TextRenderer` that animates every glyph individually: each one fades in,
/// rises and un-blurs slightly after the previous one.
@available(iOS 18.0, *)
public struct GlyphBlurRenderer: TextRenderer, Animatable {
    public var progress: Double
    var spread: Double
    var blur: CGFloat
    var lift: CGFloat

    public init(progress: Double, spread: Double = 0.45, blur: CGFloat = 10, lift: CGFloat = 12) {
        self.progress = progress
        self.spread = spread
        self.blur = blur
        self.lift = lift
    }

    public var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    public func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        let glyphs = layout.flatMap { $0 }.flatMap { $0 }
        let count = Double(max(glyphs.count, 1))

        for (index, glyph) in glyphs.enumerated() {
            let start = Double(index) / count * (1 - spread)
            let local = min(max((progress - start) / spread, 0), 1)
            let eased = 1 - pow(1 - local, 3)

            var copy = ctx
            copy.opacity = eased
            copy.addFilter(.blur(radius: (1 - eased) * blur))
            copy.translateBy(x: 0, y: (1 - eased) * lift)
            copy.draw(glyph)
        }
    }
}

/// Transition that uses `GlyphBlurRenderer`: glyphs rise in from below and float away upward.
@available(iOS 18.0, *)
public struct GlyphBlurTransition: Transition {
    public init() {}

    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.textRenderer(
            GlyphBlurRenderer(progress: phase.isIdentity ? 1 : 0,
                              lift: phase == .didDisappear ? -14 : 14)
        )
    }
}

// MARK: - Blur Reveal Text

/// Text that materializes glyph by glyph. Tap to replay.
@available(iOS 18.0, *)
public struct BlurRevealText: View {
    let text: String
    var duration: Double

    @State private var progress: Double = 0

    public init(_ text: String, duration: Double = 1.4) {
        self.text = text
        self.duration = duration
    }

    public var body: some View {
        Text(text)
            .textRenderer(GlyphBlurRenderer(progress: progress))
            .onAppear(perform: play)
            .onTapGesture(perform: play)
    }

    private func play() {
        progress = 0
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(40))
            withAnimation(.easeOut(duration: duration)) { progress = 1 }
        }
    }
}

// MARK: - Word Rotator

/// Cycles through words; each swap dissolves glyph by glyph.
/// Style it like any `Text` (font, foregroundStyle with gradients, …).
@available(iOS 18.0, *)
public struct WordRotator: View {
    let words: [String]
    var interval: Duration

    @State private var index = 0

    public init(_ words: [String], interval: Duration = .seconds(2.4)) {
        self.words = words
        self.interval = interval
    }

    public var body: some View {
        ZStack {
            Text(words.isEmpty ? "" : words[index])
                .id(index)
                .transition(GlyphBlurTransition())
        }
        .task {
            guard words.count > 1 else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: interval)
                withAnimation(.smooth(duration: 0.9)) {
                    index = (index + 1) % words.count
                }
            }
        }
    }
}

// MARK: - Shiny Text

/// Muted text with a band of light sweeping across it.
public struct ShinyText: View {
    let text: String
    var duration: Double
    var pause: Double

    public init(_ text: String, duration: Double = 1.8, pause: Double = 0.9) {
        self.text = text
        self.duration = duration
        self.pause = pause
    }

    public var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let phase = time.truncatingRemainder(dividingBy: duration + pause) / duration

            Text(text)
                .foregroundStyle(.secondary)
                .overlay {
                    GeometryReader { proxy in
                        let width = proxy.size.width
                        LinearGradient(colors: [.clear, .primary, .clear], startPoint: .leading, endPoint: .trailing)
                            .frame(width: width * 0.45)
                            .offset(x: -width * 0.45 + width * 1.45 * phase)
                    }
                    .mask(Text(text))
                }
        }
    }
}

// MARK: - Scramble Text

/// "Decrypting" text: characters cycle through random symbols and
/// lock in from left to right. Tap to replay.
public struct ScrambleText: View {
    let text: String
    var duration: Double

    @State private var display = ""
    @State private var run = 0

    private static let symbols = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#%&*$@")

    public init(_ text: String, duration: Double = 0.9) {
        self.text = text
        self.duration = duration
    }

    public var body: some View {
        Text(display.isEmpty ? text : display)
            .monospaced()
            .contentShape(Rectangle())
            .onTapGesture { run += 1 }
            .task(id: run) { await scramble() }
            .sensoryFeedback(.impact(weight: .light), trigger: run)
            .accessibilityLabel(text)
    }

    private func scramble() async {
        let target = Array(text)
        let steps = max(Int(duration * 30), 1)

        for step in 0...steps {
            guard !Task.isCancelled else { return }
            let locked = Int(Double(target.count) * Double(step) / Double(steps))
            display = String(target.enumerated().map { index, char in
                if index < locked || char == " " { return char }
                let random = Self.symbols.randomElement()!
                return char.isLowercase ? Character(random.lowercased()) : random
            })
            try? await Task.sleep(for: .milliseconds(33))
        }
        display = text
    }
}

// MARK: - Preview

#Preview("Text Effects") {
    VStack(alignment: .leading, spacing: 36) {
        BlurRevealText("Designed to feel alive.")
            .font(.system(size: 34, weight: .bold, design: .rounded))

        VStack(alignment: .leading, spacing: 0) {
            Text("Build apps that feel")
                .font(.title.bold())
            WordRotator(["magical.", "native.", "effortless.", "yours."])
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(LinearGradient(colors: [.purple, .pink, .orange], startPoint: .leading, endPoint: .trailing))
        }

        ShinyText("✨ Introducing SwiftShelf Pro  →")
            .font(.headline)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemFill), in: Capsule())

        ScrambleText("ACCESS GRANTED")
            .font(.title2.bold())
    }
    .padding(24)
}
