import SwiftUI
import PhotosUI
import CryptoKit

struct ProfileView: View {
    @EnvironmentObject var store: ProfileStore
    @Environment(\.dismiss) private var dismiss

    @State private var draftName: String = ""
    @State private var draftPrimaryEmail: String = ""
    @State private var draftUsername: String = ""
    @State private var draftPassword: String = ""
    @State private var isSecurePassword: Bool = true
    @State private var newEmail: String = ""
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var isSaving: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var showSavedToast: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                photoSection
                formSection
                emailsSection
                actionsSection
            }
            .padding(20)
        }
        .background(EcoTheme.offWhite.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadDrafts() }
        .confirmationDialog(
            "Are you sure you want to delete your account? This action cannot be undone.",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete account", role: .destructive) {
                withAnimation { deleteAccount() }
            }
            Button("Cancel", role: .cancel) { showDeleteConfirm = false }
        }
        .overlay(alignment: .top) {
            if showSavedToast {
                Text("Saved")
                    .font(.system(.subheadline, design: .rounded).weight(.heavy))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(EcoTheme.lime)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(EcoTheme.border, lineWidth: 2))
                    .shadow(color: .black, radius: 0, x: 4, y: 4)
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showSavedToast)
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Manage your account")
                .font(.system(.headline, design: .rounded).weight(.heavy))
            Spacer()
            Button("Done") { dismiss() }
                .buttonStyle(BWNeubrutalistButtonStyle())
                .controlSize(.small)
        }
    }

    private var photoSection: some View {
        VStack(spacing: 12) {
            if let data = store.profile.profileImageData, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(EcoTheme.border, lineWidth: 3))
            } else {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .overlay(Circle().stroke(EcoTheme.border, lineWidth: 3))
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 8) {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label("Add photo", systemImage: "photo.on.rectangle")
                }
                .onChange(of: photoItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            store.profile.profileImageData = data
                        }
                    }
                }
                .buttonStyle(BWNeubrutalistButtonStyle())
                .controlSize(.small)

                if store.profile.profileImageData != nil {
                    Button("Remove photo") { store.profile.profileImageData = nil }
                        .buttonStyle(BWNeubrutalistButtonStyle())
                        .controlSize(.small)
                }
            }
        }
    }

    private var formSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "person.fill")
                TextField("Full name", text: $draftName)
                    .textInputAutocapitalization(.words)
                Button(role: .destructive) { draftName = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(IconCircleButtonStyle())
                .controlSize(.mini)
            }
            .padding(10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(EcoTheme.border, lineWidth: 2))

            HStack {
                Image(systemName: "person")
                TextField("Username", text: $draftUsername)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                Button(role: .destructive) { draftUsername = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(IconCircleButtonStyle())
                .controlSize(.mini)
            }
            .padding(10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(EcoTheme.border, lineWidth: 2))

            HStack {
                Image(systemName: "envelope.fill")
                TextField("Primary email", text: $draftPrimaryEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled(true)
            }
            .padding(10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(EcoTheme.border, lineWidth: 2))

            HStack {
                Image(systemName: "lock.fill")
                Group {
                    if isSecurePassword {
                        SecureField("Password", text: $draftPassword)
                    } else {
                        TextField("Password", text: $draftPassword)
                    }
                }
                Button(action: { isSecurePassword.toggle() }) {
                    Image(systemName: isSecurePassword ? "eye.slash.fill" : "eye.fill")
                }
                Button(role: .destructive) { draftPassword = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(IconCircleButtonStyle())
                .controlSize(.mini)
            }
            .padding(10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(EcoTheme.border, lineWidth: 2))

            // Validation messages
            if let userErr = usernameError {
                Text(userErr).font(.caption).foregroundStyle(.red)
            }
            if let passErr = passwordError {
                Text(passErr).font(.caption).foregroundStyle(.red)
            }
            // Masked password status
            if store.profile.passwordHash != nil && draftPassword.isEmpty {
                Text("Password is set (hidden)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button(action: saveProfile) {
                HStack(spacing: 6) {
                    if isSaving { ProgressView().tint(.black) }
                    Text("Save changes")
                }
            }
            .buttonStyle(BWNeubrutalistButtonStyle())
            .disabled(!canSave)
            .controlSize(.small)
        }
    }

    private var emailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Additional emails")
                .font(.system(.subheadline, design: .rounded).weight(.heavy))

            ForEach(Array(store.profile.additionalEmails.enumerated()), id: \.offset) { index, email in
                HStack {
                    Text(email)
                        .font(.system(.callout, design: .rounded))
                    Spacer()
                    Button(role: .destructive) { removeEmail(at: index) } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(BWNeubrutalistButtonStyle())
                    .controlSize(.small)
                }
                .padding(10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(EcoTheme.border, lineWidth: 2))
            }

            HStack {
                Image(systemName: "envelope.badge")
                TextField("Add new email", text: $newEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled(true)
                Button("Add") { addEmail() }
                    .buttonStyle(BWNeubrutalistButtonStyle())
                    .disabled(!isValidEmail(newEmail))
                    .controlSize(.small)
            }
            .padding(10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(EcoTheme.border, lineWidth: 2))
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 8) {
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Text("Delete account")
            }
            .buttonStyle(BWNeubrutalistButtonStyle())
            .controlSize(.small)
        }
        .padding(.top, 8)
    }

    private var canSave: Bool {
        // Allow saving as long as required fields are valid.
        let hasName = !draftName.trimmingCharacters(in: .whitespaces).isEmpty
        // Email can be empty OR valid format.
        let emailOK = draftPrimaryEmail.trimmingCharacters(in: .whitespaces).isEmpty || isValidEmail(draftPrimaryEmail)
        return hasName && emailOK
    }

    private var usernameError: String? {
        if draftUsername.trimmingCharacters(in: .whitespaces).isEmpty { return "Username is required (min 3 chars)" }
        if draftUsername.trimmingCharacters(in: .whitespaces).count < 3 { return "Username must be at least 3 characters" }
        return nil
    }

    private var passwordError: String? {
        if !draftPassword.isEmpty && draftPassword.count < 6 { return "Password must be at least 6 characters" }
        return nil
    }

    private func loadDrafts() {
        draftName = store.profile.name
        draftPrimaryEmail = store.profile.primaryEmail
        draftUsername = store.profile.username ?? ""
        // Migrate plain password to hash if needed
        if let plain = store.profile.password, (store.profile.passwordHash == nil || store.profile.passwordHash?.isEmpty == true) {
            store.profile.passwordHash = sha256(plain)
            store.profile.password = nil
        }
        draftPassword = ""
    }

    private func saveProfile() {
        isSaving = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            store.profile.name = draftName.trimmingCharacters(in: .whitespaces)
            store.profile.primaryEmail = draftPrimaryEmail.trimmingCharacters(in: .whitespaces)
            let trimmedUser = draftUsername.trimmingCharacters(in: .whitespaces)
            store.profile.username = trimmedUser.isEmpty ? nil : trimmedUser
            if !draftPassword.isEmpty {
                store.profile.passwordHash = sha256(draftPassword)
                store.profile.password = nil
            }
            isSaving = false
            withAnimation {
                showSavedToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation {
                    showSavedToast = false
                }
            }
        }
    }

    private func addEmail() {
        let email = newEmail.trimmingCharacters(in: .whitespaces)
        guard isValidEmail(email) else { return }
        if !store.profile.additionalEmails.contains(email) {
            store.profile.additionalEmails.append(email)
        }
        newEmail = ""
    }

    private func removeEmail(at index: Int) {
        guard store.profile.additionalEmails.indices.contains(index) else { return }
        store.profile.additionalEmails.remove(at: index)
    }

    private func deleteAccount() {
        store.profile = .empty
        loadDrafts()
    }

    private func sha256(_ text: String) -> String {
        let data = Data(text.utf8)
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return email.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }
}

// ... (rest of the code remains the same)
#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(ProfileStore())
    }
}
