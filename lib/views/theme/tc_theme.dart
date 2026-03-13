import 'package:flutter/material.dart';
import 'tc_colors.dart';

abstract final class TcTheme {
  static ThemeData dark() {
    const c = TcColors.dark;

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: c.surface0,
      colorScheme: ColorScheme.dark(
        surface: c.surface0,
        primary: c.accent,
        onSurface: c.textPrimary,
        onSurfaceVariant: c.textSecondary,
        error: c.error,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.accent,
        selectionColor: c.accentMuted,
        selectionHandleColor: c.accent,
      ),
      useMaterial3: true,
      extensions: const [c],
    );
  }
}
