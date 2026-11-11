import SwiftUI

// MARK: - Touch Confetti Emitter

/// Drives a confetti overlay. Keep one in `@State`, attach it with
/// `.touchConfetti(_:)`, then call `burst(at:)` or `fireCannons()`.
///
/// Pieces are pure physics functions of time (gravity + air drag + sway),
/// so a single `Canvas` renders hundreds of them without per-frame state.
@MainActor
@Observable
public final class TouchConfettiEmitter {
    public var palette: [Color]
    /// Downward acceleration, points/s².
    public var gravity: CGFloat
    /// Upper bound on live pieces.
    public var maxPieces: Int

    fileprivate private(set) var pieces: [TouchConfettiPiece] = []
    /// Global frame of the overlay, used to aim the cannons.
    @ObservationIgnored fileprivate var bounds: CGRect = .zero
    fileprivate private(set) var burstCount = 0
    fileprivate private(set) var cannonCount = 0
    private var cleanup: Task<Void, Never>?

    nonisolated public static let festive: [Color] = [
        Color(red: 1.0, green: 0.36, blue: 0.42), Color(red: 1.0, green: 0.72, blue: 0.2),
        Color(red: 0.25, green: 0.82, blue: 0.62), Color(red: 0.3, green: 0.6, blue: 1.0),
        Color(red: 0.68, green: 0.45, blue: 1.0), Color(red: 1.0, green: 0.55, blue: 0.85),
    ]

    public init(palette: [Color] = TouchConfettiEmitter.festive, gravity: CGFloat = 820, maxPieces: Int = 700) {
        self.palette = palette
        self.gravity = gravity
        self.maxPieces = maxPieces
    }

    /// Radial burst from a point in **global** coordinates (what `.touchConfetti` taps report).
    public func burst(at point: CGPoint, count: Int = 70) {
        let now = Date.now.timeIntervalSinceReferenceDate
        let fresh = (0..<count).map { _ -> TouchConfettiPiece in
            let angle = Double.random(in: 0..<(2 * .pi))
            let speed = CGFloat.random(in: 350...1_250)
            return makePiece(at: point,
                             velocity: CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed - 380),
                             drag: .random(in: 3.6...5.2), birth: now)
        }
        append(fresh)
        burstCount += 1
    }

    /// Fires two cannons from the bottom corners of the overlay, aimed up and inward.
    public func fireCannons(count: Int = 110) {
        guard bounds.width > 0 else { return }
        let now = Date.now.timeIntervalSinceReferenceDate
        let reach = bounds.height
        var fresh: [TouchConfettiPiece] = []
        for side in [-1.0, 1.0] {
            let origin = CGPoint(x: side < 0 ? bounds.minX : bounds.maxX, y: bounds.maxY + 10)
            for _ in 0..<(count / 2) {
                let angle = (-90 - side * Double.random(in: 18...40)) * .pi / 180
                let speed = reach * CGFloat.random(in: 2.0...3.4)
                fresh.append(makePiece(at: origin,
                                       velocity: CGVector(dx: CGFloat(cos(angle)) * speed, dy: CGFloat(sin(angle)) * speed),
                                       drag: .random(in: 2.6...3.4),
                                       birth: now + .random(in: 0...0.12)))
            }
        }
        append(fresh)
        cannonCount += 1
    }

    private func makePiece(at point: CGPoint, velocity: CGVector, drag: CGFloat, birth: Double) -> TouchConfettiPiece {
        TouchConfettiPiece(
            origin: point,
            velocity: velocity,
            drag: drag,
            birth: birth,
            lifetime: .random(in: 2.4...3.6),
            color: palette.randomElement() ?? .pink,
            shape: TouchConfettiShape.allCases.randomElement()!,
            size: .random(in: 6...11),
            spin: .random(in: -9...9),
            flip: .random(in: 5...14),
            sway: .random(in: 10...28),
            swayPhase: .random(in: 0...(2 * .pi))
        )
    }

    private func append(_ fresh: [TouchConfettiPiece]) {
        let now = Date.now.timeIntervalSinceReferenceDate
        pieces.removeAll { now - $0.birth > $0.lifetime }
        pieces.append(contentsOf: fresh)
        if pieces.count > maxPieces { pieces.removeFirst(pieces.count - maxPieces) }
        scheduleCleanup()
    }

    private func scheduleCleanup() {
        cleanup?.cancel()
        cleanup = Task { [weak self] in
            try? await Task.sleep(for: .seconds(3.8))
            guard !Task.isCancelled, let self else { return }
            let now = Date.now.timeIntervalSinceReferenceDate
            self.pieces.removeAll { now - $0.birth > $0.lifetime }
        }
    }
}

// MARK: - Piece Model

fileprivate enum TouchConfettiShape: CaseIterable {
    case ribbon, square, circle, triangle
}

