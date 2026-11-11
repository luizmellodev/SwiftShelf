import SwiftUI
import QuartzCore

// MARK: - Bank Card Flip
//
// A payment card you can actually pick up.
//
// - Drag to turn it in 3D: horizontal drag spins it, vertical drag tilts it,
//   and it springs back when you let go.
// - Flick it (or tap a side) to flip. It lands with a rigid "thunk" haptic.
// - Hold still for a moment to peek: the number and CVV decode digit by digit.
// - A holographic foil and a specular glare track the angle of the card,
//   and a real edge (thickness) shows up when it turns side-on.
//
// The 3D is a custom projection (perspective + yaw + pitch + depth), so the
// two faces and the edge layers sit at different depths of the same slab.

// MARK: - Model

public struct BankCardDetails: Equatable, Sendable {
    public var number: String
    public var holder: String
    public var expiry: String
    public var cvv: String
    public var issuer: String

    public init(number: String, holder: String, expiry: String, cvv: String, issuer: String = "SHELF") {
        self.number = number
        self.holder = holder
        self.expiry = expiry
        self.cvv = cvv
        self.issuer = issuer
    }

    public static let sample = BankCardDetails(
        number: "4512 3456 7890 1234",
        holder: "John Appleseed",
        expiry: "08/28",
        cvv: "382"
    )

    var digits: [Character] { number.filter(\.isNumber) }
    var lastFour: String { String(digits.suffix(4)) }

    /// Groups of four; everything except the last four digits is masked unless revealed.
    func formattedNumber(revealed: Bool) -> String {
        let d = digits
        var out = ""
        for (i, c) in d.enumerated() {
            if i > 0 && i % 4 == 0 { out.append(" ") }
            out.append(revealed || i >= d.count - 4 ? c : "•")
        }
        return out
    }

    func formattedCVV(revealed: Bool) -> String {
        revealed ? cvv : String(repeating: "•", count: cvv.count)
    }
}

// MARK: - Style

public enum BankCardStyle: String, CaseIterable, Identifiable, Sendable {
    case midnight, aurora, titanium

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .midnight: "Midnight"
        case .aurora: "Aurora"
        case .titanium: "Titanium"
        }
    }

    /// The dominant color of the card, handy for tinting surrounding UI.
    public var tint: Color {
        switch self {
        case .midnight: Color(red: 0.38, green: 0.32, blue: 0.98)
        case .aurora: Color(red: 0.93, green: 0.33, blue: 0.58)
        case .titanium: Color(white: 0.62)
        }
    }

    var ink: Color { self == .titanium ? Color(white: 0.13) : .white }
    var accent: Color { self == .titanium ? Color(red: 0.1, green: 0.4, blue: 0.95) : Color(red: 0.62, green: 0.9, blue: 1) }
    var emboss: Color { self == .titanium ? .white.opacity(0.75) : .black.opacity(0.45) }

    var edge: Color {
        switch self {
        case .midnight: Color(red: 0.2, green: 0.2, blue: 0.3)
        case .aurora: Color(red: 0.5, green: 0.22, blue: 0.62)
        case .titanium: Color(white: 0.55)
        }
    }
}

// MARK: - Bank Card Flip

public struct BankCardFlip: View {
    private let details: BankCardDetails
    private let style: BankCardStyle
    private let externalFlipped: Binding<Bool>?
    private let externalRevealed: Binding<Bool>?

    @State private var baseYaw: Double = 0      // multiples of 180
    @State private var dragYaw: Double = 0      // live finger offset
    @State private var pitch: Double = 0
    @State private var lift: Double = 0
    @State private var isTouching = false
    @State private var isPeeking = false
    @State private var internalRevealed = false
    @State private var holdTask: Task<Void, Never>?
    @State private var landings = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    private let maxPitch = 18.0
    private let degreesPerPoint = 0.55

