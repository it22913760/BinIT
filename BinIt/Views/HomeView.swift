import SwiftUI
import CoreData
import UIKit

struct HomeView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: RecycledItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \RecycledItem.timestamp, ascending: false)],
        animation: .default
    ) private var items: FetchedResults<RecycledItem>
    @State private var showScanner = false
    @State private var showSettings = false
    @State private var showTutorial = false
    @AppStorage("tutorial.seen") private var tutorialSeen = false
    @AppStorage("scanner.usePhotoLibrary") private var usePhotoLibrary = !UIImagePickerController.isSourceTypeAvailable(.camera)

    // Define settings sheet view before body to ensure scope visibility
    private var settingsSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(NSLocalizedString("settings_title", comment: "Settings"))
                .font(.system(.title3, design: .rounded).weight(.heavy))
            HStack(spacing: 12) {
                Text(NSLocalizedString("scanner_source", comment: "Scanner Source"))
                    .font(.system(.subheadline, design: .rounded).weight(.heavy))
                Spacer()
                Picker(NSLocalizedString("source", comment: "Source"), selection: $usePhotoLibrary) {
                    Text(NSLocalizedString("source_camera", comment: "Camera")).tag(false)
                    Text(NSLocalizedString("source_photos", comment: "Photos")).tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
            Button(NSLocalizedString("view_tutorial", comment: "View Tutorial")) {
                showTutorial = true
            }
            .buttonStyle(BWNeubrutalistButtonStyle())
            Text(NSLocalizedString("sim_tip", comment: "Simulator tip"))
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(20)
        .background(EcoTheme.offWhite)
    }

    var body: some View {
        ZStack {
            EcoTheme.offWhite.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    statsScroll
                    recentGrid
                    Spacer(minLength: 16)
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 100) }
        }
        .overlay(alignment: .bottom) {
            fabButton
        }
        .navigationTitle(NSLocalizedString("app_title", comment: "App title"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showTutorial = true
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Help"))
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack { settingsSheet }
                .presentationDetents([.height(220)])
        }
        .sheet(isPresented: $showTutorial) {
            NavigationStack {
                TutorialView {
                    tutorialSeen = true
                    showTutorial = false
                }
            }
            .presentationDetents([.medium, .large])
        }
        .onAppear {
            if !tutorialSeen { showTutorial = true }
        }
    }

    

    private var header: some View {
        Text(NSLocalizedString("app_title", comment: "App title"))
            .font(.system(size: 40, weight: .heavy, design: .rounded))
            .kerning(-0.5)
    }

    private var statsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                statCard(title: NSLocalizedString("items_saved", comment: "Items Saved"), value: "\(items.count)", color: EcoTheme.yellow)
                statCard(title: NSLocalizedString("co2_saved", comment: "CO2 Saved"), value: String(format: "%.1f kg", co2Saved()), color: EcoTheme.blue)
                statCard(title: NSLocalizedString("top_category", comment: "Top Category"), value: topCategoryRecent(), color: EcoTheme.green)
                statCard(title: NSLocalizedString("category_diversity", comment: "Category Diversity"), value: categoryDiversityText(), color: EcoTheme.lavender)
            }
        }
    }

    private func statCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.subheadline, design: .rounded).weight(.heavy))
            Text(value)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
        }
        .padding(16)
        .frame(width: 180, height: 100, alignment: .leading)
        .background(color)
        .ecoCard()
    }

    private var recentGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("recent", comment: "Recent"))
                .font(.system(.title3, design: .rounded).weight(.heavy))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Array(items.prefix(10))) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        if let data = item.imageData, let ui = UIImage(data: data) {
                            Image(uiImage: ui)
                                .resizable()
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fill)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(EcoTheme.border, lineWidth: 1))
                        }
                        Text(item.name ?? "")
                            .font(.system(.headline, design: .rounded).weight(.heavy))
                            .lineLimit(1)
                        Text("\(item.itemCategory.rawValue.capitalized) • \(Int((item.confidence) * 100))%")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(EcoTheme.pink)
                    .ecoCard()
                }
            }
        }
    }

    private var fabButton: some View {
        Button {
            withAnimation(.spring()) { showScanner = true }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(.black)
                Text(NSLocalizedString("scan", comment: "Scan"))
                    .font(.system(.headline, design: .rounded).weight(.heavy))
                    .foregroundColor(.black)
            }
        }
        .buttonStyle(BWNeubrutalistButtonStyle())
        .padding(.bottom, 24)
        .fullScreenCover(isPresented: $showScanner) {
            NavigationStack { ScannerView() }
                .tint(.black)
        }
    }

    private func co2Saved() -> Double {
        // Simple heuristic: each correctly recycled item saves ~0.15kg CO2 eq.
        max(0.0, Double(items.count) * 0.15)
    }

    private func topCategoryRecent(limit: Int = 10) -> String {
        let recent = Array(items.prefix(limit))
        guard !recent.isEmpty else { return "—" }
        let counts = Dictionary(grouping: recent, by: { $0.itemCategory })
            .mapValues { $0.count }
        if let top = counts.max(by: { $0.value < $1.value })?.key {
            return categoryDisplayName(top)
        }
        return "—"
    }

    private func categoryDiversityText() -> String {
        let totalCategories = ItemCategory.allCases.count
        let distinct = Set(items.map { $0.itemCategory }).count
        return "\(distinct) of \(totalCategories)"
    }

    private func categoryDisplayName(_ category: ItemCategory) -> String {
        switch category {
        case .recyclable: return "♻️ " + category.rawValue.capitalized
        case .compost: return "🌿 " + category.rawValue.capitalized
        case .trash: return "🗑️ " + category.rawValue.capitalized
        }
    }
}

#Preview {
    NavigationStack { HomeView() }
        .preferredColorScheme(.light)
}
