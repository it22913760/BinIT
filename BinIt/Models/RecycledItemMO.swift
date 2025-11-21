import Foundation
import CoreData

@objc(RecycledItem)
public class RecycledItemMO: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecycledItemMO> {
        return NSFetchRequest<RecycledItemMO>(entityName: "RecycledItem")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var category: String
    @NSManaged public var confidence: Double
    @NSManaged public var timestamp: Date
    @NSManaged public var imageData: Data
}

extension RecycledItemMO {
    var itemCategory: ItemCategory {
        get { ItemCategory(rawValue: category) ?? .trash }
        set { category = newValue.rawValue }
    }
}
