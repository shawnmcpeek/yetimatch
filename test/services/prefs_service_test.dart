import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yetimatch/services/prefs_service.dart';

void main() {
  group('PrefsService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('init returns PrefsService with SharedPreferences', () async {
      final prefs = await PrefsService.init();
      expect(prefs.getQuizzesTakenCount(), 0);
      expect(prefs.getThemeMode(), ThemeMode.system);
    });

    test('getQuizzesTakenCount returns 0 when not set', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PrefsService.init();
      expect(prefs.getQuizzesTakenCount(), 0);
    });

    test('setQuizzesTakenCount and getQuizzesTakenCount round-trip', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PrefsService.init();
      await prefs.setQuizzesTakenCount(5);
      expect(prefs.getQuizzesTakenCount(), 5);
    });

    test('getThemeMode returns system when not set', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PrefsService.init();
      expect(prefs.getThemeMode(), ThemeMode.system);
    });

    test('setThemeMode and getThemeMode round-trip light/dark/system', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PrefsService.init();
      await prefs.setThemeMode(ThemeMode.light);
      expect(prefs.getThemeMode(), ThemeMode.light);
      await prefs.setThemeMode(ThemeMode.dark);
      expect(prefs.getThemeMode(), ThemeMode.dark);
      await prefs.setThemeMode(ThemeMode.system);
      expect(prefs.getThemeMode(), ThemeMode.system);
    });

    test('prefs getter throws when not initialized', () {
      final prefs = PrefsService(prefs: null);
      expect(() => prefs.getQuizzesTakenCount(), throwsStateError);
    });
  });
}
