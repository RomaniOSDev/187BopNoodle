import SwiftUI

struct GrasshopperShape: View {
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color("AppAccent"))
                .frame(width: size * 0.7, height: size * 0.35)
                .offset(y: size * 0.1)
            Circle()
                .fill(Color("AppPrimary"))
                .frame(width: size * 0.35, height: size * 0.35)
                .offset(x: size * 0.25, y: -size * 0.15)
            Capsule()
                .fill(Color("AppAccent"))
                .frame(width: size * 0.15, height: size * 0.5)
                .rotationEffect(.degrees(-30))
                .offset(x: -size * 0.2, y: size * 0.05)
            Capsule()
                .fill(Color("AppAccent"))
                .frame(width: size * 0.15, height: size * 0.5)
                .rotationEffect(.degrees(30))
                .offset(x: size * 0.05, y: size * 0.05)
            Circle()
                .fill(Color("AppTextPrimary"))
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(x: size * 0.32, y: -size * 0.18)
        }
        .frame(width: size, height: size)
    }
}

struct CollectibleStarShape: View {
    var size: CGFloat = 24
    @State private var glow = false

    var body: some View {
        Image(systemName: "star.fill")
            .font(.system(size: size))
            .foregroundStyle(Color("AppAccent"))
            .shadow(color: Color("AppAccent").opacity(glow ? 0.9 : 0.3), radius: glow ? 6 : 2)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    glow = true
                }
            }
    }
}
