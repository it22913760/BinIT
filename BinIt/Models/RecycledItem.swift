import Foundation
import SwiftData

/// Represents the sustainability category for a scanned item.
public enum ItemCategory: String, Codable, CaseIterable, Sendable {
    case recyclable
    case compost
    case trash
}

/// A SwiftData model representing a classified and saved scan.
@Model
public final class RecycledItem {
    public var id: UUID
    public var name: String
    public var category: ItemCategory
    public var confidence: Double
    public var timestamp: Date
    public var imageData: Data

    /// Designated initializer for `RecycledItem`.
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - name: Human-readable label (e.g., "Plastic Bottle").
    ///   - category: Sustainability category for the item.
    ///   - confidence: Classifier confidence (0.0 ... 1.0).
    ///   - timestamp: Time when the item was scanned.
    ///   - imageData: JPEG/PNG data of the captured image.
    public init(
        id: UUID = UUID(),
        name: String,
        category: ItemCategory,
        confidence: Double,
        timestamp: Date = Date(),
        imageData: Data
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.confidence = confidence
        self.timestamp = timestamp
        self.imageData = imageData
    }
}
