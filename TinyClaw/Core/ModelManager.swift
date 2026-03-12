import Foundation

/// Central coordinator for model lifecycle and LRU eviction.
/// Enforces a RAM budget and manages loading/unloading of specialists.
public final class ModelManager {
    private let budgetBytes: Int
    private var specialists: [Intent: SpecialistProtocol] = [:]
    private var pinnedIntents: Set<Intent> = []
    private var activeIntents: Set<Intent> = []
    private var loadOrder: [Intent] = []  // Oldest first for LRU

    /// True when all non-pinned models have been evicted due to memory pressure.
    public private(set) var isDegraded: Bool = false

    /// Current total memory used by loaded specialists (including pinned).
    public var currentMemoryUsage: Int {
        specialists.values
            .filter { $0.isLoaded }
            .reduce(0) { $0 + $1.memoryFootprint }
    }

    public init(budgetBytes: Int = 4_000_000_000) {
        self.budgetBytes = budgetBytes
    }

    /// Register a specialist for a given intent (LRU managed).
    public func register(specialist: SpecialistProtocol, for intent: Intent) {
        specialists[intent] = specialist
    }

    /// Pin a specialist — it will be exempt from LRU eviction.
    /// Use for the dispatcher or other always-loaded models.
    public func pin(specialist: SpecialistProtocol, for intent: Intent) {
        specialists[intent] = specialist
        pinnedIntents.insert(intent)
    }

    /// Load all pinned specialists. Call at app startup.
    public func loadPinned() async throws {
        for intent in pinnedIntents {
            try await specialists[intent]?.load()
        }
    }

    /// Mark a specialist as having an active inference stream (exempt from eviction).
    public func markActive(intent: Intent) {
        activeIntents.insert(intent)
    }

    /// Mark a specialist's inference stream as complete (eligible for eviction again).
    public func markInactive(intent: Intent) {
        activeIntents.remove(intent)
    }

    /// Get the specialist for an intent, loading it if necessary.
    /// Evicts LRU models if loading would exceed the budget.
    public func specialist(for intent: Intent) async throws -> SpecialistProtocol {
        guard let specialist = specialists[intent] else {
            throw SpecialistError.loadFailed("No specialist registered for \(intent)")
        }

        if specialist.isLoaded {
            // Move to end of LRU (most recently used)
            loadOrder.removeAll { $0 == intent }
            loadOrder.append(intent)
            isDegraded = false
            return specialist
        }

        // Evict until there's room (skip pinned and active)
        while currentMemoryUsage + specialist.memoryFootprint > budgetBytes {
            guard let oldest = loadOrder.first(where: { !pinnedIntents.contains($0) && !activeIntents.contains($0) }) else {
                break
            }
            evict(intent: oldest)
        }

        try await specialist.load()
        loadOrder.append(intent)
        isDegraded = false
        return specialist
    }

    /// Evict a specific specialist.
    private func evict(intent: Intent) {
        specialists[intent]?.unload()
        loadOrder.removeAll { $0 == intent }
    }

    /// Handle iOS memory warning — evict all non-pinned specialists.
    /// Sets `isDegraded = true` if no non-pinned models remain loaded.
    public func handleMemoryWarning() {
        let evictable = loadOrder.filter { !pinnedIntents.contains($0) }
        for intent in evictable {
            specialists[intent]?.unload()
            loadOrder.removeAll { $0 == intent }
        }
        isDegraded = loadOrder.allSatisfy { pinnedIntents.contains($0) }
    }
}
