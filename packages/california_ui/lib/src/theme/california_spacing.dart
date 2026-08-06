/// Spacing tokens for California UI.
///
/// A 4px-based scale derived from the gaps and paddings actually used
/// across the Figma "Components" page (node `1:50903`) — button padding,
/// card gutters, form-field padding, icon/label gaps, etc. Widgets should
/// reach for one of these named steps instead of a raw numeric literal, so
/// spacing stays consistent and a future density change only touches this
/// file.
///
/// Not every raw value in the design maps exactly onto a 4px step (e.g. a
/// `9px` divider gap); in those cases the nearest token is used and the
/// couple of pixels of drift is visually negligible.
///
/// This class is not meant to be instantiated.
abstract final class CaliforniaSpacing {
  /// 2px. Hairline gaps, e.g. between a value and its unit suffix.
  static const double xxs = 2;

  /// 4px. Tightest usable gap — icon-to-label baseline spacing.
  static const double xs = 4;

  /// 6px. Small icon/label gaps.
  static const double sm = 6;

  /// 8px. Compact vertical rhythm, e.g. under a nav bar underline.
  static const double md = 8;

  /// 10px. Default gap between a field's title and its input.
  static const double lg = 10;

  /// 12px. Default padding inside pills, chips, and compact rows.
  static const double xl = 12;

  /// 14px. Input field horizontal padding.
  static const double xxl = 14;

  /// 16px. Button vertical padding; the most common "comfortable" gap.
  static const double xxxl = 16;

  /// 20px. Section padding, e.g. between a screen edge and its content.
  static const double huge = 20;

  /// 24px. Top bar horizontal padding.
  static const double massive = 24;
}
