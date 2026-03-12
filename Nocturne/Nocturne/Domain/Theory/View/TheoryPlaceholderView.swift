import SwiftUI

struct TheoryPlaceholderView: View {
    var body: some View {
        ZStack {
            BackgroundGradient()
            Text("Theory")
                .font(.largeTitle)
                .foregroundStyle(NocturneTheme.textPrimary)
        }
    }
}
