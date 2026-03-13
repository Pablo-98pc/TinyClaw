import 'dart:async';
import '../core/specialist.dart';
import '../core/specialist_error.dart';
import '../core/intent.dart';

/// Mock specialist with canned responses for testing.
class StubSpecialist extends Specialist {
  @override
  final String id;

  final Intent intent;
  bool shouldFail;

  bool _isLoaded = false;
  final int _memoryFootprint;

  StubSpecialist({
    required this.id,
    required this.intent,
    this.shouldFail = false,
    int memoryFootprint = 100,
  }) : _memoryFootprint = memoryFootprint;

  @override
  bool get isLoaded => _isLoaded;

  @override
  int get memoryFootprint => _memoryFootprint;

  @override
  Future<void> load() async {
    if (shouldFail) throw LoadFailedError('Stub failure for $id');
    _isLoaded = true;
  }

  @override
  void unload() {
    _isLoaded = false;
  }

  @override
  Stream<String> predict(String input) async* {
    if (!_isLoaded) throw NotLoadedError();
    if (shouldFail) throw InferenceFailedError('Stub failure for $id');

    final response = _cannedResponse(input);
    // Simulate streaming by yielding word by word
    final words = response.split(' ');
    for (final word in words) {
      yield '$word ';
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  String _cannedResponse(String input) {
    switch (intent) {
      case Intent.chat:
        return 'Hello! I am TinyClaw, your AI assistant.';
      case Intent.summarize:
        return 'Here is a summary of your text.';
      case Intent.task:
        return '```json\n{"type":"task","title":"$input","dueDate":null}\n```';
      case Intent.event:
        return '```json\n{"type":"event","title":"$input","date":"2026-03-15","startTime":"09:00","endTime":"10:00"}\n```';
      case Intent.note:
        return '```json\n{"type":"note","content":"$input"}\n```';
      case Intent.habit:
        return '```json\n{"type":"habit","title":"$input","frequency":"daily","targetTime":null}\n```';
      case Intent.draft:
        return '```json\n{"type":"draft","content":"Here is a draft based on your request: $input"}\n```';
      case Intent.search:
        return 'Searching for: $input';
    }
  }
}
