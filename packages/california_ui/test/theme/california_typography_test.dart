import 'dart:ui';

import 'package:california_ui/california_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaliforniaTypography', () {
    test('h1 is bold 24px on the DM Sans family', () {
      expect(CaliforniaTypography.h1.fontFamily, californiaFontFamily);
      expect(CaliforniaTypography.h1.fontSize, 24);
      expect(CaliforniaTypography.h1.fontWeight, FontWeight.w700);
    });

    test('p14Regular is regular 14px with 160% line height', () {
      expect(CaliforniaTypography.p14Regular.fontSize, 14);
      expect(CaliforniaTypography.p14Regular.fontWeight, FontWeight.w400);
      expect(CaliforniaTypography.p14Regular.height, 1.6);
    });

    test('every style defaults to CaliforniaColors.textPrimary', () {
      for (final style in [
        CaliforniaTypography.h1,
        CaliforniaTypography.h5,
        CaliforniaTypography.p12Regular,
        CaliforniaTypography.p16Medium,
      ]) {
        expect(style.color, CaliforniaColors.textPrimary);
      }
    });
  });
}
