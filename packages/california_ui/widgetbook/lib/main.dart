import 'package:california_ui_widgetbook/main.directories.g.dart';
import 'package:california_ui_widgetbook/src/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

void main() {
  runApp(const WidgetbookApp());
}

/// Widgetbook catalog for the `california_ui` design system.
///
/// Run via `melos run widgetbook` from the repo root, or `flutter run`
/// from this directory. Use-case files live in `lib/use_cases/`, mirroring
/// `california_ui`'s `lib/src/{theme,widgets}/` structure. Regenerate
/// `main.directories.g.dart` with `melos run widgetbook:generate` after
/// adding, removing, or renaming a use-case.
@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        // ViewportAddon must come first so later addons (Alignment) wrap
        // the viewport's contents, not the viewport itself.
        ViewportAddon(Viewports.all),
        AlignmentAddon(),
        TextScaleAddon(),
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: AppThemes.light()),
            WidgetbookTheme(name: 'Dark', data: AppThemes.dark()),
          ],
        ),
      ],
    );
  }
}
