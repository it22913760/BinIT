import SwiftUI
import UIKit

struct ResultView: View {
    var image: UIImage?
    var result: ClassificationResult?
    var onSave: (_ name: String, _ category: ItemCategory, _ confidence: Double, _ imageData: Data) -> Void

    @State private var showBadge = false
    @Environment(\.dismiss) private var dismiss
    @AppStorage("ui.showTopPredictions") private var showTopPredictions = true
    @AppStorage("ui.showHumanBadge") private var showHumanBadge = true
    @AppStorage("debug.showClassifierDebug") private var showClassifierDebug = false
    @State private var topPreds: [(name: String, confidence: Double, category: ItemCategory)] = []
    @State private var selectedOverride: ClassificationResult?
    @State private var showWhy = false
    @State private var showConfetti = false
    @State private var humanDetectedFallback = false

    var body: some View {
        ZStack {
            EcoTheme.offWhite.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                header
                imageCard
                if let res = effectiveResult() { badge(for: res) }
                if showTopPredictions { topChips }
                saveControls
                Spacer()
                }
                .padding(20)
            }
            .overlay(alignment: .top) {
                if showConfetti {
                    ConfettiView()
                        .transition(.opacity)
                        .allowsHitTesting(false)
                }
                if showClassifierDebug {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Debug")
                            .font(.system(.caption, design: .rounded).weight(.heavy))
                        Text("HumanDetected: \(humanDetectedFallback ? "true" : "false")")
                            .font(.system(.caption2, design: .rounded))
                        ForEach(topPreds.indices, id: \.self) { i in
                            let p = topPreds[i]
                            Text("\(i+1). \(p.name) — \(Int(p.confidence * 100))% [\(p.category.rawValue)]")
                                .font(.system(.caption2, design: .rounded))
                        }
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(EcoTheme.border, lineWidth: 1))
                    .padding()
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showBadge = true }
            loadTopPredictions()
            triggerHapticsAndEffects()
            ensureHumanFallback()
        }
        .sheet(isPresented: $showWhy) { whySheet }
    }

    private var header: some View {
        HStack {
            Text(NSLocalizedString("result_title", comment: "Result"))
                .font(.system(.largeTitle, design: .rounded).weight(.heavy))
            Spacer()
            Button {
                showWhy = true
            } label: {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
            }
            .buttonStyle(IconCircleButtonStyle())
            Button(NSLocalizedString("done", comment: "Done")) { dismiss() }
                .buttonStyle(BWNeubrutalistButtonStyle())
        }
    }

    private var imageCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 280)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(EcoTheme.border, lineWidth: 1.5))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 24).fill(EcoTheme.offWhite)
                    Text(NSLocalizedString("no_image", comment: "No Image"))
                        .font(.system(.headline, design: .rounded))
                }
                .frame(height: 280)
            }

            if let res = effectiveResult() {
                Text(res.name)
                    .font(.system(.title3, design: .rounded).weight(.heavy))
                Text("\(NSLocalizedString("confidence", comment: "Confidence")): \(Int(res.confidence * 100))%")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(EcoTheme.yellow)
        .ecoCard()
    }

    private func badge(for res: ClassificationResult) -> some View {
        let color = CategoryTheme.color(for: res.category)
        let text = CategoryTheme.badgeText(for: res.category)

        return VStack(spacing: 8) {
            Text(text)
                .font(.system(.title2, design: .rounded).weight(.heavy))
                .padding(.horizontal, 24).padding(.vertical, 14)
                .background(res.category == .human ? EcoTheme.lavender : Color.white)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(EcoTheme.border, lineWidth: 1.5))
                .foregroundStyle(color)
                .scaleEffect(showBadge ? 1.0 : 0.6)
                .opacity(showBadge ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showBadge)

            if res.category == .human && showHumanBadge {
                Text("Not compostable. Avoid saving.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var topChips: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !topPreds.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(topPreds.enumerated()), id: \.offset) { _, item in
                            Button {
                                selectedOverride = ClassificationResult(name: item.name, category: item.category, confidence: item.confidence)
                            } label: {
                                HStack(spacing: 6) {
                                    Text(CategoryTheme.emoji(for: item.category))
                                    Text(item.name)
                                        .lineLimit(1)
                                    Text("\(Int(item.confidence * 100))%")
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(CategoryTheme.color(for: item.category))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(EcoTheme.border, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func effectiveResult() -> ClassificationResult? {
        if let sel = selectedOverride { return sel }
        return result
    }

    private func loadTopPredictions() {
        guard showTopPredictions, let img = image else { return }
        Task {
            do {
                let clf = ImageClassifier()
                let list = try await clf.topK(image: img, k: 3)
                await MainActor.run { topPreds = list }
            } catch {
                await MainActor.run { topPreds = [] }
            }
        }
    }

    private func ensureHumanFallback() {
        guard let img = image else { return }
        Task {
            let clf = ImageClassifier()
            let detected = await clf.looksHuman(image: img)
            if detected {
                await MainActor.run {
                    humanDetectedFallback = true
                    if let base = result, base.category != .human {
                        selectedOverride = ClassificationResult(name: base.name, category: .human, confidence: base.confidence)
                    } else if result == nil {
                        selectedOverride = ClassificationResult(name: "Human", category: .human, confidence: 1.0)
                    }
                }
            } else {
                await MainActor.run { humanDetectedFallback = false }
            }
        }
    }

    private func triggerHapticsAndEffects() {
        guard let res = effectiveResult() else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        switch res.category {
        case .recyclable:
            generator.notificationOccurred(.success)
            withAnimation(.easeInOut(duration: 0.6)) { showConfetti = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.4)) { showConfetti = false }
            }
        case .compost:
            generator.notificationOccurred(.success)
        case .trash, .human:
            generator.notificationOccurred(.warning)
        }
    }

    private var whySheet: some View {
        let res = effectiveResult()
        let category = res?.category ?? .trash
        return NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(CategoryTheme.whyTitle(for: category))
                    .font(.system(.title3, design: .rounded).weight(.heavy))
                if let res {
                    Text("Item: \(res.name)")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Text("Do's")
                    .font(.system(.headline, design: .rounded).weight(.heavy))
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(CategoryTheme.dos(for: category), id: \.self) { t in
                        HStack(spacing: 8) { Text("•"); Text(t) }
                    }
                }
                Text("Don'ts")
                    .font(.system(.headline, design: .rounded).weight(.heavy))
                    .padding(.top, 8)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(CategoryTheme.donts(for: category), id: \.self) { t in
                        HStack(spacing: 8) { Text("•"); Text(t) }
                    }
                }
                Spacer()
            }
            .padding(20)
            .background(EcoTheme.offWhite)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(NSLocalizedString("done", comment: "Done")) { showWhy = false }
                        .buttonStyle(BWNeubrutalistButtonStyle())
                }
            }
        }
    }

    private var saveControls: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Text(NSLocalizedString("discard", comment: "Discard"))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .buttonStyle(BWNeubrutalistButtonStyle())
            .controlSize(.small)
            .scaleEffect(0.9)
            .frame(maxWidth: .infinity)

            Button {
                guard let res = effectiveResult(), let img = image, let data = img.jpegData(compressionQuality: 0.85) else { return }
                onSave(res.name, res.category, res.confidence, data)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "tray.and.arrow.down.fill")
                    Text(NSLocalizedString("save", comment: "Save"))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .buttonStyle(BWNeubrutalistButtonStyle())
            .controlSize(.small)
            .scaleEffect(0.9)
            .frame(maxWidth: .infinity)

            Button {
                guard let img = image, let data = img.jpegData(compressionQuality: 0.85) else { return }
                let name = result?.name ?? NSLocalizedString("unknown_item", comment: "Unknown")
                onSave(name, .trash, result?.confidence ?? 0, data)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash.fill")
                    Text(NSLocalizedString("mark_trash", comment: "Trash"))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .buttonStyle(DestructiveCapsuleButtonStyle())
            .controlSize(.small)
            .scaleEffect(0.9)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ResultView(image: UIImage(systemName: "leaf")?.withTintColor(.black, renderingMode: .alwaysOriginal),
               result: ClassificationResult(name: "Plastic Bottle", category: .recyclable, confidence: 0.92)) { _, _, _, _ in }
}
