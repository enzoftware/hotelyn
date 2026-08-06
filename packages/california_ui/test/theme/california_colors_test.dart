import 'dart:ui';

import 'package:california_ui/california_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaliforniaColors', () {
    test('brandPrimary matches the Figma primary blue', () {
      expect(CaliforniaColors.brandPrimary, const Color(0xFF3D5BF6));
    });

    test('textPrimary matches the Figma primary black', () {
      expect(CaliforniaColors.textPrimary, const Color(0xFF151B33));
    });

    test('surfacePrimary matches the Figma white', () {
      expect(CaliforniaColors.surfacePrimary, const Color(0xFFFFFFFF));
    });

    test('error matches the Figma red', () {
      expect(CaliforniaColors.error, const Color(0xFFFF4747));
    });

    test('surfacePrimaryDark matches the Figma dark-mode black', () {
      expect(CaliforniaColors.surfacePrimaryDark, const Color(0xFF111315));
    });
  });

  group('CaliforniaPalette', () {
    test('exposes numbered tints per hue', () {
      expect(CaliforniaPalette.blue01, const Color(0xFF3D5BF6));
      expect(CaliforniaPalette.blue02, const Color(0xFF7F9EF9));
      expect(CaliforniaPalette.blue03, const Color(0xFF9FB6FA));
    });
  });
}
