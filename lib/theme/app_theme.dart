import 'package:flutter/material.dart';

final ColorScheme _darkScheme = ColorScheme.dark(
  primary: const Color(0xFF7DD3FC),
  onPrimary: const Color(0xFF003547),
  primaryContainer: const Color(0xFF004D64),
  onPrimaryContainer: const Color(0xFFB6EAFF),
  secondary: const Color(0xFFB1C8D4),
  onSecondary: const Color(0xFF1C333B),
  secondaryContainer: const Color(0xFF334952),
  onSecondaryContainer: const Color(0xFFCDE4F0),
  surface: const Color(0xFF191C1E),
  onSurface: const Color(0xFFE1E3E5),
  error: const Color(0xFFFFB4AB),
  onError: const Color(0xFF690005),
);

final ColorScheme _lightScheme = ColorScheme.light(
  primary: const Color(0xFF006684),
  onPrimary: Colors.white,
  primaryContainer: const Color(0xFFB6EAFF),
  onPrimaryContainer: const Color(0xFF001F29),
  secondary: const Color(0xFF4D616C),
  onSecondary: Colors.white,
  secondaryContainer: const Color(0xFFD0E6F2),
  onSecondaryContainer: const Color(0xFF091E27),
  surface: const Color(0xFFF5FAFC),
  onSurface: const Color(0xFF191C1E),
  error: const Color(0xFFBA1A1A),
  onError: Colors.white,
);

ThemeData yetiMatchTheme({required bool dark}) {
  final scheme = dark ? _darkScheme : _lightScheme;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
  );
}

/// Category card surface: light mode = 15% darker than surface, dark mode = 15% lighter.
Color categoryCardColor(ColorScheme scheme, Brightness brightness) {
  final base = scheme.surface;
  return brightness == Brightness.dark
      ? Color.lerp(base, const Color(0xFFFFFFFF), 0.15)!
      : Color.lerp(base, const Color(0xFF000000), 0.15)!;
}