    /// - Parameters:
    ///   - details: What's printed on the card.
    ///   - style: Card finish.
    ///   - isFlipped: Optional binding to drive / observe which side is up.
    ///   - isRevealed: Optional binding to keep the full number and CVV visible.
    ///     Holding the card always reveals them temporarily.
    public init(
        details: BankCardDetails = .sample,
        style: BankCardStyle = .midnight,
        isFlipped: Binding<Bool>? = nil,
        isRevealed: Binding<Bool>? = nil
    ) {
        self.details = details
        self.style = style
        self.externalFlipped = isFlipped
        self.externalRevealed = isRevealed
    }

    private var isFlipped: Bool { !Int((baseYaw / 180).rounded()).isMultiple(of: 2) }
    private var liveShowsBack: Bool { cos((baseYaw + dragYaw) * .pi / 180) < 0 }
    private var persistentRevealed: Bool { externalRevealed?.wrappedValue ?? internalRevealed }
    private var isRevealed: Bool { persistentRevealed || isPeeking }

    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let s = size.width / 340

            ZStack {
                // Colored bloom under the card.
                Ellipse()
                    .fill(style.tint)
                    .frame(width: size.width * 0.78, height: size.height * 0.45)
                    .blur(radius: 38 * s)
                    .opacity((colorScheme == .dark ? 0.55 : 0.32) * (0.65 + 0.35 * lift))
                    .offset(y: size.height * (0.3 + 0.06 * lift))

                BankCardSlab(
                    yaw: baseYaw + dragYaw,
                    pitch: pitch,
                    lift: lift,
                    size: size,
                    thickness: 4.5 * s,
                    edgeColor: style.edge,
                    cornerRadius: 18 * s,
                    front: { tilt in
                        BankCardFront(details: details, style: style, revealed: isRevealed, tilt: tilt, size: size)
                    },
                    back: { tilt in
                        BankCardBack(details: details, style: style, revealed: isRevealed, tilt: tilt, size: size)
                    }
                )
                .compositingGroup()
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.55 : 0.25),
                        radius: 12 + 16 * lift,
                        y: 8 + 14 * lift)
            }
            .contentShape(Rectangle())
            .gesture(dragGesture(width: size.width))
        }
        .aspectRatio(1.586, contentMode: .fit)
        .sensoryFeedback(.impact(weight: .light, intensity: 0.6), trigger: isTouching) { _, touching in touching }
        .sensoryFeedback(.selection, trigger: liveShowsBack) { _, _ in isTouching }
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.9), trigger: landings)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isPeeking) { _, peeking in peeking }
        .onChange(of: externalFlipped?.wrappedValue) { _, newValue in
            if let newValue, newValue != isFlipped { flip(direction: 1) }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(details.issuer) card ending in \(details.lastFour)")
        .accessibilityValue(accessibilityValue)
        .accessibilityHint("Double-tap to flip the card.")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { flip(direction: 1) }
        .accessibilityAction(named: persistentRevealed ? "Hide card details" : "Show card details") {
            setRevealed(!persistentRevealed)
        }
    }

    private var accessibilityValue: String {
        if isFlipped {
            return isRevealed ? "Back. Security code \(details.cvv.map(String.init).joined(separator: " "))" : "Back. Security code hidden"
        }
        let number = isRevealed ? details.digits.map(String.init).joined(separator: " ") : "hidden"
        return "Front. \(details.holder), expires \(details.expiry). Number \(number)"
    }

    // MARK: Gesture

    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if !isTouching {
                    isTouching = true
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { lift = 1 }
                    holdTask = Task {
                        try? await Task.sleep(for: .milliseconds(380))
                        guard !Task.isCancelled else { return }
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { isPeeking = true }
                    }
                }

                let t = value.translation
                if hypot(t.width, t.height) > 10 { holdTask?.cancel() }
                guard !reduceMotion else { return }

                withAnimation(.interactiveSpring(response: 0.22, dampingFraction: 0.86)) {
                    let raw = Double(t.width) * degreesPerPoint
                    dragYaw = Self.rubber(raw, limit: isPeeking ? 22 : 200)
                    pitch = maxPitch * tanh(Double(t.height) / 160)
                }
            }
            .onEnded { value in
                holdTask?.cancel()
                holdTask = nil
                isTouching = false

                if isPeeking {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { isPeeking = false }
                    settle()
                    return
                }

                let t = value.translation
                if hypot(t.width, t.height) < 10 {
                    // Tap: push the side you touched away.
                    flip(direction: value.location.x >= width / 2 ? 1 : -1)
                    return
                }

                let projected = Double(value.predictedEndTranslation.width) * degreesPerPoint
                let steps = max(-1, min(1, (projected / 180).rounded()))
                if steps != 0 { flip(direction: steps) } else { settle() }
            }
    }

    private func flip(direction: Double) {
        let target = baseYaw + (direction >= 0 ? 180 : -180)
        let animation: Animation = reduceMotion
            ? .smooth(duration: 0.3)
            : .spring(response: 0.62, dampingFraction: 0.72)
        withAnimation(animation, completionCriteria: .logicallyComplete) {
            baseYaw = target
            dragYaw = 0
            pitch = 0
            lift = 0
        } completion: {
            landings += 1
        }
        let flipped = !Int((target / 180).rounded()).isMultiple(of: 2)
        if let externalFlipped, externalFlipped.wrappedValue != flipped {
            externalFlipped.wrappedValue = flipped
        }
    }

    private func settle() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.58)) {
            dragYaw = 0
            pitch = 0
            lift = 0
        }
    }

    private func setRevealed(_ value: Bool) {
        if let externalRevealed { externalRevealed.wrappedValue = value } else { internalRevealed = value }
    }

    private static func rubber(_ x: Double, limit: Double) -> Double {
        limit * tanh(x / limit)
    }
}

