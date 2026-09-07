import 'package:california_ui/california_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaliforniaSpacing', () {
    test('steps increase monotonically', () {
      const steps = [
        CaliforniaSpacing.xxs,
        CaliforniaSpacing.xs,
        CaliforniaSpacing.sm,
        CaliforniaSpacing.md,
        CaliforniaSpacing.lg,
        CaliforniaSpacing.xl,
        CaliforniaSpacing.xxl,
        CaliforniaSpacing.xxxl,
        CaliforniaSpacing.huge,
        CaliforniaSpacing.massive,
      ];

      for (var i = 1; i < steps.length; i++) {
        expect(
          steps[i],
          greaterThan(steps[i - 1]),
          reason:
              'step $i (${steps[i]}) should exceed step ${i - 1} '
              '(${steps[i - 1]})',
        );
      }
    });

    test('matches the Figma-derived 4px-based scale', () {
      expect(CaliforniaSpacing.xxs, 2);
      expect(CaliforniaSpacing.xs, 4);
      expect(CaliforniaSpacing.sm, 6);
      expect(CaliforniaSpacing.md, 8);
      expect(CaliforniaSpacing.lg, 10);
      expect(CaliforniaSpacing.xl, 12);
      expect(CaliforniaSpacing.xxl, 14);
      expect(CaliforniaSpacing.xxxl, 16);
      expect(CaliforniaSpacing.huge, 20);
      expect(CaliforniaSpacing.massive, 24);
    });
  });
}
