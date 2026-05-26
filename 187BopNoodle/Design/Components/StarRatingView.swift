import SwiftUI

struct StarRatingView: View {
    let count: Int
    var max: Int = 3
    var size: CGFloat = 16

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<max, id: \.self) { index in
                Image(systemName: index < count ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(
                        index < count ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.5)
                    )
            }
        }
    }
}

struct AnimatedResultStarsView: View {
    let count: Int
    @State private var visibleCount = 0

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < visibleCount ? "star.fill" : "star")
                    .font(.system(size: 36))
                    .foregroundStyle(Color("AppAccent"))
                    .shadow(color: Color("AppAccent").opacity(index < visibleCount ? 0.8 : 0), radius: 8)
                    .scaleEffect(index < visibleCount ? 1 : 0.5)
                    .opacity(index < visibleCount ? 1 : 0.3)
            }
        }
        .onAppear {
            animateStars()
        }
        .onChange(of: count) { _ in
            visibleCount = 0
            animateStars()
        }
    }

    private func animateStars() {
        for i in 0..<min(count, 3) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    visibleCount = i + 1
                }
            }
        }
    }
}
