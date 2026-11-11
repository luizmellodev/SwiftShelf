import SwiftUI

// MARK: - Device Model

/// Something the radar can discover.
public struct RadarPulseDevice: Identifiable, Hashable {
    public let id: String
    public var name: String
    public var systemImage: String
    public var tint: Color
    /// Compass bearing (0° = top, clockwise).
    public var bearing: Angle
    /// 0 (center) ... 1 (outer edge).
    public var distance: CGFloat

    public init(id: String? = nil, name: String, systemImage: String, tint: Color, bearing: Angle, distance: CGFloat) {
        self.id = id ?? name
        self.name = name
        self.systemImage = systemImage
        self.tint = tint
        self.bearing = bearing
        self.distance = distance
    }
}

// MARK: - Radar Pulse

/// "Searching for nearby devices…" radar: ripples emanate from the center,
/// a gradient sweep rotates around it, and each device pops in with a ping
/// the moment the sweep passes over it.
public struct RadarPulse<Center: View>: View {
    var devices: [RadarPulseDevice]
    var isScanning: Bool
    var tint: Color
    var sweepPeriod: Double
    var rippleCount: Int
    var onDiscover: ((RadarPulseDevice) -> Void)?
    var center: Center

    @State private var startDate = Date.now
    @State private var discovered: [RadarPulseDevice] = []
    @State private var diameter: CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        devices: [RadarPulseDevice],
        isScanning: Bool = true,
        tint: Color = .blue,
        sweepPeriod: Double = 3.2,
        rippleCount: Int = 3,
        onDiscover: ((RadarPulseDevice) -> Void)? = nil,
        @ViewBuilder center: () -> Center
    ) {
        self.devices = devices
        self.isScanning = isScanning
        self.tint = tint
        self.sweepPeriod = sweepPeriod
        self.rippleCount = rippleCount
        self.onDiscover = onDiscover
        self.center = center()
    }

    private var radius: CGFloat { diameter / 2 }

    public var body: some View {
        ZStack {
            TimelineView(.animation(paused: !isScanning)) { timeline in
                let elapsed = timeline.date.timeIntervalSince(startDate)
                Canvas { ctx, size in
                    drawScope(in: &ctx, size: size, elapsed: elapsed)
                }
            }
            .accessibilityHidden(true)

            center

            ForEach(discovered) { device in
                RadarPulseBlip(device: device)
                    .offset(x: CGFloat(sin(device.bearing.radians)) * device.distance * radius,
                            y: CGFloat(-cos(device.bearing.radians)) * device.distance * radius)
                    .transition(.scale(scale: 0.2).combined(with: .opacity))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onGeometryChange(for: CGFloat.self) { min($0.size.width, $0.size.height) } action: { diameter = $0 }
        .task(id: scanKey) { await scan() }
        .sensoryFeedback(.impact(weight: .light), trigger: discovered.count) { old, new in new > old }
    }

    private var scanKey: [String] { isScanning ? ["on"] + devices.map(\.id) : ["off"] }

    // MARK: Discovery

    /// Reveals each device exactly when the sweep's leading edge reaches its bearing.
    private func scan() async {
        guard isScanning else { return }
        startDate = .now
        withAnimation(.easeOut(duration: 0.25)) { discovered = [] }

        let schedule = devices
            .map { device -> (Double, RadarPulseDevice) in
                var degrees = device.bearing.degrees.truncatingRemainder(dividingBy: 360)
                if degrees < 0 { degrees += 360 }
                // First pass skips devices too close to "now" so they don't pop instantly.
                let delay = degrees / 360 * sweepPeriod + (degrees < 20 ? sweepPeriod : 0)
                return (delay, device)
            }
            .sorted { $0.0 < $1.0 }

        for (delay, device) in schedule {
            let wait = delay - Date.now.timeIntervalSince(startDate)
            if wait > 0 { try? await Task.sleep(for: .seconds(wait)) }
            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) {
                discovered.append(device)
            }
            onDiscover?(device)
        }
    }

    // MARK: Drawing

    private func drawScope(in ctx: inout GraphicsContext, size: CGSize, elapsed: Double) {
        let c = CGPoint(x: size.width / 2, y: size.height / 2)
        let r = min(size.width, size.height) / 2
        let isDark = colorScheme == .dark
        let gridColor = isDark ? Color.white : Color.black

        func circle(_ radius: CGFloat) -> Path {
            Path(ellipseIn: CGRect(x: c.x - radius, y: c.y - radius, width: radius * 2, height: radius * 2))
        }

        // Scope background + grid.
        ctx.fill(circle(r), with: .radialGradient(
            Gradient(colors: [tint.opacity(isDark ? 0.16 : 0.08), tint.opacity(isDark ? 0.04 : 0.02)]),
            center: c, startRadius: 0, endRadius: r))
        for step in 1...4 {
            ctx.stroke(circle(r * CGFloat(step) / 4), with: .color(gridColor.opacity(step == 4 ? 0.14 : 0.07)), lineWidth: 1)
        }
        var cross = Path()
        cross.move(to: CGPoint(x: c.x - r, y: c.y)); cross.addLine(to: CGPoint(x: c.x + r, y: c.y))
        cross.move(to: CGPoint(x: c.x, y: c.y - r)); cross.addLine(to: CGPoint(x: c.x, y: c.y + r))
        ctx.stroke(cross, with: .color(gridColor.opacity(0.06)), style: StrokeStyle(lineWidth: 1, dash: [2, 4]))

        guard isScanning else { return }

        // Ripples.
        let rippleSpeed = sweepPeriod * 0.8
        for index in 0..<max(rippleCount, 0) {
            let raw = elapsed / rippleSpeed + Double(index) / Double(rippleCount)
            let p = CGFloat(raw - floor(raw))
            let eased = 1 - pow(1 - p, 2)
            let ripple = circle(r * 0.12 + r * 0.88 * eased)
            ctx.stroke(ripple, with: .color(tint.opacity(Double(pow(1 - p, 1.6)) * 0.75)), lineWidth: 1.5 + 2 * (1 - p))
        }

        guard !reduceMotion else { return }

        // Sweep: a conic wedge trailing behind the leading edge.
        let sweep = -90 + elapsed / sweepPeriod * 360
        let wedge = 80.0
        var slice = Path()
        slice.move(to: c)
        slice.addArc(center: c, radius: r, startAngle: .degrees(sweep - wedge), endAngle: .degrees(sweep), clockwise: false)
        slice.closeSubpath()

        var glow = ctx
        if isDark { glow.blendMode = .plusLighter }
        glow.fill(slice, with: .conicGradient(
            Gradient(stops: [
                .init(color: tint.opacity(0), location: 0),
                .init(color: tint.opacity(isDark ? 0.5 : 0.32), location: wedge / 360),
                .init(color: tint.opacity(0), location: wedge / 360 + 0.0001),
            ]),
            center: c, angle: .degrees(sweep - wedge)))

        let edge = CGPoint(x: c.x + cos(sweep * .pi / 180) * r, y: c.y + sin(sweep * .pi / 180) * r)
        var beam = Path()
        beam.move(to: c); beam.addLine(to: edge)
        glow.addFilter(.blur(radius: 3))
        glow.stroke(beam, with: .color(tint.opacity(0.9)), lineWidth: 4)
        ctx.stroke(beam, with: .linearGradient(Gradient(colors: [tint.opacity(0.2), tint]), startPoint: c, endPoint: edge),
                   lineWidth: 1.5)
    }
}

