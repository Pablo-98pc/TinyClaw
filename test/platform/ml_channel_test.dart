import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/platform/ml_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MlChannel', () {
    late MlChannel mlChannel;
    late MethodChannel methodChannel;
    final List<MethodCall> calls = [];

    setUp(() {
      methodChannel = const MethodChannel('com.tinyclaw/ml');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (call) async {
        calls.add(call);
        switch (call.method) {
          case 'loadModel':
            return null;
          case 'unloadModel':
            return null;
          case 'predict':
            return 'Mock response for ${call.arguments['input']}';
          case 'memoryUsage':
            return 1024;
          default:
            return null;
        }
      });
      mlChannel = MlChannel(channel: methodChannel);
    });

    tearDown(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, null);
    });

    test('loadModel sends correct method call', () async {
      await mlChannel.loadModel('llama-3.2');
      expect(calls.length, 1);
      expect(calls.first.method, 'loadModel');
      expect(calls.first.arguments, {'modelId': 'llama-3.2'});
    });

    test('unloadModel sends correct method call', () async {
      await mlChannel.unloadModel('llama-3.2');
      expect(calls.length, 1);
      expect(calls.first.method, 'unloadModel');
      expect(calls.first.arguments, {'modelId': 'llama-3.2'});
    });

    test('predict returns response', () async {
      final result = await mlChannel.predict('llama-3.2', 'Hello');
      expect(result, 'Mock response for Hello');
      expect(calls.first.arguments, {'modelId': 'llama-3.2', 'input': 'Hello'});
    });

    test('memoryUsage returns bytes', () async {
      final result = await mlChannel.memoryUsage('llama-3.2');
      expect(result, 1024);
    });
  });
}
