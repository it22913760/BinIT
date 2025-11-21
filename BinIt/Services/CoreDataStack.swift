import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    private init() {
        // Try to load the compiled .xcdatamodeld (BinItModel.momd) first.
        // Validate it contains the expected entity; otherwise fall back to the programmatic model.
        let container: NSPersistentContainer
        if let modelURL = Bundle.main.url(forResource: "BinItModel", withExtension: "momd"),
           let bundledModel = NSManagedObjectModel(contentsOf: modelURL),
           let recycled = bundledModel.entitiesByName["RecycledItem"],
           Set(recycled.attributesByName.keys).isSuperset(of: [
               "id", "name", "category", "confidence", "timestamp", "imageData"
           ]) {
            container = NSPersistentContainer(name: "BinItModel", managedObjectModel: bundledModel)
            #if DEBUG
            print("[CoreData] Loaded model from xcdatamodeld (BinItModel.momd)")
            #endif
        } else {
            // Fallback to programmatic model if the xcdatamodeld isn't present or is missing entities
            let programmaticModel = CoreDataStack.buildModel()
            container = NSPersistentContainer(name: "BinItModel", managedObjectModel: programmaticModel)
            #if DEBUG
            print("[CoreData] Loaded programmatic Core Data model (no valid xcdatamodeld found)")
            #endif
        }
        persistentContainer = container
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        let storeURL = description?.url
        var didAttemptRecreation = false
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                if let url = storeURL, !didAttemptRecreation {
                    didAttemptRecreation = true
                    try? self.persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
                    self.persistentContainer.loadPersistentStores { _, error in
                        if let error = error {
                            assertionFailure("Core Data store unrecoverable: \(error)")
                        }
                    }
                } else {
                    assertionFailure("Core Data store failed: \(error)")
                }
            }
        }
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    static func buildModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // RecycledItem entity
        let entity = NSEntityDescription()
        entity.name = "RecycledItem"
        // Use fully-qualified class name so Core Data can resolve the generated class at runtime
        entity.managedObjectClassName = NSStringFromClass(RecycledItem.self)

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
