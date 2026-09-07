import 'package:california_ui/src/theme/california_colors.dart';
import 'package:california_ui/src/theme/california_spacing.dart';
import 'package:california_ui/src/theme/california_typography.dart';
import 'package:flutter/widgets.dart';

/// Size variants for [CaliforniaButton], matching the Figma "Button"
/// component's `Property 1` axis (node `234:6429`).
enum CaliforniaButtonSize {
  /// Full-width button, 327×54, 16px bold label.
  large,

  /// Medium-width button, 258×54, 14px bold label.
  medium,

  /// Narrow button, 173×54, 15px bold label.
  small,
}

/// California UI's button, in the sizes and styles defined by the Figma
/// "Button" component (node `234:6429`).
///
/// Combine a [CaliforniaButtonSize] with one of the three named
/// constructors for style:
///
///  * [CaliforniaButton.primary] — solid brand fill, white label
///    ("Active" in Figma). Disabled automatically when [onPressed] is null
///    ("Dissable" in Figma) — no separate `enabled` flag to keep in sync.
///  * [CaliforniaButton.ghost] — transparent, brand-colored label and no
///    fill, for secondary actions.
///
/// ```dart
/// CaliforniaButton.primary(
///   label: context.l10n.confirmBooking,
///   onPressed: canConfirm ? _handleConfirm : null,
/// )
///
/// CaliforniaButton.ghost(
///   label: context.l10n.cancel,
///   size: CaliforniaButtonSize.small,
///   onPressed: _handleCancel,
/// )
/// ```
class CaliforniaButton extends StatelessWidget {
  /// Creates a solid, brand-filled button. Renders in its disabled style
  /// automatically when [onPressed] is null.
  const CaliforniaButton.primary({
    required this.label,
    required this.onPressed,
    super.key,
    this.size = CaliforniaButtonSize.large,
    this.width,
    this.height,
  }) : _isGhost = false;

  /// Creates a transparent button with a brand-colored label, for
  /// secondary/tertiary actions.
  const CaliforniaButton.ghost({
    required this.label,
    required this.onPressed,
    super.key,
    this.size = CaliforniaButtonSize.large,
    this.width,
    this.height,
  }) : _isGhost = true;

  /// Button label. Supply an already-localized string.
  final String label;

  /// Called when tapped. If null, the button renders disabled and ignores
  /// taps — this is the only way to disable [CaliforniaButton.primary].
  final VoidCallback? onPressed;

  /// The button's width/height/font-size variant.
  final CaliforniaButtonSize size;

  /// Optional explicit width override.
  final double? width;

  /// Optional explicit height override.
  final double? height;

  final bool _isGhost;

  bool get _isDisabled => onPressed == null;

  double get _width => switch (size) {
    CaliforniaButtonSize.large => 327,
    CaliforniaButtonSize.medium => 258,
    CaliforniaButtonSize.small => 173,
  };

  double get _borderRadius => switch (size) {
    CaliforniaButtonSize.large => 46,
    CaliforniaButtonSize.medium => 40,
    CaliforniaButtonSize.small => 46,
  };

  TextStyle get _textStyle {
    final base = switch (size) {
      CaliforniaButtonSize.large => CaliforniaTypography.h5,
      CaliforniaButtonSize.medium => CaliforniaTypography.h5,
      CaliforniaButtonSize.small => CaliforniaTypography.p16Medium.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.6,
      ),
    };

    if (_isGhost) return base.copyWith(color: CaliforniaColors.brandPrimary);
    return base.copyWith(color: CaliforniaColors.textOnBrand);
  }

  Color? get _backgroundColor {
    if (_isGhost) return null;
    if (_isDisabled) return CaliforniaColors.disabled;
    return CaliforniaColors.brandPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      enabled: !_isDisabled,
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<Intent>(
          onInvoke: (intent) => onPressed?.call(),
        ),
      },
      child: GestureDetector(
        onTap: onPressed,
        child: Semantics(
          button: true,
          enabled: !_isDisabled,
          label: label,
          child: Container(
            width: width ?? _width,
            height: height ?? 54,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              vertical: height != null ? 0 : CaliforniaSpacing.xxxl,
              horizontal: CaliforniaSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _textStyle,
            ),
          ),
        ),
      ),
    );
  }
}
