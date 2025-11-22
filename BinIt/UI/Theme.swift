import SwiftUI

struct EcoTheme {
    // Neubrutalism palette
    static let offWhite = Color(red: 0.98, green: 0.98, blue: 0.98) // #F9F9F9
    static let yellow = Color(red: 0.97, green: 0.84, blue: 0.39)   // #F8D664
    static let pink = Color(red: 0.95, green: 0.77, blue: 0.85)     // #F3C4D8
    static let blue = Color(red: 0.54, green: 0.81, blue: 0.94)     // #89CFF0
    static let green = Color(red: 0.27, green: 0.75, blue: 0.43)
    static let lime = Color(red: 0.74, green: 0.90, blue: 0.45)     // fresh lime green
    static let red = Color(red: 0.95, green: 0.27, blue: 0.27)
    static let lavender = Color(red: 0.80, green: 0.72, blue: 0.95)  // approx neubrutalist lavender

    static let border = Color.black.opacity(0.8)

    struct Card: ViewModifier {
        func body(content: Content) -> some View {
            content
                .background(EcoTheme.offWhite)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(EcoTheme.border, lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.15), radius: 0, x: 4, y: 4)
        }
    }
}

struct IconCircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.primary)
            .frame(width: 34, height: 34)
            .background(
                ZStack {
                    Circle().fill(Color(.systemBackground))
                    Circle().strokeBorder(Color.primary, lineWidth: 3)
                }
                .compositingGroup()
                .shadow(color: Color.primary, radius: 0, x: 3, y: 3)
            )
            .contentShape(Circle())
            .scaleEffect(configuration.isPressed ? 1.03 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: configuration.isPressed)
    }
}

extension View {
    func ecoCard() -> some View { modifier(EcoTheme.Card()) }
}

struct BWNeubrutalistButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded).weight(.heavy))
            .foregroundColor(.primary)
            .padding(.vertical, 14)
            .padding(.horizontal, 28)
            .background(
                ZStack {
                    Capsule().fill(Color(.systemBackground))
                    Capsule().strokeBorder(Color.primary, lineWidth: 3)
                }
                .compositingGroup()
                .shadow(color: Color.primary, radius: 0, x: 6, y: 6)
            )
            .contentShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.02 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: configuration.isPressed)
    }
}

 

struct CapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .rounded).weight(.semibold))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.black, lineWidth: 3))
            .shadow(color: .black, radius: 0, x: 6, y: 6)
            .foregroundColor(.black)
            .scaleEffect(configuration.isPressed ? 1.04 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct DestructiveCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded).weight(.heavy))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    Capsule().fill(Color.white)
                    Capsule().strokeBorder(Color.black, lineWidth: 3)
                }
                .compositingGroup()
                .shadow(color: .black, radius: 0, x: 6, y: 6)
            )
            .contentShape(Capsule())
            .foregroundStyle(EcoTheme.red)
            .scaleEffect(configuration.isPressed ? 1.02 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: configuration.isPressed)
    }
}

struct LavenderPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded).weight(.heavy))
            .foregroundColor(.black)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(EcoTheme.lavender)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.black, lineWidth: 3))
            .shadow(color: .black, radius: 0, x: 8, y: 8)
            .scaleEffect(configuration.isPressed ? 1.03 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct YellowPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded).weight(.heavy))
            .foregroundColor(.black)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(EcoTheme.yellow)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.black, lineWidth: 3))
            .shadow(color: .black, radius: 0, x: 8, y: 8)
            .scaleEffect(configuration.isPressed ? 1.03 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}
