import Foundation
import UIKit

@MainActor
final class ScannerViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isClassifying = false
    @Published var result: ClassificationResult?
    @Published var errorMessage: String?

    private let classifier = ImageClassifier()

    func handleCapture(_ image: UIImage?) {
        capturedImage = image
    }

    func classifyIfNeeded() async {
        guard let img = capturedImage, !isClassifying else { return }
        isClassifying = true
        defer { isClassifying = false }
        do {
            let res = try await classifier.classify(image: img)
            self.result = res
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
