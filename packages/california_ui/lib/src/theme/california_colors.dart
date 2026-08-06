import 'package:flutter/widgets.dart';

/// Raw color swatches from the Figma "Colours" page (node `1:50729`).
///
/// Grouped by hue with numbered steps (`01` = base tone, `02`/`03` =
/// progressively lighter tints), mirroring the naming used in the Figma
/// file's color styles.
///
/// Prefer [CaliforniaColors]'s semantic tokens in widget code — reach for
/// [CaliforniaPalette] directly only when no semantic role fits yet (e.g. a
/// one-off chart series color).
abstract final class CaliforniaPalette {
  // Blue — primary brand hue.
  static const Color blue01 = Color(0xFF3D5BF6);
  static const Color blue02 = Color(0xFF7F9EF9);
  static const Color blue03 = Color(0xFF9FB6FA);

  // Black — light-mode ink scale.
  static const Color black01 = Color(0xFF151B33);
  static const Color black02 = Color(0xFF636777);
  static const Color black03 = Color(0xFF8A8D99);

  // White.
  static const Color white01 = Color(0xFFFFFFFF);
  static const Color white02 = Color(0xFFD4D4D4);
  static const Color white03 = Color(0xFFAAAAAA);

  // Grey — borders and secondary text.
  static const Color grey01 = Color(0xFFA7AEC1);
  static const Color grey02 = Color(0xFFC4C9D6);
  static const Color grey03 = Color(0xFFE2E4EA);

  // Light grey — muted surfaces.
  static const Color lightGrey01 = Color(0xFFF9F9F9);
  static const Color lightGrey02 = Color(0xFFE7E7E7);
  static const Color lightGrey03 = Color(0xFFCFCFCF);

  // Green — success / positive feedback.
  static const Color green01 = Color(0xFF13B97D);
  static const Color green02 = Color(0xFF62D0A8);
  static const Color green03 = Color(0xFFB0E8D4);

  // Yellow — warning / highlight feedback.
  static const Color yellow01 = Color(0xFFFFBA55);
  static const Color yellow02 = Color(0xFFFFD18E);
  static const Color yellow03 = Color(0xFFFFE8C6);

  // Red — error / destructive feedback.
  static const Color red01 = Color(0xFFFF4747);
  static const Color red02 = Color(0xFFFF8484);
  static const Color red03 = Color(0xFFFFC2C2);

  // Dark mode — ink scale for dark surfaces.
  static const Color darkBlack01 = Color(0xFF111315);
  static const Color darkBlack02 = Color(0xFF202427);
  static const Color darkBlack03 = Color(0xFF292E32);
}

/// Semantic (role-based) color tokens for California UI.
///
/// Built on top of [CaliforniaPalette]. Widgets should always reach for a
/// semantic token here rather than a raw palette swatch, so a future palette
/// change only requires updating this file, not every call site.
///
/// This class is not meant to be instantiated.
abstract final class CaliforniaColors {
  // ---------------------------------------------------------------------
  // Surfaces
  // ---------------------------------------------------------------------

  /// Default page/screen background.
  static const Color surfacePrimary = CaliforniaPalette.white01;

  /// Background for cards, inputs, and other elevated surfaces.
  static const Color surfaceElevated = CaliforniaPalette.white01;

  /// Subtle background fill, e.g. unselected chips or skeletons.
  static const Color surfaceMuted = CaliforniaPalette.lightGrey01;

  // ---------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------

  /// Primary text color (headings, body copy).
  static const Color textPrimary = CaliforniaPalette.black01;

  /// Secondary text color (captions, timestamps, placeholders).
  static const Color textSecondary = CaliforniaPalette.grey01;

  /// Tertiary text color, one step quieter than [textSecondary].
  static const Color textTertiary = CaliforniaPalette.black03;

  /// Text color for content rendered over a solid brand/dark background.
  static const Color textOnBrand = CaliforniaPalette.white01;

  /// Text/icon color used for interactive/brand-colored text (links, active
  /// tab labels, prices).
  static const Color textBrand = CaliforniaPalette.blue01;

  // ---------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------

  /// Primary brand color. Drives active states, primary buttons, and links.
  static const Color brandPrimary = CaliforniaPalette.blue01;

  /// Lighter brand tint, e.g. secondary accents or hover states.
  static const Color brandSecondary = CaliforniaPalette.blue02;

  /// Softest brand tint, e.g. selected-chip backgrounds.
  static const Color brandTertiary = CaliforniaPalette.blue03;

  // ---------------------------------------------------------------------
  // Borders & dividers
  // ---------------------------------------------------------------------

  /// Default (unfocused) border color for inputs and outlined surfaces.
  static const Color borderDefault = CaliforniaPalette.grey03;

  /// Border color for a focused/selected interactive element.
  static const Color borderFocused = CaliforniaPalette.blue01;

  /// Divider/hairline color.
  static const Color divider = CaliforniaPalette.lightGrey02;

  // ---------------------------------------------------------------------
  // State / feedback
  // ---------------------------------------------------------------------

  /// Disabled fill for buttons and controls.
  static const Color disabled = CaliforniaPalette.grey02;

  /// Disabled text/icon color, used on top of [disabled] fills.
  static const Color disabledOn = CaliforniaPalette.white01;

  /// Success / positive feedback color.
  static const Color success = CaliforniaPalette.green01;

  /// Success feedback color, softened for backgrounds/badges.
  static const Color successMuted = CaliforniaPalette.green03;

  /// Warning / caution feedback color.
  static const Color warning = CaliforniaPalette.yellow01;

  /// Warning feedback color, softened for backgrounds/badges.
  static const Color warningMuted = CaliforniaPalette.yellow03;

  /// Error / destructive feedback color.
  static const Color error = CaliforniaPalette.red01;

  /// Error feedback color, softened for backgrounds/badges.
  static const Color errorMuted = CaliforniaPalette.red03;

  // ---------------------------------------------------------------------
  // Dark mode
  // ---------------------------------------------------------------------

  /// Base background for dark-mode surfaces.
  static const Color surfacePrimaryDark = CaliforniaPalette.darkBlack01;

  /// Elevated surface background in dark mode (cards, sheets).
  static const Color surfaceElevatedDark = CaliforniaPalette.darkBlack02;

  /// Border color for dark-mode surfaces.
  static const Color borderDefaultDark = CaliforniaPalette.darkBlack03;
}