// MARK: - Blip

/// A discovered device: avatar with a one-shot "ping" ring and name label.
private struct RadarPulseBlip: View {
    let device: RadarPulseDevice
    @State private var pinged = false

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(device.tint, lineWidth: 2)
                    .scaleEffect(pinged ? 2.2 : 1)
                    .opacity(pinged ? 0 : 0.8)
                Image(systemName: device.systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(device.tint.gradient, in: Circle())
                    .overlay(Circle().strokeBorder(.white.opacity(0.35), lineWidth: 1))
                    .shadow(color: device.tint.opacity(0.5), radius: 10, y: 4)
            }
            .frame(width: 44, height: 44)
            Text(device.name)
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
                .fixedSize()
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(.thinMaterial, in: Capsule())
        }
        .offset(y: 10) // keep the avatar, not the label, on the device's coordinate
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) { pinged = true }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview("Radar Pulse") {
    RadarPulse(devices: [
        .init(name: "Ana's iPhone", systemImage: "iphone", tint: .pink, bearing: .degrees(50), distance: 0.62),
        .init(name: "MacBook Pro", systemImage: "laptopcomputer", tint: .indigo, bearing: .degrees(150), distance: 0.78),
        .init(name: "AirPods", systemImage: "airpods", tint: .teal, bearing: .degrees(235), distance: 0.45),
        .init(name: "iPad", systemImage: "ipad", tint: .orange, bearing: .degrees(310), distance: 0.7),
    ]) {
        Image(systemName: "person.fill")
            .font(.system(size: 28))
            .foregroundStyle(.white)
            .frame(width: 72, height: 72)
            .background(.blue.gradient, in: Circle())
            .shadow(color: .blue.opacity(0.5), radius: 16)
    }
    .padding(30)
}
