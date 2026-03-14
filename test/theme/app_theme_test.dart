import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yetimatch/theme/app_theme.dart';

void main() {
  group('yetiMatchTheme', () {
    test('returns ThemeData with useMaterial3 true', () {
      final theme = yetiMatchTheme(dark: false);
      expect(theme.useMaterial3, true);
    });

    test('light theme has light colorScheme', () {
      final theme = yetiMatchTheme(dark: false);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('dark theme has dark colorScheme', () {
      final theme = yetiMatchTheme(dark: true);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });
  });

  group('categoryCardColor', () {
    test('light mode returns darker than surface', () {
      final scheme = ColorScheme.light(surface: const Color(0xFFE0E0E0));
      final color = categoryCardColor(scheme, Brightness.light);
      expect(color.toARGB32(), lessThan(scheme.surface.toARGB32()));
    });

    test('dark mode returns lighter than surface', () {
      final scheme = ColorScheme.dark(surface: const Color(0xFF202020));
      final color = categoryCardColor(scheme, Brightness.dark);
      expect(color.toARGB32(), greaterThan(scheme.surface.toARGB32()));
    });
  });
}
