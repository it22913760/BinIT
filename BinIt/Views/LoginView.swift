import SwiftUI
import CryptoKit

struct LoginView: View {
    @EnvironmentObject var store: ProfileStore
    @AppStorage("nav.showProfileAfterLogin") private var showProfileAfterLogin = false
    @AppStorage("auth.loggedIn") private var loggedIn = false
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

            HStack(spacing: 8) {
                Button(action: submit) {
                    HStack(spacing: 6) {
                        if isLoading { ProgressView().tint(.black) }
                        Text("Login")
                    }
                }
                .buttonStyle(BWNeubrutalistButtonStyle())
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                .controlSize(.small)

                Button("Skip now") {
                    // Skip: just dismiss login and go to Home. Do not set navigation flags.
                    showProfileAfterLogin = false
                    store.transientPlainPassword = nil
                    UserDefaults.standard.set(true, forKey: "auth.skipLogin")
                    onDone?()
                }
                .buttonStyle(BWNeubrutalistButtonStyle())
                .controlSize(.small)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(EcoTheme.offWhite.ignoresSafeArea())
    }

    private func submit() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isLoading = false
            let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
            if !trimmedEmail.isEmpty {
                store.profile.primaryEmail = trimmedEmail
                let userFromEmail = trimmedEmail.split(separator: "@").first.map(String.init) ?? ""
                if (store.profile.username ?? "").isEmpty {
                    store.profile.username = userFromEmail.isEmpty ? store.profile.username : userFromEmail
                }
            }
            if !password.isEmpty {
                store.profile.passwordHash = sha256(password)
                store.profile.password = nil
                // keep a transient copy (not persisted) so Profile can reveal after confirmation
                store.transientPlainPassword = password
            }
            // Do not navigate to Profile after login; go to Home
            showProfileAfterLogin = false
            // mark user as logged in so tapping Profile shows full profile
            loggedIn = true
            onDone?()
        }
    }

    private func sha256(_ text: String) -> String {
        let data = Data(text.utf8)
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}

#Preview {
    LoginView()
}
