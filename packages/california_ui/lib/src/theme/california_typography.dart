import 'package:california_ui/src/theme/california_colors.dart';
import 'package:flutter/widgets.dart';

/// The DM Sans font family bundled with California UI.
///
/// Registered via this package's `pubspec.yaml` (`assets/fonts/`). Consumers
/// do not need to declare the font themselves.
const String californiaFontFamily = 'DM Sans';

/// DM Sans type-scale tokens for California UI, matching the text styles
/// defined in the Figma design system (Headings H1–H6, Paragraph P12–P16).
///
/// Every style defaults to [CaliforniaColors.textPrimary]. Use
/// [TextStyle.copyWith] to override color for a specific context, e.g.:
///
/// ```dart
/// Text('$46', style: CaliforniaTypography.h5.copyWith(
///   color: CaliforniaColors.textBrand,
/// ));
/// ```
///
/// This class is not meant to be instantiated.
abstract final class CaliforniaTypography {
  /// Bold, 24px, 130% line height. Page/screen titles (e.g. "Search").
  static const TextStyle h1 = TextStyle(
    fontFamily: californiaFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: CaliforniaColors.textPrimary,
  );

  /// Bold, 20px, 130% line height.
  static const TextStyle h2 = TextStyle(
    fontFamily: californiaFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: CaliforniaColors.textPrimary,
  );

  /// Bold, 18px, 130% line height.
  static const TextStyle h3 = TextStyle(
    fontFamily: californiaFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: CaliforniaColors.textPrimary,
  );

  /// Bold, 16px, 130% line height. Section headers, form field titles.
  static const TextStyle h4 = TextStyle(
    fontFamily: californiaFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: CaliforniaColors.textPrimary,
  );

  /// Bold, 14px, 130% line height. Card titles (e.g. hotel name), prices.
  static const TextStyle h5 = TextStyle(
    fontFamily: californiaFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: CaliforniaColors.textPrimary,
  );

  /// Bold, 12px, 130% line height. Small labels (e.g. coupon codes).
  static const TextStyle h6 = TextStyle(
    fontFamily: californiaFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: CaliforniaColors.textPrimary,
  );

  /// Medium, 16px, 130% line height. Emphasized body copy, input titles.
  static const TextStyle p16Medium = TextStyle(
    fontFamily: californiaFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: CaliforniaColors.textPrimary,
  );

  /// Regular, 16px, 160% line height. Default body copy.
  static const TextStyle p16Regular = TextStyle(
    fontFamily: californiaFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: CaliforniaColors.textPrimary,
  );

  /// Medium, 14px, 130% line height. Emphasized secondary copy.
  static const TextStyle p14Medium = TextStyle(
    fontFamily: californiaFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: CaliforniaColors.textPrimary,
  );

  /// Regular, 14px, 160% line height. Input values, body copy.
  static const TextStyle p14Regular = TextStyle(
    fontFamily: californiaFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: CaliforniaColors.textPrimary,
  );

  /// Medium, 12px, 130% line height. Nav bar labels, small emphasized tags.
  static const TextStyle p12Medium = TextStyle(
    fontFamily: californiaFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: CaliforniaColors.textPrimary,
  );

  /// Regular, 12px, 160% line height. Captions, timestamps, helper text.
  static const TextStyle p12Regular = TextStyle(
    fontFamily: californiaFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: CaliforniaColors.textPrimary,
  );
}
