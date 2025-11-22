import SwiftUI

struct ResultView: View {
    var image: UIImage?
    var result: ClassificationResult?
    var onSave: (_ name: String, _ category: ItemCategory, _ confidence: Double, _ imageData: Data) -> Void

    @State private var showBadge = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            EcoTheme.offWhite.ignoresSafeArea()
            VStack(spacing: 20) {
                header
                imageCard
                if let res = result { badge(for: res) }
                saveControls
                Spacer()
            }
            .padding(20)
        }
        .onAppear { withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showBadge = true } }
    }

    private var header: some View {
        HStack {
            Text(NSLocalizedString("result_title", comment: "Result"))
                .font(.system(.largeTitle, design: .rounded).weight(.heavy))
            Spacer()
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

            if let res = result {
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
        let color: Color
        let text: String
        switch res.category {
        case .recyclable:
            color = EcoTheme.green; text = NSLocalizedString("badge_recycle", comment: "Recycle Me")
        case .compost:
            color = .green; text = NSLocalizedString("badge_compost", comment: "Compostable")
        case .trash:
            color = EcoTheme.red; text = NSLocalizedString("badge_trash", comment: "Trash Can")
        }
        return Text(text)
            .font(.system(.title2, design: .rounded).weight(.heavy))
            .padding(.horizontal, 24).padding(.vertical, 14)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(EcoTheme.border, lineWidth: 1.5))
            .foregroundStyle(color)
            .scaleEffect(showBadge ? 1.0 : 0.6)
            .opacity(showBadge ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showBadge)
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
                guard let res = result, let img = image, let data = img.jpegData(compressionQuality: 0.85) else { return }
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
