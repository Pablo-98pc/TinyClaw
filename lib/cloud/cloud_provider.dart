/// Abstract interface for cloud AI providers.
abstract class CloudProvider {
  /// Enhance draft text with a cloud model.
  Future<String> enhance(String text, String instruction);
}
