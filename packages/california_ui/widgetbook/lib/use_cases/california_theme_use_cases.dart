import 'package:california_ui/california_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

/// A read-only reference of every [CaliforniaColors] semantic token, so
/// palette/token changes can be sanity-checked visually alongside the
/// components that consume them.
@widgetbook.UseCase(name: 'Palette', type: CaliforniaColors)
Widget buildCaliforniaColorsUseCase(BuildContext context) {
  final swatches = <String, Color>{
    'surfacePrimary': CaliforniaColors.surfacePrimary,
    'surfaceElevated': CaliforniaColors.surfaceElevated,
    'surfaceMuted': CaliforniaColors.surfaceMuted,
    'textPrimary': CaliforniaColors.textPrimary,
    'textSecondary': CaliforniaColors.textSecondary,
    'textTertiary': CaliforniaColors.textTertiary,
    'textBrand': CaliforniaColors.textBrand,
    'brandPrimary': CaliforniaColors.brandPrimary,
    'brandSecondary': CaliforniaColors.brandSecondary,
    'brandTertiary': CaliforniaColors.brandTertiary,
    'borderDefault': CaliforniaColors.borderDefault,
    'borderFocused': CaliforniaColors.borderFocused,
    'divider': CaliforniaColors.divider,
    'disabled': CaliforniaColors.disabled,
    'success': CaliforniaColors.success,
    'warning': CaliforniaColors.warning,
    'error': CaliforniaColors.error,
  };

  return GridView.count(
    padding: const EdgeInsets.all(24),
    crossAxisCount: 4,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 1.4,
    shrinkWrap: true,
    children: [
      for (final entry in swatches.entries)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: entry.value,
                  border: Border.all(color: CaliforniaColors.borderDefault),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(entry.key, style: const TextStyle(fontSize: 12)),
          ],
        ),
    ],
  );
}

/// A read-only reference of every [CaliforniaTypography] style.
@widgetbook.UseCase(name: 'Type scale', type: CaliforniaTypography)
Widget buildCaliforniaTypographyUseCase(BuildContext context) {
  final styles = <String, TextStyle>{
    'h1 — 24 / Bold': CaliforniaTypography.h1,
    'h2 — 20 / Bold': CaliforniaTypography.h2,
    'h3 — 18 / Bold': CaliforniaTypography.h3,
    'h4 — 16 / Bold': CaliforniaTypography.h4,
    'h5 — 14 / Bold': CaliforniaTypography.h5,
    'h6 — 12 / Bold': CaliforniaTypography.h6,
    'p16Medium': CaliforniaTypography.p16Medium,
    'p16Regular': CaliforniaTypography.p16Regular,
    'p14Medium': CaliforniaTypography.p14Medium,
    'p14Regular': CaliforniaTypography.p14Regular,
    'p12Medium': CaliforniaTypography.p12Medium,
    'p12Regular': CaliforniaTypography.p12Regular,
  };

  return ListView(
    padding: const EdgeInsets.all(24),
    shrinkWrap: true,
    children: [
      for (final entry in styles.entries)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('${entry.key} — The quick fox', style: entry.value),
        ),
    ],
  );
}

/// A read-only reference of every [CaliforniaSpacing] step.
@widgetbook.UseCase(name: 'Scale', type: CaliforniaSpacing)
Widget buildCaliforniaSpacingUseCase(BuildContext context) {
  final steps = <String, double>{
    'xxs': CaliforniaSpacing.xxs,
    'xs': CaliforniaSpacing.xs,
    'sm': CaliforniaSpacing.sm,
    'md': CaliforniaSpacing.md,
    'lg': CaliforniaSpacing.lg,
    'xl': CaliforniaSpacing.xl,
    'xxl': CaliforniaSpacing.xxl,
    'xxxl': CaliforniaSpacing.xxxl,
    'huge': CaliforniaSpacing.huge,
    'massive': CaliforniaSpacing.massive,
  };

  return ListView(
    padding: const EdgeInsets.all(24),
    shrinkWrap: true,
    children: [
      for (final entry in steps.entries)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text('${entry.key} (${entry.value.toInt()}px)'),
              ),
              Container(
                width: entry.value,
                height: 16,
                color: CaliforniaColors.brandPrimary,
              ),
            ],
          ),
        ),
    ],
  );
}
