import 'package:flutter/material.dart' hide Intent;
import '../../core/intent.dart';

class TcColors extends ThemeExtension<TcColors> {
  // Surfaces
  final Color surface0;
  final Color surface1;
  final Color surface2;
  final Color surface3;

  // Accents
  final Color accent;
  final Color accentMuted;
  final Color accentSurface;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  // Semantic
  final Color success;
  final Color warning;
  final Color error;
  final Color divider;

  // Intent colors
  final Map<Intent, Color> _intentColors;

  const TcColors({
    required this.surface0,
    required this.surface1,
    required this.surface2,
    required this.surface3,
    required this.accent,
    required this.accentMuted,
    required this.accentSurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.success,
    required this.warning,
    required this.error,
    required this.divider,
    required Map<Intent, Color> intentColors,
  }) : _intentColors = intentColors;

  Color intentColor(Intent intent) =>
      _intentColors[intent] ?? textSecondary;

  static TcColors of(BuildContext context) =>
      Theme.of(context).extension<TcColors>()!;

  static const dark = TcColors(
    surface0: Color(0xFF0F0F14),
    surface1: Color(0xFF1A1A24),
    surface2: Color(0xFF24243A),
    surface3: Color(0xFF2E2E48),
    accent: Color(0xFF4A9EFF),
    accentMuted: Color(0x264A9EFF),   // 15% opacity
    accentSurface: Color(0x144A9EFF), // 8% opacity
    textPrimary: Color(0xFFEFEFEF),
    textSecondary: Color(0xFF9CA3AF),
    textTertiary: Color(0xFF6B7280),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    divider: Color(0x0FFFFFFF),       // 6% opacity
    intentColors: {
      Intent.chat: Color(0xFF9CA3AF),
      Intent.summarize: Color(0xFFFB923C),
      Intent.task: Color(0xFF60A5FA),
      Intent.event: Color(0xFFA78BFA),
      Intent.note: Color(0xFFFBBF24),
      Intent.habit: Color(0xFF34D399),  // green — growth/streaks
      Intent.draft: Color(0xFF818CF8),  // indigo — writing
      Intent.search: Color(0xFFF472B6), // pink — discovery
    },
  );

  @override
  TcColors copyWith() => this;

  @override
  TcColors lerp(TcColors? other, double t) => other ?? this;
}
