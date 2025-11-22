import Foundation

struct UserProfile: Codable, Equatable, Sendable {
    var name: String
    var primaryEmail: String
    var additionalEmails: [String]
    var profileImageData: Data?
    var username: String? // optional for backward compatibility
    var password: String? // optional for backward compatibility
    var passwordHash: String? // new hashed password storage

    static let empty = UserProfile(name: "", primaryEmail: "", additionalEmails: [], profileImageData: nil, username: nil, password: nil, passwordHash: nil)
}

final class ProfileStore: ObservableObject {
    @Published var profile: UserProfile {
        didSet { save() }
    }

    private let storageKey = "user.profile.store"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = decoded
        } else {
            self.profile = .empty
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
