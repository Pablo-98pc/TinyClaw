import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/briefing_service.dart';
import 'database_provider.dart';

const _lastBriefingKey = 'last_briefing_timestamp';
const _briefingCooldownMs = 2 * 60 * 60 * 1000; // 2 hours

final briefingProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final lastMs = prefs.getInt(_lastBriefingKey) ?? 0;
  final now = DateTime.now().millisecondsSinceEpoch;

  if (now - lastMs < _briefingCooldownMs) return null;

  final service = BriefingService(
    taskDao: ref.read(taskDaoProvider),
    eventDao: ref.read(eventDaoProvider),
    habitDao: ref.read(habitDaoProvider),
  );

  final text = await service.generate();
  await prefs.setInt(_lastBriefingKey, now);
  return text;
});
