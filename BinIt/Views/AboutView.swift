import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) private var openURL

    private let name = "Hasith Bulathgama"
    private let subtitle = "Undergraduate at SLIIT under Interactive Media • UI/UX Undergraduate"
    private let portfolio = URL(string: "https://hasithbulathgama.framer.website/")!
    private let linkedin = URL(string: "https://www.linkedin.com/in/hasith-bulathgama-71b608354")!
    private let email = "hasithkavinda2001@gmail.com"

    var body: some View {
        VStack(spacing: 20) {
            avatar
            Text(name)
                .font(.system(.title3, design: .rounded).weight(.heavy))
            Text(subtitle)
                .font(.system(.subheadline, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            HStack(spacing: 12) {
                Button("View LinkedIn") { openURL(linkedin) }
                    .buttonStyle(BWNeubrutalistButtonStyle())
                Button("View Portfolio") { openURL(portfolio) }
                    .buttonStyle(BWNeubrutalistButtonStyle())
                Button("Email") {
                    if let url = URL(string: "mailto:\(email)") { openURL(url) }
                }
                .buttonStyle(BWNeubrutalistButtonStyle())
            }
            Spacer()
        }
        .padding(20)
        .background(EcoTheme.offWhite.ignoresSafeArea())
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var avatar: some View {
        Group {
            if let ui = UIImage(named: "avatar") {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(width: 112, height: 112)
        .clipShape(Circle())
        .overlay(Circle().stroke(EcoTheme.border, lineWidth: 3))
        .shadow(color: .black.opacity(0.15), radius: 0, x: 6, y: 6)
    }
}

#Preview {
    NavigationStack { AboutView() }
}
