import SwiftUI

/// Lightweight shared gradients and depth styling (no Color extensions).
enum AppVisualStyle {
    static var screenGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppBackground"),
                Color("AppSurface").opacity(0.92),
                Color("AppBackground")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var surfaceGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface").opacity(0.98),
                Color("AppSurface"),
                Color("AppBackground").opacity(0.55)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent")],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var glossGradient: LinearGradient {
        LinearGradient(
            colors: [Color("AppTextPrimary").opacity(0.14), Color.clear],
            startPoint: .top,
            endPoint: .center
        )
    }

    static func borderGradient(highlighted: Bool) -> LinearGradient {
        LinearGradient(
            colors: highlighted
                ? [Color("AppAccent").opacity(0.9), Color("AppPrimary").opacity(0.5)]
                : [Color("AppPrimary").opacity(0.35), Color("AppAccent").opacity(0.15)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

enum AppShadowLevel {
    case low
    case medium
    case high

    var radius: CGFloat {
        switch self {
        case .low: return 6
        case .medium: return 9
        case .high: return 12
        }
    }

    var y: CGFloat {
        switch self {
        case .low: return 3
        case .medium: return 5
        case .high: return 7
        }
    }

    var opacity: Double {
        switch self {
        case .low: return 0.32
        case .medium: return 0.42
        case .high: return 0.52
        }
    }
}

extension View {
    func appSoftShadow(_ level: AppShadowLevel = .medium) -> some View {
        shadow(
            color: Color("AppBackground").opacity(level.opacity),
            radius: level.radius,
            x: 0,
            y: level.y
        )
    }
}

struct LayeredAppBackground: View {
    enum Depth {
        case standard
        case minimal
    }

    var depth: Depth = .standard

    var body: some View {
        ZStack {
            AppVisualStyle.screenGradient

            if depth == .standard {
                ambientOrbs
                MeadowDecorLayer()
            }
        }
        .ignoresSafeArea()
    }

    private var ambientOrbs: some View {
        ZStack {
            Circle()
                .fill(Color("AppPrimary").opacity(0.18))
                .frame(width: 220, height: 220)
                .offset(x: -120, y: -200)
            Circle()
                .fill(Color("AppAccent").opacity(0.12))
                .frame(width: 180, height: 180)
                .offset(x: 140, y: 120)
        }
        .allowsHitTesting(false)
    }
}

/// Static decor — drawn once, no animation (scroll-friendly).
struct MeadowDecorLayer: View {
    var body: some View {
        Canvas { context, size in
            let blades = 6
            for i in 0..<blades {
                let x = CGFloat(i) / CGFloat(blades - 1) * size.width
                var path = Path()
                path.move(to: CGPoint(x: x, y: size.height))
                path.addQuadCurve(
                    to: CGPoint(x: x + 24, y: size.height * 0.62),
                    control: CGPoint(x: x + 10, y: size.height * 0.82)
                )
                path.addLine(to: CGPoint(x: x + 24, y: size.height))
                path.closeSubpath()
                context.fill(path, with: .color(Color("AppSurface").opacity(0.45)))
            }
            for i in 0..<4 {
                let fx = 24 + CGFloat(i) * (size.width - 48) / 3
                let fy = size.height * 0.34 + CGFloat(i % 2) * 28
                let rect = CGRect(x: fx, y: fy, width: 7, height: 7)
                context.fill(Circle().path(in: rect), with: .color(Color("AppAccent").opacity(0.3)))
            }
        }
        .opacity(0.55)
        .allowsHitTesting(false)
    }
}

/// Game screens: gradient only — keeps 60 FPS stable.
struct GameMeadowBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color("AppBackground"),
                Color("AppSurface").opacity(0.85),
                Color("AppBackground")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
