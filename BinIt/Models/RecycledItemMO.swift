import Foundation
import CoreData

extension RecycledItem {
    var itemCategory: ItemCategory {
        get { ItemCategory(rawValue: category ?? "") ?? .trash }
        set { category = newValue.rawValue }
    }
}