fileprivate struct TouchConfettiPiece {
    var origin: CGPoint
    var velocity: CGVector
    var drag: CGFloat
    var birth: Double
    var lifetime: Double
    var color: Color
    var shape: TouchConfettiShape
    var size: CGFloat
    var spin: Double
    var flip: Double
    var sway: CGFloat
    var swayPhase: Double

    /// Closed-form motion with linear air drag: v(t) = v₀·e^(−kt), terminal speed g/k.
    func position(at age: Double, gravity: CGFloat) -> CGPoint {
        let t = CGFloat(age)
        let decay = (1 - exp(-drag * t)) / drag
        let terminal = gravity / drag
        let x = origin.x + velocity.dx * decay + sin(age * 3.2 + swayPhase) * sway * min(t, 1)
        let y = origin.y + (velocity.dy - terminal) * decay + terminal * t
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Overlay Modifier

public extension View {
    /// Overlays a confetti canvas driven by `emitter`.
    /// With `tapToBurst`, any tap on the view bursts confetti from the finger
    /// (observed simultaneously, so buttons still work).
    func touchConfetti(_ emitter: TouchConfettiEmitter, tapToBurst: Bool = true) -> some View {
        modifier(TouchConfettiModifier(emitter: emitter, tapToBurst: tapToBurst))
    }
}

private struct TouchConfettiModifier: ViewModifier {
    let emitter: TouchConfettiEmitter
    var tapToBurst: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                TouchConfettiCanvas(emitter: emitter)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            .simultaneousGesture(
                SpatialTapGesture(coordinateSpace: .global).onEnded { value in
                    emitter.burst(at: value.location)
                },
                isEnabled: tapToBurst
            )
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.8), trigger: emitter.burstCount)
            .sensoryFeedback(.impact(weight: .heavy), trigger: emitter.cannonCount)
    }
}

private struct TouchConfettiCanvas: View {
    let emitter: TouchConfettiEmitter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let pieces = emitter.pieces
        let gravity = emitter.gravity
        TimelineView(.animation(paused: pieces.isEmpty)) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, _ in
                let origin = emitter.bounds.origin
                ctx.translateBy(x: -origin.x, y: -origin.y)
                for piece in pieces {
                    let age = now - piece.birth
                    guard age >= 0, age < piece.lifetime else { continue }
                    draw(piece, age: age, gravity: gravity, in: ctx)
                }
            }
        }
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { emitter.bounds = $0 }
    }

    private func draw(_ piece: TouchConfettiPiece, age: Double, gravity: CGFloat, in base: GraphicsContext) {
        var ctx = base
        let point = piece.position(at: age, gravity: gravity)
        let remaining = piece.lifetime - age
        ctx.opacity = min(remaining / 0.6, 1) * min(age / 0.05, 1)

        let flip = reduceMotion ? 1 : cos(age * piece.flip)
        ctx.translateBy(x: point.x, y: point.y)
        ctx.rotate(by: .radians(reduceMotion ? 0 : age * piece.spin))
        ctx.scaleBy(x: 1, y: max(abs(flip), 0.08))

        // Back faces read slightly darker, selling the 3D tumble.
        let shade = flip >= 0 ? piece.color : piece.color.mix(with: .black, by: 0.25)
        let s = piece.size
        let path: Path
        switch piece.shape {
        case .ribbon:
            path = Path(roundedRect: CGRect(x: -s * 0.22, y: -s * 0.75, width: s * 0.44, height: s * 1.5), cornerRadius: 1)
        case .square:
            path = Path(CGRect(x: -s / 2, y: -s / 2, width: s, height: s * 0.8))
        case .circle:
            path = Path(ellipseIn: CGRect(x: -s * 0.4, y: -s * 0.4, width: s * 0.8, height: s * 0.8))
        case .triangle:
            var tri = Path()
            tri.move(to: CGPoint(x: 0, y: -s * 0.55))
            tri.addLine(to: CGPoint(x: s * 0.5, y: s * 0.4))
            tri.addLine(to: CGPoint(x: -s * 0.5, y: s * 0.4))
            tri.closeSubpath()
            path = tri
        }
        ctx.fill(path, with: .color(shade))
    }
}

// MARK: - Preview

#Preview("Touch Confetti") {
    @Previewable @State var confetti = TouchConfettiEmitter()

    VStack(spacing: 18) {
        Spacer()
        Text("🎉").font(.system(size: 64))
        Text("Tap anywhere")
            .font(.system(size: 34, weight: .bold, design: .rounded))
        Text("or fire the cannons")
            .foregroundStyle(.secondary)
        Spacer()
        Button {
            confetti.fireCannons()
        } label: {
            Label("Celebrate", systemImage: "party.popper.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.pink.gradient, in: Capsule())
                .foregroundStyle(.white)
        }
        .padding(24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .contentShape(Rectangle())
    .touchConfetti(confetti)
}
