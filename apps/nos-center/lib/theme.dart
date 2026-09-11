// Thème N-OS Center — palette NAABIGA (rouge #D62828, or #D4AF37, vert #198754, noir #111111)
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

class NosColors {
  NosColors._();
  static const Color red = Color(0xFFD62828);
  static const Color gold = Color(0xFFD4AF37);
  static const Color green = Color(0xFF198754);
  static const Color black = Color(0xFF111111);
  static const Color white = Color(0xFFFFFFFF);
}

class NosTheme {
  NosTheme._();

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: NosColors.red,
      brightness: brightness,
      primary: NosColors.red,
      secondary: NosColors.gold,
      tertiary: NosColors.green,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Inter',
      scaffoldBackgroundColor:
          brightness == Brightness.dark ? NosColors.black : NosColors.white,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
