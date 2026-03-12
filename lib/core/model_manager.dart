import 'intent.dart';
import 'specialist.dart';
import 'specialist_error.dart';

/// Manages specialist lifecycle with LRU eviction under a memory budget.
class ModelManager {
  final int memoryBudget;

  final Map<Intent, Specialist> _registry = {};
  final Set<Intent> _pinned = {};
  final Set<Intent> _active = {};
  final List<Intent> _lruOrder = []; // most recent at end
  bool _degraded = false;

  ModelManager({this.memoryBudget = 4 * 1024 * 1024 * 1024}); // 4GB default

  bool get isDegraded => _degraded;

  int get currentMemoryUsage {
    int total = 0;
    for (final entry in _registry.entries) {
      if (entry.value.isLoaded) total += entry.value.memoryFootprint;
    }
    return total;
  }

  Set<Intent> get pinnedIntents => Set.unmodifiable(_pinned);

  void register(Intent intent, Specialist specialist) {
    _registry[intent] = specialist;
  }

  void pin(Intent intent) {
    if (!_registry.containsKey(intent)) {
      throw ArgumentError('No specialist registered for $intent');
    }
    _pinned.add(intent);
  }

  Future<void> loadPinned() async {
    for (final intent in _pinned) {
      final specialist = _registry[intent];
      if (specialist != null && !specialist.isLoaded) {
        await specialist.load();
        _touchLru(intent);
      }
    }
  }

  void markActive(Intent intent) => _active.add(intent);
  void markInactive(Intent intent) => _active.remove(intent);

  Future<Specialist> specialist(Intent intent) async {
    final s = _registry[intent];
    if (s == null) throw NotLoadedError();

    if (!s.isLoaded) {
      await _ensureMemory(s.memoryFootprint);
      await s.load();
    }
    _touchLru(intent);
    return s;
  }

  void handleMemoryWarning() {
    // Evict non-pinned, non-active specialists
    final toEvict = _lruOrder.where(
      (i) => !_pinned.contains(i) && !_active.contains(i),
    ).toList();

    for (final intent in toEvict) {
      final s = _registry[intent];
      if (s != null && s.isLoaded) {
        s.unload();
        _lruOrder.remove(intent);
      }
    }

    // If still over budget, enter degradation mode
    if (currentMemoryUsage > memoryBudget) {
      _degraded = true;
    }
  }

  Future<void> _ensureMemory(int needed) async {
    while (currentMemoryUsage + needed > memoryBudget) {
      final evictable = _lruOrder.where(
        (i) => !_pinned.contains(i) && !_active.contains(i) && (_registry[i]?.isLoaded ?? false),
      ).toList();

      if (evictable.isEmpty) break;

      final victim = evictable.first; // oldest in LRU
      _registry[victim]?.unload();
      _lruOrder.remove(victim);
    }
  }

  void _touchLru(Intent intent) {
    _lruOrder.remove(intent);
    _lruOrder.add(intent);
  }
}
