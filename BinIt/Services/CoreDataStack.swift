import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    private init() {
        let model = CoreDataStack.buildModel()
        persistentContainer = NSPersistentContainer(name: "BinItModel", managedObjectModel: model)
        persistentContainer.loadPersistentStores { _, error in
            if let error = error { fatalError("Core Data store failed: \(error)") }
        }
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    static func buildModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // RecycledItem entity
        let entity = NSEntityDescription()
        entity.name = "RecycledItem"
        entity.managedObjectClassName = String(describing: RecycledItemMO.self)

        // Attributes
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false

        let nameAttr = NSAttributeDescription()
        nameAttr.name = "name"
        nameAttr.attributeType = .stringAttributeType
        nameAttr.isOptional = false

        let categoryAttr = NSAttributeDescription()
        categoryAttr.name = "category"
        categoryAttr.attributeType = .stringAttributeType
        categoryAttr.isOptional = false

        let confidenceAttr = NSAttributeDescription()
        confidenceAttr.name = "confidence"
        confidenceAttr.attributeType = .doubleAttributeType
        confidenceAttr.isOptional = false

        let timestampAttr = NSAttributeDescription()
        timestampAttr.name = "timestamp"
        timestampAttr.attributeType = .dateAttributeType
        timestampAttr.isOptional = false

        let imageDataAttr = NSAttributeDescription()
        imageDataAttr.name = "imageData"
        imageDataAttr.attributeType = .binaryDataAttributeType
        imageDataAttr.isOptional = false
        imageDataAttr.allowsExternalBinaryDataStorage = true

        entity.properties = [idAttr, nameAttr, categoryAttr, confidenceAttr, timestampAttr, imageDataAttr]

        model.entities = [entity]
        return model
    }
}
