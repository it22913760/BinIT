import Foundation
import UIKit
import Vision
import CoreML

/// A CoreML + Vision powered image classifier using MobileNetV2.
public final class ImageClassifier {
    private let vnModel: VNCoreMLModel
    private let inputSize = CGSize(width: 224, height: 224)

    public init() {
        // Load compiled model from bundle to avoid build-time dependency on generated class names.
        do {
            let config = MLModelConfiguration()
            guard let url = Bundle.main.url(forResource: "MobileNetV2", withExtension: "mlmodelc") else {
                fatalError("MobileNetV2.mlmodelc not found in app bundle. Ensure the .mlmodel is added to the project and built.")
            }
            let coreMLModel = try MLModel(contentsOf: url, configuration: config)
            self.vnModel = try VNCoreMLModel(for: coreMLModel)
        } catch {
            fatalError("Failed to load MobileNetV2 model: \(error)")
        }
    }

    /// Classifies a UIImage using MobileNetV2 through the Vision framework.
    /// - Parameter image: The image to classify.
    /// - Returns: A `ClassificationResult` with the best prediction mapped to an `ItemCategory`.
    /// - Throws: Errors from Vision/CoreML if the request fails.
    public func classify(image: UIImage) async throws -> ClassificationResult {
        let resized = image.resized(to: inputSize)
        guard let cgImage = resized.cgImage else {
            throw NSError(domain: "ImageClassifier", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to obtain CGImage from input.\n"])
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: vnModel) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let results = request.results as? [VNClassificationObservation],
                      let top = results.first else {
                    continuation.resume(throwing: NSError(domain: "ImageClassifier", code: -2, userInfo: [NSLocalizedDescriptionKey: "No classification results."]))
                    return
                }

                let name = top.identifier
                let confidence = Double(top.confidence)
                let category = Self.mapLabelToCategory(name)
                let result = ClassificationResult(name: name, category: category, confidence: confidence)
                continuation.resume(returning: result)
            }
            request.imageCropAndScaleOption = .centerCrop

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Maps a MobileNet label string to one of our sustainability categories.
    /// This is a heuristic mapping and can be refined with a custom model or label map.
    static func mapLabelToCategory(_ label: String) -> ItemCategory {
        let lower = label.lowercased()

        // Heuristics for recyclable materials (expandable)
        let recyclableKeywords = [
            // Metals
            "can", "aluminum", "tin", "steel",
            // Glass
            "glass", "jar", "bottle",
            // Paper/Cardboard
            "cardboard", "paper", "magazine", "newspaper", "envelope",
            // Plastics and containers
            "plastic", "pet", "hdpe", "container", "carton", "tray"
        ]

        // Heuristics for compostable materials (expandable)
        let compostKeywords = [
            // Produce and food scraps
            "banana", "apple", "orange", "pear", "fruit", "vegetable", "greens", "food",
            // Yard/plant
            "leaf", "leaves", "plant", "yard", "grass",
            // Common compostables
            "coffee", "grounds", "tea", "eggshell", "bread", "compost"
        ]

        if recyclableKeywords.contains(where: { lower.contains($0) }) {
            return .recyclable
        }
        if compostKeywords.contains(where: { lower.contains($0) }) {
            return .compost
        }
        return .trash
    }
}

private extension UIImage {
    /// Returns a resized image using a high-quality renderer preserving orientation.
    func resized(to target: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: target, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: target))
        }
    }
}
