import XCTest
@testable import BinIt

final class BinItModelTests: XCTestCase {
    func testRecycledItemInitialization() throws {
        let id = UUID()
        let name = "Plastic Bottle"
        let category: ItemCategory = .recyclable
        let confidence = 0.92
        let timestamp = Date()
        let imageData = Data([0xFF, 0xD8, 0xFF]) // JPEG SOI bytes as sample

        let item = RecycledItem(
            id: id,
            name: name,
            category: category,
            confidence: confidence,
            timestamp: timestamp,
            imageData: imageData
        )

        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.name, name)
        XCTAssertEqual(item.category, category)
        XCTAssertEqual(item.confidence, confidence, accuracy: 0.0001)
        // timestamp equality within 1s to avoid precision drift
        XCTAssertLessThan(abs(item.timestamp.timeIntervalSince(timestamp)), 1.0)
        XCTAssertEqual(item.imageData, imageData)
    }
}
