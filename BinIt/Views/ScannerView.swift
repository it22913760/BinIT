import SwiftUI
import SwiftData
import UIKit

struct ScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = ScannerViewModel()
    @Environment(\.modelContext) private var modelContext

    @State private var showCamera = false
    @State private var navigateToResult = false
    @AppStorage("scanner.usePhotoLibrary") private var usePhotoLibrary = !UIImagePickerController.isSourceTypeAvailable(.camera)
    @State private var showSavedToast = false

    var body: some View {
        ZStack {
            EcoTheme.blue.ignoresSafeArea()

            VStack(spacing: 16) {
                header
                if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Text(NSLocalizedString("simulator_fallback", comment: "Simulator fallback"))
                        .font(.system(.caption, design: .rounded))
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(EcoTheme.border, lineWidth: 1.5))
                }
                sourceToggle
                cameraCard
                Spacer()
                controls
            }
            .padding(20)

            // Saved toast overlay
            if showSavedToast {
                Text("Saved ✔︎")
                    .font(.system(.subheadline, design: .rounded).weight(.heavy))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(EcoTheme.border, lineWidth: 1.5))
                    .shadow(color: .black, radius: 0, x: 6, y: 6)
                    .transition(.scale)
            }
        }
        .onAppear { withAnimation(.spring()) { showCamera = true } }
        .sheet(isPresented: $showCamera) {
            CameraPicker(
                allowsEditing: false,
                preferredSource: usePhotoLibrary ? .photoLibrary : .camera
            ) { image in
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                vm.handleCapture(image)
                Task {
                    await vm.classifyIfNeeded()
                    if vm.result != nil {
                        let success = UINotificationFeedbackGenerator()
                        success.notificationOccurred(.success)
                    } else if vm.errorMessage != nil {
                        let errorGen = UINotificationFeedbackGenerator()
                        errorGen.notificationOccurred(.error)
                    }
                    navigateToResult = vm.result != nil || vm.errorMessage != nil
                }
            }
            .ignoresSafeArea()
        }
        .navigationDestination(isPresented: $navigateToResult) {
            ResultView(image: vm.capturedImage, result: vm.result) { item in
                // Save tapped using the provided item
                Task {
                    try? await DataManager.shared.save(item, in: modelContext)
                    withAnimation(.spring()) { showSavedToast = true }
                    // Short delay to show toast, then dismiss
                    try? await Task.sleep(nanoseconds: 800_000_000)
                    dismiss()
                }
            }
        }
    }

    private var sourceToggle: some View {
        HStack(spacing: 12) {
            Text(NSLocalizedString("source", comment: "Source"))
                .font(.system(.subheadline, design: .rounded).weight(.heavy))
            Picker("Source", selection: $usePhotoLibrary) {
                Text(NSLocalizedString("source_camera", comment: "Camera")).tag(false)
                Text(NSLocalizedString("source_photos", comment: "Photos")).tag(true)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 240)
        }
    }

    private var header: some View {
        HStack {
            Text(NSLocalizedString("scanner_title", comment: "Scanner"))
                .font(.system(.largeTitle, design: .rounded).weight(.heavy))
            Spacer()
            Button(NSLocalizedString("close", comment: "Close")) { dismiss() }
                .buttonStyle(BWNeubrutalistButtonStyle())
        }
    }

    private var cameraCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(EcoTheme.offWhite)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(EcoTheme.border, lineWidth: 1.5))
                .shadow(color: .black.opacity(0.15), radius: 0, x: 6, y: 6)
                .frame(height: 360)

            ScanningFrame()
                .padding(32)
        }
        .animation(.spring(), value: vm.capturedImage)
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button {
                showCamera = true
            } label: {
                Label(NSLocalizedString("capture", comment: "Capture"), systemImage: "camera.fill")
            }
            .buttonStyle(BWNeubrutalistButtonStyle())

            if vm.isClassifying {
                ProgressView().progressViewStyle(.circular)
            }
        }
    }
}

private struct ScanningFrame: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(EcoTheme.border, lineWidth: 2)
                    .background(Color.clear)

                Rectangle()
                    .fill(Color.green.opacity(0.8))
                    .frame(height: 3)
                    .offset(y: phase * (geo.size.height - 3))
                    .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: phase)
            }
        }
        .onAppear { phase = 1 }
    }
}

#Preview {
    NavigationStack { ScannerView() }
}
