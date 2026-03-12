/// Base class for all ML specialists.
abstract class Specialist {
  String get id;
  bool get isLoaded;
  int get memoryFootprint;
  Future<void> load();
  void unload();
  Stream<String> predict(String input);
}
