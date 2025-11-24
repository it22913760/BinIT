import SwiftUI
import UIKit

struct AboutView: View {
    @Environment(\.openURL) private var openURL

    private let name = "Hasith Bulathgama"
    private let subtitle = "Undergraduate at SLIIT under Interactive Media • UI/UX Undergraduate"
    private let portfolio = URL(string: "https://hasithbulathgama.framer.website/")!
    private let linkedin = URL(string: "https://www.linkedin.com/in/hasith-bulathgama-71b608354")!
    private let email = "hasithkavinda2001@gmail.com"
    private let skills: [String] = [
        "3D Modeling", "Animation", "AR/VR", "XR", "Interaction Design", "UI/UX", "Game Design",
        "Blender", "Maya", "Unreal Engine", "Unity", "Swift (iOS AR)", "MERN", "Python", "Kotlin", "C++",
        "MySQL", "MongoDB"
    ]
    private let bio = """
    I am an aspiring Creative Technologist and Interactive Media specialist with a strong mix of technical development and visual design. I work across 3D modeling, animation, AR/VR development, UI/UX, and game design, creating immersive and interactive digital experiences. My skill set spans Blender, Maya, Unreal Engine, Unity, Swift (iOS AR), MERN stack, Python, Kotlin, C++, and database technologies such as MySQL and MongoDB.

    I enjoy building VR interactions, developing AR applications, designing minimalist user interfaces, creating motion graphics, and producing engaging visual content. My experience includes mixed reality education concepts, VR prototypes, product design ideas, event poster design, and multimedia projects. I combine creativity with technical problem-solving to craft meaningful digital experiences.

    I am passionate about XR, immersive storytelling, interaction design, and innovative interfaces—and I am continuously working on expanding my skills to contribute to the future of creative technology.
    """
    @State private var pulse = false
    @State private var showCopied = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                avatar
                Text(name)
                    .font(.system(.title3, design: .rounded).weight(.heavy))
                Text(subtitle)
                    .font(.system(.subheadline, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                Text(bio)
                    .font(.system(.body, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                // Microdetails chips
                HStack(spacing: 8) {
                    chip(text: "📍 Colombo, Sri Lanka", color: EcoTheme.blue)
                    chip(text: "Available for internships", color: EcoTheme.lime)
                }
                .fixedSize(horizontal: false, vertical: true)
                // Skills chips for visual interest
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(skills, id: \.self) { tag in
                            Text(tag)
                                .font(.system(.footnote, design: .rounded).weight(.heavy))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(EcoTheme.lavender)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(EcoTheme.border, lineWidth: 1))
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(.vertical, 12)
                // Links section
                sectionHeader("Links")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button {
                            openURL(linkedin)
                        } label: {
                            HStack(spacing: 8) { Image(systemName: "link.circle.fill"); Text("LinkedIn") }
                        }
                        .buttonStyle(BWNeubrutalistButtonStyle())
                        Button {
                            openURL(portfolio)
                        } label: {
                            HStack(spacing: 8) { Image(systemName: "globe"); Text("Portfolio") }
                        }
                        .buttonStyle(BWNeubrutalistButtonStyle())
                        Button {
                            if let url = URL(string: "mailto:\(email)") { openURL(url) }
                        } label: {
                            HStack(spacing: 8) { Image(systemName: "envelope.fill"); Text("Email") }
                        }
                        .buttonStyle(BWNeubrutalistButtonStyle())
                    }
                    .padding(.vertical, 8)
                }
                .padding(.vertical, 12)
                // Vertical button stack under the horizontal row
                sectionHeader("Contact")
                VStack(spacing: 12) {
                    Button {
                        UIPasteboard.general.string = email
                        withAnimation(.easeInOut(duration: 0.2)) { showCopied = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation(.easeOut(duration: 0.3)) { showCopied = false }
                        }
                    } label: {
                        HStack(spacing: 8) { Image(systemName: "doc.on.doc.fill"); Text("Copy Email") }
                    }
                    .buttonStyle(BWNeubrutalistButtonStyle())
                    .frame(maxWidth: .infinity)

                    Button {
                        openURL(linkedin)
                    } label: {
                        HStack(spacing: 8) { Image(systemName: "link.circle.fill"); Text("Open LinkedIn") }
                    }
                    .buttonStyle(BWNeubrutalistButtonStyle())
                    .frame(maxWidth: .infinity)

                    Button {
                        openURL(portfolio)
                    } label: {
                        HStack(spacing: 8) { Image(systemName: "globe"); Text("Open Portfolio") }
                    }
                    .buttonStyle(BWNeubrutalistButtonStyle())
                    .frame(maxWidth: .infinity)
                }
                Spacer(minLength: 8)
            }
            .padding(20)
        }
        .scrollIndicators(.hidden)
        .background(EcoTheme.offWhite.ignoresSafeArea())
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
        .overlay(alignment: .bottom) {
            if showCopied {
                Text("Copied!")
                    .font(.system(.subheadline, design: .rounded).weight(.heavy))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(EcoTheme.border, lineWidth: 1.5))
                    .shadow(color: .black.opacity(0.15), radius: 0, x: 4, y: 4)
                    .padding(.bottom, 24)
                    .transition(.opacity)
            }
        }
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .strokeBorder(AngularGradient(gradient: Gradient(colors: [.pink, .yellow, .green, .blue, .pink]), center: .center), lineWidth: 6)
                .frame(width: 124, height: 124)
                .opacity(0.9)
                .scaleEffect(pulse ? 1.03 : 0.97)
            profileImage()
                .resizable()
                .scaledToFill()
            .frame(width: 112, height: 112)
            .clipShape(Circle())
            .overlay(Circle().stroke(EcoTheme.border, lineWidth: 3))
        }
        .shadow(color: .black.opacity(0.15), radius: 0, x: 6, y: 6)
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(.subheadline, design: .rounded).weight(.heavy))
            Spacer()
        }
        .padding(.top, 6)
    }

    private func chip(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(.footnote, design: .rounded).weight(.heavy))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(EcoTheme.border, lineWidth: 1))
    }

    private func profileImage() -> Image {
        // Try common asset names first
        if let ui = UIImage(named: "profile_photo")
            ?? UIImage(named: "avatar")
            ?? UIImage(named: "profile") {
            return Image(uiImage: ui)
        }

        // Try common file types and @2x/@3x variants in main bundle and an optional "images" folder
        let candidates = ["profile_photo", "avatar", "profile"]
        let exts = ["png", "jpg", "jpeg"]
        let suffixes = ["", "@2x", "@3x"]

        for name in candidates {
            for suf in suffixes {
                for ext in exts {
                    if let path = Bundle.main.path(forResource: name + suf, ofType: ext)
                        ?? Bundle.main.path(forResource: name + suf, ofType: ext, inDirectory: "images") {
                        if let ui = UIImage(contentsOfFile: path) {
                            return Image(uiImage: ui)
                        }
                    }
                }
            }
        }

        // Fallback system image
        return Image(systemName: "person.circle.fill")
    }
}

#Preview {
    NavigationStack { AboutView() }
}
