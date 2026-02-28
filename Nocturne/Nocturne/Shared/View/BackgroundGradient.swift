import SwiftUI

struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(
            colors: [NocturneTheme.backgroundTop, NocturneTheme.backgroundBottom],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