// MARK: - 3D Slab

/// Resolves rotation handedness once, so positive yaw always pushes the right
/// edge away from the viewer and positive pitch always pushes the bottom edge away.
private enum BankCardAxes {
    static let yawSign: Double = CATransform3DMakeRotation(0.3, 0, 1, 0).m13 < 0 ? 1 : -1
    static let pitchSign: Double = CATransform3DMakeRotation(0.3, 1, 0, 0).m23 < 0 ? 1 : -1
}

/// Draws the card as a slab: back face, edge layers, front face — each at its
/// own depth — and shows whichever face points at the viewer. Animatable, so
/// the face swap and the sheen stay correct on every frame of a spring.
private struct BankCardSlab<Front: View, Back: View>: View, Animatable {
    var yaw: Double
    var pitch: Double
    var lift: Double
    let size: CGSize
    let thickness: CGFloat
    let edgeColor: Color
    let cornerRadius: CGFloat
    let front: (CGPoint) -> Front
    let back: (CGPoint) -> Back

    private let edgeLayers = 6

    var animatableData: AnimatablePair<Double, AnimatablePair<Double, Double>> {
        get { AnimatablePair(yaw, AnimatablePair(pitch, lift)) }
        set {
            yaw = newValue.first
            pitch = newValue.second.first
            lift = newValue.second.second
        }
    }

    var body: some View {
        let yawRad = yaw * .pi / 180
        let showsFront = cos(yawRad) >= 0
        // -1...1 tilt of whichever face is up, used to drive the sheen.
        let tilt = CGPoint(
            x: sin(yawRad) * (showsFront ? 1 : -1),
            y: sin(pitch * .pi / 180) / sin(18 * .pi / 180)
        )
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        ZStack {
            ForEach(0..<edgeLayers, id: \.self) { i in
                let f = (CGFloat(i) + 0.5) / CGFloat(edgeLayers)
                shape
                    .fill(edgeColor.mix(with: .black, by: 0.35 * (1 - abs(Double(f) - 0.5) * 2)))
                    .projectionEffect(projection(z: -thickness / 2 + thickness * f))
            }

            back(tilt)
                .scaleEffect(x: -1, y: 1)
                .opacity(showsFront ? 0 : 1)
                .projectionEffect(projection(z: -thickness / 2))

            front(tilt)
                .opacity(showsFront ? 1 : 0)
                .projectionEffect(projection(z: thickness / 2))
        }
        .frame(width: size.width, height: size.height)
    }

