import Foundation
import SwiftData

/// An actor-based data manager for thread-safe SwiftData operations.
/// This actor does not own a container; instead, a `ModelContext` is passed per call
/// and operations are performed on the main actor to satisfy SwiftData requirements.
public actor DataManager {
    public static let shared = DataManager()

    private init() {}

    /// Persists a `RecycledItem` instance.
    /// - Parameters:
    ///   - item: The item to save.
    ///   - context: The SwiftData model context from the environment.
    public func save(_ item: RecycledItem, in context: ModelContext) async throws {
        try await MainActor.run {
            context.insert(item)
            try context.save()
        }
    }

    /// Convenience to create and save an item in one call.
    /// - Parameters mirror `RecycledItem.init` with an injected `ModelContext`.
    /// - Returns: The saved `RecycledItem`.
    @discardableResult
    public func createAndSave(
        name: String,
        category: ItemCategory,
        confidence: Double,
        imageData: Data,
        timestamp: Date = Date(),
        in context: ModelContext
    ) async throws -> RecycledItem {
        let item = RecycledItem(
            name: name,
            category: category,
            confidence: confidence,
            timestamp: timestamp,
            imageData: imageData
        )
        try await save(item, in: context)
        return item
    }

    /// Fetches items, optionally limiting the result.
    /// - Parameters:
    ///   - limit: Maximum number of items to return. Pass nil for all.
    ///   - context: The SwiftData model context from the environment.
    /// - Returns: Items sorted by `timestamp` descending.
    public func fetch(limit: Int? = nil, in context: ModelContext) async throws -> [RecycledItem] {
        try await MainActor.run {
            var descriptor = FetchDescriptor<RecycledItem>(
                sortBy: [ .init(\.timestamp, order: .reverse) ]
            )
            if let limit = limit {
                descriptor.fetchLimit = limit
            }
            return try context.fetch(descriptor)
        }
    }

    /// Deletes a given item.
    public func delete(_ item: RecycledItem, in context: ModelContext) async throws {
        try await MainActor.run {
            context.delete(item)
            try context.save()
        }
    }

    /// Deletes all saved items.
    public func wipeAll(in context: ModelContext) async throws {
        let items = try await fetch(in: context)
        try await MainActor.run {
            for i in items {
                context.delete(i)
            }
            try context.save()
        }
    }
}
