import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

const _keyQuizCount = 'quizzes_taken_count';
const _keyThemeMode = 'theme_mode'; // 'light' | 'dark' | 'system'

class PrefsService {
  PrefsService({SharedPreferences? prefs}) : _prefs = prefs;

  final SharedPreferences? _prefs;
  SharedPreferences get prefs {
    final p = _prefs;
    if (p != null) return p;
    throw StateError(
        'PrefsService not initialized. Call init() first.');
  }

  static Future<PrefsService> init() async {
    final p = await SharedPreferences.getInstance();
    return PrefsService(prefs: p);
  }

  int getQuizzesTakenCount() => prefs.getInt(_keyQuizCount) ?? 0;
  Future<void> setQuizzesTakenCount(int count) =>
      prefs.setInt(_keyQuizCount, count);

  ThemeMode getThemeMode() {
    final s = prefs.getString(_keyThemeMode);
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final s = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_keyThemeMode, s);
  }
}
