import SwiftUI

struct SplashView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            EcoTheme.offWhite.ignoresSafeArea()
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .overlay(Circle().stroke(EcoTheme.border, lineWidth: 3))
                        .shadow(color: .black.opacity(0.15), radius: 0, x: 6, y: 6)
                    Image(systemName: "leaf.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(EcoTheme.green)
                        .scaleEffect(animate ? 1.06 : 0.94)
                        .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: animate)
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
}

#Preview {
    SplashView()
}
