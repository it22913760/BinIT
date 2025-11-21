import SwiftUI

struct OnboardingView: View {
    var onDone: (() -> Void)? = nil

    @State private var page = 0

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Button(NSLocalizedString("skip", comment: "")) {
                    onDone?()
                }
                .buttonStyle(BWNeubrutalistButtonStyle())
            }

            TabView(selection: $page) {
                Color.clear
                    .background(EcoTheme.offWhite)
                    .tag(0)
                Color.clear
                    .background(EcoTheme.offWhite)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            HStack(spacing: 12) {
                if page > 0 {
                    Button(NSLocalizedString("back", comment: "")) { page -= 1 }
                        .buttonStyle(BWNeubrutalistButtonStyle())
                }

                Spacer()

                if page < 1 {
                    Button(NSLocalizedString("next", comment: "")) { page += 1 }
                        .buttonStyle(BWNeubrutalistButtonStyle())
                } else {
                    Button(NSLocalizedString("done", comment: "")) {
                        onDone?()
                    }
                    .buttonStyle(BWNeubrutalistButtonStyle())
                }
            }
        }
        .padding(20)
        .background(EcoTheme.offWhite.ignoresSafeArea())
    }
}

#Preview {
    OnboardingView()
}
