import 'cloud_config.dart';
import 'cloud_provider.dart';

/// Orchestrates draft enhancement via cloud.
class EnhanceService {
  final CloudConfig config;
  final CloudProvider provider;

  EnhanceService({required this.config, required this.provider});

  /// Returns enhanced text, or null if cloud is disabled.
  Future<String?> enhance(String draftText, {String instruction = 'improve this'}) async {
    if (!config.isEnabled) return null;
    return provider.enhance(draftText, instruction);
  }
}
