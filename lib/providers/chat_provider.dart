import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_notifier.dart';

/// Provides the ChatNotifier for orchestrating chat flow.
final chatNotifierProvider = NotifierProvider<ChatNotifier, bool>(ChatNotifier.new);
