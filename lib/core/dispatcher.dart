import 'intent.dart';

/// Base class for intent classification.
abstract class Dispatcher {
  Future<Intent> classify(String text);
}
