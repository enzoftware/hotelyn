import 'package:california_ui/src/theme/california_colors.dart';
import 'package:california_ui/src/theme/california_spacing.dart';
import 'package:california_ui/src/theme/california_typography.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';

/// California UI's checkbox.
///
/// Not part of the source Figma "Components" page — the kit has no
/// dedicated checkbox spec — so this is derived from the design system's
/// established language: a [CaliforniaColors.brandPrimary]-filled,
/// rounded-square box with a check glyph when selected, and a
/// [CaliforniaColors.borderDefault] outline when not, matching
/// `CaliforniaInputField`'s corner treatment and border colors.
///
/// This is a controlled widget: it does not own its own checked state.
/// Wire [onChanged] to your own state management and pass the resulting
/// value back in as [value].
///
/// ```dart
/// CaliforniaCheckbox(
///   value: state.acceptedTerms,
///   label: context.l10n.acceptTerms,
///   onChanged: (value) => context.read<RegisterBloc>().add(
///     TermsAccepted(value),
///   ),
/// )
/// ```
class CaliforniaCheckbox extends StatelessWidget {
  /// Creates a California UI checkbox, optionally with a trailing [label].
  const CaliforniaCheckbox({
    required this.value,
    super.key,
    this.label,
    this.onChanged,
  });

  /// Whether the checkbox is checked.
  final bool value;

  /// Optional label shown beside the box. Supply an already-localized
  /// string. Tapping the label toggles the checkbox, same as the box
  /// itself.
  final String? label;

  /// Called with the new value when tapped. If null, the checkbox renders
  /// disabled and ignores taps.
  final ValueChanged<bool>? onChanged;

  bool get _isDisabled => onChanged == null;

  @override
  Widget build(BuildContext context) {
    final box = _CaliforniaCheckboxBox(value: value, disabled: _isDisabled);

    return GestureDetector(
      onTap: _isDisabled ? null : () => onChanged!(!value),
      child: Semantics(
        checked: value,
        enabled: !_isDisabled,
        label: label,
        child: label == null
            ? box
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  box,
                  const SizedBox(width: CaliforniaSpacing.sm),
                  Text(
                    label!,
                    style: CaliforniaTypography.p14Regular.copyWith(
                      color: _isDisabled
                          ? CaliforniaColors.textSecondary
                          : CaliforniaColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CaliforniaCheckboxBox extends StatelessWidget {
  const _CaliforniaCheckboxBox({required this.value, required this.disabled});

  final bool value;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final Color fillColor;
    final Color borderColor;

    if (disabled) {
      fillColor = value
          ? CaliforniaColors.disabled
          : CaliforniaColors.surfaceElevated;
      borderColor = CaliforniaColors.disabled;
    } else if (value) {
      fillColor = CaliforniaColors.brandPrimary;
      borderColor = CaliforniaColors.brandPrimary;
    } else {
      fillColor = CaliforniaColors.surfaceElevated;
      borderColor = CaliforniaColors.borderDefault;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: value
          ? const Icon(
              CupertinoIcons.check_mark,
              size: 14,
              color: CaliforniaColors.textOnBrand,
            )
          : null,
    );
  }
}
