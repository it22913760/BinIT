import Foundation

public enum ItemCategory: String, Codable, CaseIterable, Sendable {
    case recyclable
    case compost
    case trash
}
