import Foundation
import UIKit
import Vision
import CoreML
import ImageIO

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
            var didResume = false
            func safeResume(_ result: Result<ClassificationResult, Error>) {
                guard !didResume else { return }
                didResume = true
                switch result {
                case .success(let value): continuation.resume(returning: value)
                case .failure(let err): continuation.resume(throwing: err)
                }
            }

            DispatchQueue.global(qos: .userInitiated).async {
                // 1) Early human detectors
                let orientation = image.cgOrientation
                let faceReq = VNDetectFaceRectanglesRequest()
                let faceLandmarksReq = VNDetectFaceLandmarksRequest()
                let humanReq = VNDetectHumanRectanglesRequest()
                let bodyPoseReq = VNDetectHumanBodyPoseRequest()
                let detector: VNImageRequestHandler = {
                    if let origCG = image.cgImage {
                        return VNImageRequestHandler(cgImage: origCG, orientation: orientation, options: [:])
                    } else {
                        return VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
                    }
                }()
                var isHuman = false
                do {
                    try detector.perform([faceReq, faceLandmarksReq, humanReq, bodyPoseReq])
                    let hasFaces = (faceReq.results as? [VNFaceObservation])?.isEmpty == false
                    let hasLandmarks = (faceLandmarksReq.results as? [VNFaceObservation])?.isEmpty == false
                    let hasHumans = (humanReq.results as? [VNHumanObservation])?.isEmpty == false
                    let hasPose = (bodyPoseReq.results as? [VNHumanBodyPoseObservation])?.isEmpty == false
                    isHuman = hasFaces || hasLandmarks || hasHumans || hasPose
                } catch {
                    // ignore and continue to classification
                }
                if isHuman {
                    let name = "Human"
                    safeResume(.success(ClassificationResult(name: name, category: .human, confidence: 1.0)))
                    return
                }

                // 2) CoreML classification
                let request = VNCoreMLRequest(model: self.vnModel) { request, error in
                    if let error = error { safeResume(.failure(error)); return }
                    guard let results = request.results as? [VNClassificationObservation], let top = results.first else {
                        safeResume(.failure(NSError(domain: "ImageClassifier", code: -2, userInfo: [NSLocalizedDescriptionKey: "No classification results."]))); return
                    }
                    let name = top.identifier
                    let confidence = Double(top.confidence)
                    if Self.resultsContainHuman(results) {
                        safeResume(.success(ClassificationResult(name: name, category: .human, confidence: confidence)))
                        return
                    }
                    let category = Self.mapLabelToCategory(name)
                    safeResume(.success(ClassificationResult(name: name, category: category, confidence: confidence)))
                }
                request.imageCropAndScaleOption = .centerCrop
                let handler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgOrientation, options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    safeResume(.failure(error))
                }
            }
        }
    }

    /// Maps a MobileNet label string to one of our sustainability categories.
    /// This is a heuristic mapping and can be refined with a custom model or label map.
    static func mapLabelToCategory(_ label: String) -> ItemCategory {
        let lower = label.lowercased()

        // Detect human-related labels and mark as non-compostable human category
        let humanKeywords = [
            // direct human terms
            "person", "people", "human", "man", "woman", "male", "female", "boy", "girl", "child", "baby",
            // facial/body parts & portrait semantics
            "face", "head", "profile", "portrait", "self-portrait", "selfie", "torso", "neck", "ear", "beard", "mustache",
            // apparel commonly present in human photos (heuristic fallback)
            "tshirt", "t-shirt", "shirt", "sweater", "sweatshirt", "hoodie", "jersey", "jeans", "jacket", "coat"
        ]

        if humanKeywords.contains(where: { lower.contains($0) }) {
            return .human
        }

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

    /// Checks top-N classification results for human-related labels.
    private static func resultsContainHuman(_ results: [VNClassificationObservation], topK: Int = 15) -> Bool {
        let humanKeywords = [
            "person", "people", "human", "man", "woman", "male", "female", "boy", "girl", "child", "baby",
            "face", "head", "profile", "portrait", "self-portrait", "selfie", "torso", "neck", "ear", "beard", "mustache",
            "tshirt", "t-shirt", "shirt", "sweater", "sweatshirt", "hoodie", "jersey", "jeans", "jacket", "coat"
        ]
        for obs in results.prefix(topK) {
            let id = obs.identifier.lowercased()
            if humanKeywords.contains(where: { id.contains($0) }) { return true }
        }
        return false
    }

    public func topK(image: UIImage, k: Int = 3) async throws -> [(name: String, confidence: Double, category: ItemCategory)] {
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
                guard let results = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                let mapped: [(String, Double, ItemCategory)] = results.prefix(k).map { obs in
                    let n = obs.identifier
                    let c = Double(obs.confidence)
                    return (n, c, Self.mapLabelToCategory(n))
                }
                continuation.resume(returning: mapped)
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

    public func looksHuman(image: UIImage) async -> Bool {
        let faceReq = VNDetectFaceRectanglesRequest()
        let humanReq = VNDetectHumanRectanglesRequest()
        let handler: VNImageRequestHandler
        let orientation = image.cgOrientation
        if let orig = image.cgImage {
            handler = VNImageRequestHandler(cgImage: orig, orientation: orientation, options: [:])
        } else {
            let resized = image.resized(to: inputSize)
            guard let cg = resized.cgImage else { return false }
            handler = VNImageRequestHandler(cgImage: cg, orientation: orientation, options: [:])
        }
        do {
            try handler.perform([faceReq, humanReq])
            let hasFaces = (faceReq.results as? [VNFaceObservation])?.isEmpty == false
            let hasHumans = (humanReq.results as? [VNHumanObservation])?.isEmpty == false
            return hasFaces || hasHumans
        } catch {
            return false
        }
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

    var cgOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
