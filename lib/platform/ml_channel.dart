import 'package:flutter/services.dart';

/// Dart-side wrapper for the native ML platform channel.
class MlChannel {
  final MethodChannel _channel;

  MlChannel({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('com.tinyclaw/ml');

  /// Load a model into memory on the native side.
  Future<void> loadModel(String modelId) async {
    await _channel.invokeMethod('loadModel', {'modelId': modelId});
  }

  /// Unload a model from memory on the native side.
  Future<void> unloadModel(String modelId) async {
    await _channel.invokeMethod('unloadModel', {'modelId': modelId});
  }

  /// Run inference on a loaded model. Returns the full response string.
  Future<String> predict(String modelId, String input) async {
    final result = await _channel.invokeMethod<String>('predict', {
      'modelId': modelId,
      'input': input,
    });
    return result ?? '';
  }

  /// Get the memory usage of a loaded model in bytes.
  Future<int> memoryUsage(String modelId) async {
    final result = await _channel.invokeMethod<int>('memoryUsage', {
      'modelId': modelId,
    });
    return result ?? 0;
  }
}