    private func projection(z: CGFloat) -> ProjectionTransform {
        var m = CATransform3DMakeTranslation(-size.width / 2, -size.height / 2, z)
        m = CATransform3DConcat(m, CATransform3DMakeRotation(BankCardAxes.yawSign * yaw * .pi / 180, 0, 1, 0))
        m = CATransform3DConcat(m, CATransform3DMakeRotation(BankCardAxes.pitchSign * pitch * .pi / 180, 1, 0, 0))
        m = CATransform3DConcat(m, CATransform3DMakeTranslation(0, 0, lift * 26))
        var perspective = CATransform3DIdentity
        perspective.m34 = -1 / 1100
        m = CATransform3DConcat(m, perspective)
        m = CATransform3DConcat(m, CATransform3DMakeTranslation(size.width / 2, size.height / 2, 0))
        return ProjectionTransform(m)
    }
}

// MARK: - Faces

private struct BankCardFront: View {
    let details: BankCardDetails
    let style: BankCardStyle
    let revealed: Bool
    let tilt: CGPoint
    let size: CGSize

    var body: some View {
        let s = size.width / 340
        let shape = RoundedRectangle(cornerRadius: 18 * s, style: .continuous)

        ZStack {
            BankCardSurface(style: style, scale: s)
            BankCardHolo(tilt: tilt, style: style)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(details.issuer)
                        .font(.system(size: 17 * s, weight: .heavy, design: .rounded))
                        .tracking(3 * s)
                    Spacer()
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 17 * s, weight: .semibold))
                        .opacity(0.8)
                }

                Spacer(minLength: 0)

                BankCardChip()
                    .frame(width: 46 * s, height: 35 * s)

                Spacer(minLength: 0)

                BankCardScrambleText(
                    text: details.formattedNumber(revealed: revealed),
                    font: .system(size: 21 * s, weight: .medium, design: .monospaced),
                    ink: style.ink,
                    accent: style.accent
                )
                .shadow(color: style.emboss, radius: 0, x: 0, y: 1)

                Spacer(minLength: 0)

                HStack(alignment: .bottom, spacing: 0) {
                    field("CARDHOLDER", details.holder.uppercased(), s)
                    Spacer(minLength: 12 * s)
                    field("VALID THRU", details.expiry, s)
                    BankCardNetworkMark(scale: s)
                        .padding(.leading, 16 * s)
                }
            }
            .foregroundStyle(style.ink)
            .padding(.horizontal, 22 * s)
            .padding(.vertical, 20 * s)

            BankCardGlare(tilt: tilt, scale: s)
        }
        .frame(width: size.width, height: size.height)
        .clipShape(shape)
        .overlay { BankCardRim(shape: shape, tilt: tilt) }
    }

    private func field(_ label: String, _ value: String, _ s: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 3 * s) {
            Text(label)
                .font(.system(size: 7.5 * s, weight: .bold))
                .tracking(1.2 * s)
                .opacity(0.6)
            Text(value)
                .font(.system(size: 13 * s, weight: .semibold, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .shadow(color: style.emboss, radius: 0, x: 0, y: 1)
        }
    }
}

private struct BankCardBack: View {
    let details: BankCardDetails
    let style: BankCardStyle
    let revealed: Bool
    let tilt: CGPoint
    let size: CGSize

