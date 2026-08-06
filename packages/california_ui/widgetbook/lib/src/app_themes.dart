import 'package:california_ui/california_ui.dart';
import 'package:flutter/material.dart';

/// Minimal light/dark [ThemeData] built from California UI's design
/// tokens, for previewing use-cases against both palettes in the
/// Widgetbook catalog.
///
/// `california_ui` does not (yet) ship its own [ThemeData]/[ColorScheme] —
/// its widgets read tokens directly from [CaliforniaColors] and
/// [CaliforniaTypography] rather than `Theme.of(context)`. This theme only
/// controls the catalog's own chrome (background, app bar); it does not
/// affect how catalogued widgets render, since they don't consume
/// `ThemeData`.
abstract final class AppThemes {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: CaliforniaColors.surfacePrimary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CaliforniaColors.brandPrimary,
      ),
      fontFamily: californiaFontFamily,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CaliforniaColors.surfacePrimaryDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CaliforniaColors.brandPrimary,
        brightness: Brightness.dark,
      ),
      fontFamily: californiaFontFamily,
    );
  }
}
