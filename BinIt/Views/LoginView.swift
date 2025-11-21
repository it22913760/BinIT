import SwiftUI

struct LoginView: View {
    var onDone: (() -> Void)? = nil

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSecure: Bool = true
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Welcome back")
                    .font(.system(.title2, design: .rounded).weight(.heavy))
                Text("Login to continue")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "envelope.fill")
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled(true)
                }
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(EcoTheme.border, lineWidth: 2))

                HStack {
                    Image(systemName: "lock.fill")
                    Group {
                        if isSecure {
                            SecureField("Password", text: $password)
                        } else {
                            TextField("Password", text: $password)
                        }
                    }
                    Button(action: { isSecure.toggle() }) {
                        Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    }
                }
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(EcoTheme.border, lineWidth: 2))
            }

            Button(action: submit) {
                HStack(spacing: 10) {
                    if isLoading { ProgressView().tint(.black) }
                    Text("Login")
                }
            }
            .buttonStyle(BWNeubrutalistButtonStyle())
            .disabled(isLoading || email.isEmpty || password.isEmpty)

            Button("Skip for now") {
                onDone?()
            }
            .buttonStyle(CapsuleButtonStyle())

            Spacer()
        }
        .padding(20)
        .background(EcoTheme.offWhite.ignoresSafeArea())
    }

    private func submit() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isLoading = false
            onDone?()
        }
    }
}

#Preview {
    LoginView()
}
