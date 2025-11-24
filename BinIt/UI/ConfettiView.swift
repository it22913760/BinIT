import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    private let colors: [Color] = [.white, .yellow, .pink, .blue, .green, .orange]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<24, id: \.self) { i in
                    let size = CGFloat(Int.random(in: 6...10))
                    let x = CGFloat.random(in: 0...geo.size.width)
                    let delay = Double.random(in: 0...0.6)
                    let duration = Double.random(in: 0.9...1.6)
                    let color = colors.randomElement() ?? .white
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: size, height: size * 1.6)
                        .position(x: x, y: animate ? geo.size.height + 20 : -20)
                        .rotationEffect(.degrees(animate ? 360 : 0))
                        .opacity(0.9)
                        .animation(
                            .easeInOut(duration: duration)
                                .delay(delay),
                            value: animate
                        )
                }
            }
            .onAppear { animate = true }
        }
        .frame(height: 180)
        .allowsHitTesting(false)
    }
}

#Preview {
    ConfettiView()
        .padding()
}
