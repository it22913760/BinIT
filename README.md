# BinIt – Smart Waste Sorting iOS App

BinIt is an iOS app that helps users classify items into Recyclable, Compost, Trash, or Human (not a waste item) categories, track activity, and learn proper disposal. Built with SwiftUI and Core Data, it focuses on a fun neubrutalist design and simple, private on‑device persistence.

## Features
- **Image classification (MobileNetV2)**: CoreML + Vision pipeline classifies items and shows confidence and mapped sustainability category.
- **Recent items**: Recent grid with images, category, and confidence.
- **Stats**: Simple stats for items and estimated CO2 saved.
- **Tutorial & Onboarding**: In‑app guides for new users.
- **Profile**: Login, edit profile, manage additional emails, and add a profile photo.
- **About**: Developer bio, skills, and quick links.
- **Design system**: Consistent neubrutalist components and theme.

## Tech stack
- **Language/Framework**: Swift 5, SwiftUI
- **Minimum iOS**: 16.0 (no iOS 17‑only APIs required)
- **Data**: Core Data (SQLite store) for recent items, `UserDefaults` for profile
- **Media**: `PhotosUI` for profile photo picker
- **Crypto**: `CryptoKit` for password hashing (SHA‑256)
 - **ML**: CoreML + Vision using the MobileNetV2 model (`MobileNetV2.mlmodelc`)

## App architecture
- **SwiftUI Views**: Composable views with a shared `ProfileStore` environment object
- **Persistence**:
  - Core Data via `CoreDataStack` for `RecycledItem`
  - `UserDefaults` JSON for `UserProfile` via `ProfileStore`
- **Theming**: `EcoTheme` + custom button styles

### Key modules
- `Views/` – Home, Result, Scanner, Profile, Login, About, Tutorial, Onboarding
- `Models/UserProfile.swift` – Codable profile model and `ProfileStore` (UserDefaults persistence)
- `Services/CoreDataStack.swift` – Programmatic Core Data model + optional compiled model
- `Services/ImageClassifier.swift` – Classification service and helpers
- `UI/Theme.swift` – Theme colors, reusable button styles, card modifier

## Data model
### Core Data: RecycledItem
- `id: UUID`
- `name: String`
- `category: String` ("recyclable", "compost", "trash", "human")
- `confidence: Double`
- `timestamp: Date`
- `imageData: Data` (external binary storage enabled)

### Profile: UserProfile (UserDefaults)
- `name: String`
- `primaryEmail: String`
- `additionalEmails: [String]`
- `profileImageData: Data?`
- `username: String?`
- `passwordHash: String?` (SHA‑256)
- `password: String?` is used only for backward compatibility and not persisted after hashing

## Privacy & security
- Profile data is stored locally in `UserDefaults` (JSON‑encoded) under the key `user.profile.store`.
- Passwords are never stored in plaintext; only a SHA‑256 hash is saved.
- Recent item images are stored locally in Core Data (external binary storage).

## Setup & build
1. Open `BinIt.xcodeproj` in Xcode 15 (or newer).
2. Select a simulator or a connected device (iOS 16+).
3. Build & run.

### Assets
- App icon assets in `Assets.xcassets/AppIcon.appiconset`
- Profile avatar:
  - Add an image set named `profile_photo` in `Assets.xcassets` or place `profile_photo.(png|jpg|jpeg)` in the main bundle (optionally under `images/`).
  - The About page automatically loads: `profile_photo` → `avatar` → `profile` → bundle file → fallback SF Symbol.

## How to view saved data
- **Core Data (Recycled items)**
  1. Xcode → Window → Devices and Simulators → select simulator → your app.
  2. Gear icon → Download Container…
  3. Open `AppData/Library/Application Support/BinItModel.sqlite` with a SQLite viewer.
- **Profile (UserDefaults)**
  - In the same app container: `AppData/Library/Preferences/<bundle-id>.plist` → key `user.profile.store` (JSON).

## Usage guide
- **Scan/Add Items**: Use the camera button (FAB) on Home to add items.
- **View Results**: See category and confidence; learn why a category was chosen.
- **Profile**: Login to set email/password; edit name, username, additional emails, and profile photo.
- **About**: See developer bio, links, and skills.

## Accessibility & localization
- Uses SF Symbols and semantic fonts.
- Localized strings for common UI (e.g., settings labels) with `NSLocalizedString`.

## Known limitations / roadmap
- The classifier is a simple heuristic/service example; improve with a proper on‑device ML model.
- Add Keychain storage for credentials instead of UserDefaults.
- Extend localization coverage and add dynamic type audits.
- Add unit/UI tests.

## Project scripts & configuration
- No custom build scripts required.
- Core Data model is loaded from `BinItModel.momd` if present; otherwise a programmatic model is used.

## Contributing
- Open issues and PRs are welcome. Please describe changes clearly and include screenshots for UI updates.

## License
- MIT License. See `LICENSE` for full text. © 2025 Hasith Bulathgama.

## Contact
- Author: Hasith Bulathgama
- Portfolio: https://hasithbulathgama.framer.website/
- LinkedIn: https://www.linkedin.com/in/hasith-bulathgama-71b608354
- Email: hasithkavinda2001@gmail.com
