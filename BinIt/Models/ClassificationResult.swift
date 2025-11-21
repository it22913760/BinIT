import Foundation

/// Represents the result of classifying an image.
public struct ClassificationResult: Sendable, Equatable {
    public let name: String
    public let category: ItemCategory
    public let confidence: Double
}
