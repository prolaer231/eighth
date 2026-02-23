import 'package:flutter/material.dart';

class EditorSettings {
  final ThemeMode themeMode;
  final double fontSize;

  EditorSettings({this.themeMode = ThemeMode.dark, this.fontSize = 14.0});

  EditorSettings copyWith({ThemeMode? themeMode, double? fontSize}) {
    return EditorSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}
