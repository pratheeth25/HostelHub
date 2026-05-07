import 'package:flutter/material.dart';

class AppTheme {
  static const _primarySeed = Color(0xFF6750A4);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _primarySeed,
        brightness: Brightness.light,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _primarySeed,
        brightness: Brightness.dark,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      );
}
