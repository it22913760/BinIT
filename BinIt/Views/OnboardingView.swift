import SwiftUI

struct OnboardingView: View {
    var onDone: (() -> Void)? = nil

    @State private var page = 0

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Button(NSLocalizedString("skip", comment: "")) {
                    onDone?()
                }
                .buttonStyle(BWNeubrutalistButtonStyle())
            }

            TabView(selection: $page) {
                VStack(spacing: 12) {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 48, weight: .heavy))
                        .foregroundStyle(EcoTheme.green)
                    Text("Welcome to BinIt")
                        .font(.system(.title3, design: .rounded).weight(.heavy))
                    Text("Quickly classify items and learn how to dispose of them responsibly.")
                        .font(.system(.body, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                .padding(16)
                .background(EcoTheme.offWhite)
                .tag(0)

                VStack(spacing: 12) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 48, weight: .heavy))
                    Text("How it works")
                        .font(.system(.title3, design: .rounded).weight(.heavy))
                    VStack(spacing: 8) {
                        Text("1. Scan or pick a photo of an item.")
                        Text("2. We classify it and suggest a category.")
                        Text("3. Save to history for quick access.")
                    }
                    .font(.system(.body, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                }
                .padding(16)
                .background(EcoTheme.offWhite)
                .tag(1)

                VStack(spacing: 12) {
                    Text("Categories")
                        .font(.system(.title3, design: .rounded).weight(.heavy))
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("♻️ Recyclables")
                                .font(.system(.headline, design: .rounded).weight(.heavy))
                            Text("Paper, cardboard, cans, bottles")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("🧴 Plastic")
                                .font(.system(.headline, design: .rounded).weight(.heavy))
                            Text("Containers, bottles, wraps (check local rules)")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("🍎 Organic")
                                .font(.system(.headline, design: .rounded).weight(.heavy))
                            Text("Food scraps, yard waste")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("🧪 Hazardous")
                                .font(.system(.headline, design: .rounded).weight(.heavy))
                            Text("Batteries, e‑waste, chemicals")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("🗑️ General")
                                .font(.system(.headline, design: .rounded).weight(.heavy))
                            Text("Items that can’t be recycled")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(16)
                .background(EcoTheme.offWhite)
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            HStack(spacing: 12) {
                if page > 0 {
                    Button(NSLocalizedString("back", comment: "")) { page -= 1 }
                        .buttonStyle(BWNeubrutalistButtonStyle())
                }

                Spacer()

                if page < 2 {
                    Button(NSLocalizedString("next", comment: "")) { page += 1 }
                        .buttonStyle(BWNeubrutalistButtonStyle())
                } else {
                    Button(NSLocalizedString("done", comment: "")) {
                        onDone?()
                    }
                    .buttonStyle(BWNeubrutalistButtonStyle())
                }
            }
        }
        .padding(20)
        .background(EcoTheme.offWhite.ignoresSafeArea())
    }
}

#Preview {
    OnboardingView()
}