    var body: some View {
        let s = size.width / 340
        let shape = RoundedRectangle(cornerRadius: 18 * s, style: .continuous)

        ZStack {
            BankCardSurface(style: style, scale: s)
            BankCardHolo(tilt: tilt, style: style)
                .opacity(0.6)

            VStack(alignment: .leading, spacing: 0) {
                // Magnetic stripe
                Rectangle()
                    .fill(LinearGradient(colors: [Color(white: 0.04), Color(white: 0.17), Color(white: 0.06)],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(height: 42 * s)
                    .padding(.top, 20 * s)

                HStack(alignment: .bottom, spacing: 10 * s) {
                    // Signature panel
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4 * s, style: .continuous)
                            .fill(Color(white: 0.96))
                        BankCardFoilLines(color: Color(red: 0.55, green: 0.65, blue: 0.95), spacing: 4 * s)
                            .opacity(0.25)
                            .clipShape(RoundedRectangle(cornerRadius: 4 * s, style: .continuous))
                        Text(details.holder)
                            .font(.system(size: 15 * s, design: .serif).italic())
                            .foregroundStyle(Color(red: 0.12, green: 0.18, blue: 0.45))
                            .padding(.leading, 10 * s)
                    }
                    .frame(height: 34 * s)

                    VStack(alignment: .leading, spacing: 3 * s) {
                        Text("CVV")
                            .font(.system(size: 7.5 * s, weight: .bold))
                            .tracking(1.2 * s)
                            .foregroundStyle(style.ink.opacity(0.65))
                        BankCardScrambleText(
                            text: details.formattedCVV(revealed: revealed),
                            font: .system(size: 17 * s, weight: .semibold, design: .monospaced),
                            ink: Color(white: 0.1),
                            accent: Color(red: 0.1, green: 0.4, blue: 0.95)
                        )
                        .frame(width: 60 * s, height: 34 * s)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 6 * s, style: .continuous))
                    }
                }
                .padding(.horizontal, 22 * s)
                .padding(.top, 16 * s)

                Text("This card is property of \(details.issuer). Use is subject to the cardholder agreement. If found, please return it to any branch.")
                    .font(.system(size: 7 * s))
                    .foregroundStyle(style.ink.opacity(0.5))
                    .lineLimit(2)
                    .padding(.horizontal, 22 * s)
                    .padding(.top, 10 * s)

                Spacer(minLength: 0)

                HStack(alignment: .center) {
                    BankCardHologram(tilt: tilt)
                        .frame(width: 44 * s, height: 30 * s)
                    Spacer()
                    Text(details.issuer)
                        .font(.system(size: 12 * s, weight: .heavy, design: .rounded))
                        .tracking(3 * s)
                        .foregroundStyle(style.ink.opacity(0.55))
                    BankCardNetworkMark(scale: s * 0.8)
                        .padding(.leading, 10 * s)
                }
                .padding(.horizontal, 22 * s)
                .padding(.bottom, 18 * s)
            }

            BankCardGlare(tilt: tilt, scale: s)
        }
        .frame(width: size.width, height: size.height)
        .clipShape(shape)
        .overlay { BankCardRim(shape: shape, tilt: tilt) }
    }
}

// MARK: - Surfaces & Effects

private struct BankCardSurface: View {
    let style: BankCardStyle
    let scale: CGFloat

