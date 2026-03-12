import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder for the ChatNotifier provider.
/// Will be wired in Task 16 when ChatNotifier is implemented.
///
/// For now, export a simple state provider to track if chat is processing.
final chatLoadingProvider = StateProvider<bool>((ref) => false);
