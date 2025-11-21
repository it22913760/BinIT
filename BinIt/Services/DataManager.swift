import Foundation
import CoreData

/// An actor-based data manager for thread-safe Core Data operations.
/// A context is passed per call and operations are performed on the main actor for UI contexts.
public actor DataManager {
    public static let shared = DataManager()

    private init() {}

    /// Persists changes on the provided context.
    public func saveContext(_ context: NSManagedObjectContext) async throws {
        try await MainActor.run {
            if context.hasChanges {
                try context.save()
            }
        }
    }

    /// Convenience to create and save an item in one call.
    /// - Parameters mirror `RecycledItemMO` fields with an injected `NSManagedObjectContext`.
    @discardableResult
    public func createAndSave(
        name: String,
        category: ItemCategory,
        confidence: Double,
        imageData: Data,
        timestamp: Date = Date(),
        in context: NSManagedObjectContext
    ) async throws -> RecycledItemMO {
        var created: RecycledItemMO!
        try await MainActor.run {
            created = RecycledItemMO(context: context)
            created.id = UUID()
            created.name = name
            created.itemCategory = category
            created.confidence = confidence
            created.timestamp = timestamp
            created.imageData = imageData
            try context.save()
        }
        return created
    }

    /// Fetches items, optionally limiting the result.
    /// - Parameters:
    ///   - limit: Maximum number of items to return. Pass nil for all.
    ///   - context: The Core Data context from the environment.
    /// - Returns: Items sorted by `timestamp` descending.
    public func fetch(limit: Int? = nil, in context: NSManagedObjectContext) async throws -> [RecycledItemMO] {
        try await MainActor.run {
            let request: NSFetchRequest<RecycledItemMO> = RecycledItemMO.fetchRequest()
            let sort = NSSortDescriptor(key: #keyPath(RecycledItemMO.timestamp), ascending: false)
            request.sortDescriptors = [sort]
            if let limit = limit { request.fetchLimit = limit }
            return try context.fetch(request)
        }
    }

    /// Deletes a given item.
    public func delete(_ item: RecycledItemMO, in context: NSManagedObjectContext) async throws {
        try await MainActor.run {
            context.delete(item)
            try context.save()
        }
    }

    /// Deletes all saved items.
    public func wipeAll(in context: NSManagedObjectContext) async throws {
        let items = try await fetch(in: context)
        try await MainActor.run {
            for i in items { context.delete(i) }
            try context.save()
        }
    }
}