    var body: some View {
        switch style {
        case .midnight:
            ZStack {
                LinearGradient(colors: [Color(red: 0.06, green: 0.06, blue: 0.11), Color(red: 0.13, green: 0.12, blue: 0.25)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                RadialGradient(colors: [Color(red: 0.42, green: 0.32, blue: 1).opacity(0.6), .clear],
                               center: UnitPoint(x: 0.95, y: 0), startRadius: 0, endRadius: 250 * scale)
                RadialGradient(colors: [Color(red: 0.1, green: 0.75, blue: 0.9).opacity(0.28), .clear],
                               center: UnitPoint(x: 0, y: 1), startRadius: 0, endRadius: 220 * scale)
            }
        case .aurora:
            MeshGradient(
                width: 3, height: 3,
                points: [[0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.62, 0.42], [1, 0.5], [0, 1], [0.4, 1], [1, 1]],
                colors: [
                    Color(red: 0.98, green: 0.47, blue: 0.35), Color(red: 0.95, green: 0.3, blue: 0.55), Color(red: 0.55, green: 0.25, blue: 0.85),
                    Color(red: 0.85, green: 0.25, blue: 0.6), Color(red: 0.5, green: 0.2, blue: 0.8), Color(red: 0.25, green: 0.3, blue: 0.85),
                    Color(red: 0.35, green: 0.15, blue: 0.55), Color(red: 0.2, green: 0.2, blue: 0.6), Color(red: 0.1, green: 0.45, blue: 0.85),
                ]
            )
        case .titanium:
            ZStack {
                LinearGradient(colors: [Color(white: 0.88), Color(white: 0.7), Color(white: 0.9), Color(white: 0.66)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                BankCardBrushed()
                    .opacity(0.5)
            }
        }
    }
}

private enum BankCardSpectrum {
    static let colors: [Color] = [
        Color(red: 1, green: 0.42, blue: 0.7),
        Color(red: 1, green: 0.85, blue: 0.4),
        Color(red: 0.45, green: 1, blue: 0.7),
        Color(red: 0.35, green: 0.75, blue: 1),
        Color(red: 0.72, green: 0.45, blue: 1),
    ]
}

/// Rainbow foil seen through fine diagonal lines; slides with the tilt.
private struct BankCardHolo: View {
    let tilt: CGPoint
    let style: BankCardStyle

    var body: some View {
        let shift = tilt.x * 0.8 + tilt.y * 0.35
        let magnitude = min(1, hypot(tilt.x, tilt.y))
        let isLight = style == .titanium

        LinearGradient(
            colors: [.clear] + BankCardSpectrum.colors + [.clear],
            startPoint: UnitPoint(x: -0.9 + shift, y: 0),
            endPoint: UnitPoint(x: 1.9 + shift, y: 1)
        )
        .mask(BankCardFoilLines(color: .white, spacing: 3))
        .blendMode(isLight ? .overlay : .plusLighter)
        .opacity((isLight ? 0.35 : 0.08) + (isLight ? 0.55 : 0.45) * magnitude)
        .allowsHitTesting(false)
    }
}

/// A soft hotspot plus a sharp diagonal streak, both moving against the tilt.
private struct BankCardGlare: View {
    let tilt: CGPoint
    let scale: CGFloat

    var body: some View {
        let magnitude = min(1, hypot(tilt.x, tilt.y))
        let band = min(0.88, max(0.12, 0.5 - tilt.x * 0.7 - tilt.y * 0.3))

        ZStack {
            RadialGradient(
                colors: [.white.opacity(0.32), .clear],
                center: UnitPoint(x: 0.5 - tilt.x * 0.9, y: 0.3 - tilt.y * 0.9),
                startRadius: 0,
                endRadius: 230 * scale
            )
            .opacity(0.3 + 0.7 * magnitude)

            LinearGradient(
                stops: [
                    .init(color: .clear, location: band - 0.12),
                    .init(color: .white.opacity(0.08 + 0.18 * magnitude), location: band),
                    .init(color: .clear, location: band + 0.12),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .blendMode(.plusLighter)
        .allowsHitTesting(false)
    }
}

/// A thin bevel whose bright side follows the light.
private struct BankCardRim: View {
    let shape: RoundedRectangle
    let tilt: CGPoint

    var body: some View {
        shape.strokeBorder(
            LinearGradient(
                colors: [.white.opacity(0.5), .white.opacity(0.04), .white.opacity(0.22)],
                startPoint: UnitPoint(x: 0.5 - tilt.x, y: 0 - tilt.y * 0.5),
                endPoint: UnitPoint(x: 0.5 + tilt.x, y: 1 + tilt.y * 0.5)
            ),
            lineWidth: 1
        )
        .allowsHitTesting(false)
    }
}

private struct BankCardFoilLines: View {
    let color: Color
    let spacing: CGFloat

    var body: some View {
        Canvas { context, size in
            var path = Path()
            var x = -size.height
            while x < size.width {
                path.move(to: CGPoint(x: x, y: size.height))
                path.addLine(to: CGPoint(x: x + size.height, y: 0))
                x += spacing
            }
            context.stroke(path, with: .color(color), lineWidth: max(0.6, spacing / 3))
        }
    }
}

private struct BankCardBrushed: View {
    var body: some View {
        Canvas { context, size in
            var y: CGFloat = 0
            var i = 0
            while y < size.height {
                let alpha = 0.05 + 0.12 * abs(sin(Double(i) * 12.9898))
                context.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 0.7)),
                             with: .color(.white.opacity(alpha)))
                y += 1.5
                i += 1
            }
        }
    }
}

private struct BankCardHologram: View {
    let tilt: CGPoint

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 5, style: .continuous)
        shape
            .fill(AngularGradient(colors: BankCardSpectrum.colors + [BankCardSpectrum.colors[0]],
                                  center: .center,
                                  angle: .degrees(tilt.x * 170 + tilt.y * 90)))
            .overlay { BankCardFoilLines(color: .white, spacing: 2.5).opacity(0.35).blendMode(.overlay) }
            .overlay {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.75))
            }
            .clipShape(shape)
            .overlay { shape.strokeBorder(.white.opacity(0.5), lineWidth: 0.5) }
    }
}

