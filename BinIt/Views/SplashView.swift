import SwiftUI

struct SplashView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            EcoTheme.offWhite.ignoresSafeArea()
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(EcoTheme.border, lineWidth: 3)
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.15), radius: 0, x: 6, y: 6)
                    logoImage()
                        .resizable()
                        .scaledToFit()
                        .frame(width: 112, height: 112)
                        .scaleEffect(animate ? 1.02 : 0.98)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: animate)
                }
                Text("BinIt")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.black)
                    .padding(.top, 8)
            }
        }
        .onAppear { animate = true }
    }

    private func logoImage() -> Image {
        if let ui = UIImage(named: "Artboard 2") ?? UIImage(named: "Artboard 2@4x") {
            return Image(uiImage: ui)
        }
        if let path = Bundle.main.path(forResource: "Artboard 2@4x", ofType: "png")
            ?? Bundle.main.path(forResource: "Artboard 2", ofType: "png")
            ?? Bundle.main.path(forResource: "Artboard 2@4x", ofType: "png", inDirectory: "images")
            ?? Bundle.main.path(forResource: "Artboard 2", ofType: "png", inDirectory: "images") {
            if let ui = UIImage(contentsOfFile: path) { return Image(uiImage: ui) }
        }
        return Image(systemName: "leaf")
    }
}

#Preview {
    SplashView()
}
