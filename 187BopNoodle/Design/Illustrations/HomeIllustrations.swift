import SwiftUI

struct MeadowHeroIllustration: View {
    var height: CGFloat = 160

    var body: some View {
        Canvas { context, size in
            let sky = Path(CGRect(x: 0, y: 0, width: size.width, height: size.height * 0.55))
            context.fill(sky, with: .color(Color("AppBackground")))

            for i in 0..<8 {
                let x = CGFloat(i) * size.width / 7
                var blade = Path()
                blade.move(to: CGPoint(x: x, y: size.height))
                blade.addQuadCurve(
                    to: CGPoint(x: x + 18, y: size.height * 0.45),
                    control: CGPoint(x: x + 8, y: size.height * 0.7)
                )
                blade.addLine(to: CGPoint(x: x + 22, y: size.height))
                blade.closeSubpath()
                context.fill(blade, with: .color(Color("AppSurface").opacity(0.85)))
            }

            for i in 0..<6 {
                let fx = 30 + CGFloat(i) * (size.width - 60) / 5
                let fy = size.height * 0.42 + CGFloat(i % 3) * 12
                let petal = Circle().path(in: CGRect(x: fx, y: fy, width: 10, height: 10))
                context.fill(petal, with: .color(Color("AppAccent").opacity(0.75)))
            }

            let sun = Circle().path(in: CGRect(x: size.width - 56, y: 16, width: 36, height: 36))
            context.fill(sun, with: .color(Color("AppPrimary").opacity(0.5)))
        }
        .frame(height: height)
        .overlay(alignment: .bottomTrailing) {
            GrasshopperShape(size: 56)
                .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppVisualStyle.borderGradient(highlighted: true), lineWidth: 1.5)
        )
        .appSoftShadow(.medium)
    }
}

struct SprintTrailIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("AppPrimary").opacity(0.2))
            Path { path in
                path.move(to: CGPoint(x: 12, y: 44))
                path.addCurve(
                    to: CGPoint(x: 88, y: 20),
                    control1: CGPoint(x: 30, y: 10),
                    control2: CGPoint(x: 60, y: 30)
                )
            }
            .stroke(Color("AppAccent"), style: StrokeStyle(lineWidth: 3, dash: [6, 4]))
            GrasshopperShape(size: 32)
                .offset(x: 24, y: 8)
        }
        .frame(width: 100, height: 64)
    }
}

struct MeadowPathIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("AppSurface").opacity(0.8))
            ForEach(0..<4, id: \.self) { i in
                Capsule()
                    .fill(Color("AppAccent").opacity(0.4))
                    .frame(width: 8, height: 22 + CGFloat(i) * 6)
                    .offset(x: CGFloat(i * 18) - 24, y: 8)
            }
            CollectibleStarShape(size: 16)
                .offset(x: 30, y: -12)
        }
        .frame(width: 100, height: 64)
    }
}

struct GlideArcIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("AppAccent").opacity(0.15))
            Path { path in
                path.move(to: CGPoint(x: 10, y: 50))
                path.addQuadCurve(
                    to: CGPoint(x: 90, y: 18),
                    control: CGPoint(x: 50, y: -8)
                )
            }
            .stroke(Color("AppPrimary"), lineWidth: 2.5)
            GrasshopperShape(size: 28)
                .offset(x: -20, y: 12)
        }
        .frame(width: 100, height: 64)
    }
}