private struct BankCardChip: View {
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 6, style: .continuous)
        shape
            .fill(LinearGradient(
                colors: [Color(red: 0.95, green: 0.83, blue: 0.55), Color(red: 0.76, green: 0.6, blue: 0.3), Color(red: 0.97, green: 0.88, blue: 0.64)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .overlay {
                BankCardChipLines()
                    .stroke(Color(red: 0.5, green: 0.38, blue: 0.15).opacity(0.55), lineWidth: 0.8)
            }
            .clipShape(shape)
            .overlay { shape.strokeBorder(.black.opacity(0.15), lineWidth: 0.5) }
    }
}

private struct BankCardChipLines: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.addRoundedRect(in: CGRect(x: w * 0.32, y: h * 0.25, width: w * 0.36, height: h * 0.5),
                         cornerSize: CGSize(width: 3, height: 3))
        for y in [h * 0.33, h * 0.67] {
            p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: w * 0.32, y: y))
            p.move(to: CGPoint(x: w * 0.68, y: y)); p.addLine(to: CGPoint(x: w, y: y))
        }
        p.move(to: CGPoint(x: w * 0.5, y: 0)); p.addLine(to: CGPoint(x: w * 0.5, y: h * 0.25))
        p.move(to: CGPoint(x: w * 0.5, y: h * 0.75)); p.addLine(to: CGPoint(x: w * 0.5, y: h))
        return p
    }
}

private struct BankCardNetworkMark: View {
    let scale: CGFloat

    var body: some View {
        HStack(spacing: -11 * scale) {
            Circle().fill(Color(red: 0.92, green: 0.12, blue: 0.16))
            Circle().fill(Color(red: 0.98, green: 0.62, blue: 0.1)).opacity(0.88)
        }
        .frame(width: 45 * scale, height: 28 * scale)
    }
}

// MARK: - Scramble Text

/// Text that decodes into place: changed characters cycle through random
/// digits (tinted with `accent`) and settle one after another, left to right.
private struct BankCardScrambleText: View {
    let text: String
    let font: Font
    let ink: Color
    let accent: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown: String?
    @State private var hot: Set<Int> = []

    var body: some View {
        let chars = Array(shown ?? text)
        chars.indices.reduce(Text(verbatim: "")) { partial, i in
            let piece = Text(verbatim: String(chars[i]))
                .foregroundStyle(hot.contains(i) ? accent : ink)
            return Text("\(partial)\(piece)")
        }
        .font(font)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .task(id: text) { await decode() }
    }

    private func decode() async {
        guard let current = shown else { shown = text; return }
        let from = Array(current), to = Array(text)
        guard from != to else { return }
        guard from.count == to.count, !reduceMotion else {
            shown = text
            hot = []
            return
        }

        let changing = to.indices.filter { from[$0] != to[$0] }
        let glyphs = Array("0123456789")
        let start = Date()

        while !Task.isCancelled {
            let elapsed = Date().timeIntervalSince(start)
            var out = to
            var live = Set<Int>()
            for (order, i) in changing.enumerated() where elapsed < 0.14 + Double(order) * 0.035 {
                out[i] = glyphs.randomElement() ?? "0"
                live.insert(i)
            }
            shown = String(out)
            hot = live
            if live.isEmpty { return }
            try? await Task.sleep(for: .milliseconds(45))
        }
    }
}

// MARK: - Preview

#Preview("Bank Card Flip") {
    struct Demo: View {
        @State private var style: BankCardStyle = .midnight
        @State private var flipped = false

        var body: some View {
            VStack(spacing: 28) {
                BankCardFlip(style: style, isFlipped: $flipped)
                    .padding(.horizontal, 24)

                Picker("Finish", selection: $style) {
                    ForEach(BankCardStyle.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 40)

                Text("Drag to tilt · Flick or tap to flip · Hold to peek")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
    }
    return Demo()
}
