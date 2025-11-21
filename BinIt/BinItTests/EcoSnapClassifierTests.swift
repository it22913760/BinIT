// This file was misplaced under the app bundle. Guard it so the app target never compiles it.
#if canImport(XCTest)
import XCTest
@testable import BinIt

final class EcoSnapClassifierTests_AppBundle: XCTestCase {
    func testRecyclableMapping() {
        XCTAssertEqual(ImageClassifier.mapLabelToCategory("aluminum can"), .recyclable)
        XCTAssertEqual(ImageClassifier.mapLabelToCategory("glass bottle"), .recyclable)
        XCTAssertEqual(ImageClassifier.mapLabelToCategory("cardboard box"), .recyclable)
    }

    func testCompostMapping() {
        XCTAssertEqual(ImageClassifier.mapLabelToCategory("banana peel"), .compost)
        XCTAssertEqual(ImageClassifier.mapLabelToCategory("apple core"), .compost)
        XCTAssertEqual(ImageClassifier.mapLabelToCategory("coffee grounds"), .compost)
    }

    func testTrashFallback() {
        XCTAssertEqual(ImageClassifier.mapLabelToCategory("plastic wrapper"), .trash)
        XCTAssertEqual(ImageClassifier.mapLabelToCategory("styrofoam cup"), .trash)
    }
}
#endif
