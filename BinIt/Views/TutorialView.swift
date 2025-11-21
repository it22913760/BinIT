import SwiftUI

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    var onDone: (() -> Void)? = nil

    @State private var page = 0

    var body: some View {
        VStack(spacing: 16) {
            Text(NSLocalizedString("tutorial_title", comment: ""))
                .font(.system(.title2, design: .rounded).weight(.heavy))

            TabView(selection: $page) {
                tutorialPage(
                    title: NSLocalizedString("tut_scan_title", comment: ""),
                    text: NSLocalizedString("tut_scan_body", comment: ""),
                    symbol: "camera.viewfinder"
                ).tag(0)

                tutorialPage(
                    title: NSLocalizedString("tut_categories_title", comment: ""),
                    text: NSLocalizedString("tut_categories_body", comment: ""),
                    symbol: "tray.full"
                ).tag(1)

                tutorialPage(
                    title: NSLocalizedString("tut_tips_title", comment: ""),
                    text: NSLocalizedString("tut_tips_body", comment: ""),
                    symbol: "lightbulb.fill"
                ).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            HStack(spacing: 12) {
                if page > 0 {
                    Button(NSLocalizedString("back", comment: "")) { page -= 1 }
                        .buttonStyle(BWNeubrutalistButtonStyle())
                }

                Spacer()

                if page < 2 {
                    Button(NSLocalizedString("next", comment: "")) { page += 1 }
                        .buttonStyle(BWNeubrutalistButtonStyle())
                } else {
                    Button(NSLocalizedString("done", comment: "")) {
                        onDone?()
                        dismiss()
                    }
                    .buttonStyle(BWNeubrutalistButtonStyle())
                }
            }
        }
        .padding(20)
        .background(EcoTheme.offWhite)
    }

    private func tutorialPage(title: String, text: String, symbol: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 44, weight: .heavy))
            Text(title)
                .font(.system(.headline, design: .rounded).weight(.heavy))
            Text(text)
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(16)
    }
}

#Preview {
    TutorialView()
}
