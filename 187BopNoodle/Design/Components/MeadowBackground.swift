import SwiftUI

struct MeadowBackground: View {
    var body: some View {
        LayeredAppBackground(depth: .standard)
    }
}

/// Scroll screens — static layered background (no repeating Canvas animation).
struct AnimatedPlayBackground: View {
    var body: some View {
        LayeredAppBackground(depth: .standard)
    }
}
