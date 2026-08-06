import 'package:california_ui/src/theme/california_colors.dart';
import 'package:california_ui/src/theme/california_spacing.dart';
import 'package:california_ui/src/theme/california_typography.dart';
import 'package:flutter/widgets.dart';

/// California UI's selector chip — a tappable pill that toggles between a
/// selected and unselected state, for filter chips, amenity toggles,
/// room-type pickers, and similar single/multi-choice option lists.
///
/// Like `CaliforniaCheckbox`, this has no dedicated frame in the source
/// Figma "Components" page — it's derived from the kit's established
/// language: [CaliforniaColors.brandTertiary] fill with a brand border and
/// brand text when selected (echoing the input field's focused-border
/// treatment), a neutral outline when not.
///
/// This is a controlled widget: it does not own its own selected state.
/// Wire [onSelected] to your own state management and pass the resulting
/// value back in as [selected]. For a group of mutually-exclusive or
/// multi-select chips, manage the set of selected values in the parent and
/// build one [CaliforniaSelector] per option.
///
/// ```dart
/// Wrap(
///   spacing: CaliforniaSpacing.sm,
///   children: [
///     for (final amenity in amenities)
///       CaliforniaSelector(
///         label: amenity.label,
///         selected: state.selectedAmenities.contains(amenity),
///         onSelected: (selected) => context
///             .read<FiltersCubit>()
///             .toggleAmenity(amenity, selected),
///       ),
///   ],
/// )
/// ```
class CaliforniaSelector extends StatelessWidget {
  /// Creates a California UI selector chip.
  const CaliforniaSelector({
    required this.label,
    required this.selected,
    super.key,
    this.icon,
    this.onSelected,
  });

  /// Chip label. Supply an already-localized string.
  final String label;

  /// Whether this chip is currently selected.
  final bool selected;

  /// Optional leading icon.
  final IconData? icon;

  /// Called with the new selected state when tapped. If null, the chip
  /// renders disabled and ignores taps.
  final ValueChanged<bool>? onSelected;

  bool get _isDisabled => onSelected == null;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color border;
    final Color content;

    if (_isDisabled) {
      background = CaliforniaColors.surfaceMuted;
      border = CaliforniaColors.borderDefault;
      content = CaliforniaColors.textSecondary;
    } else if (selected) {
      background = CaliforniaColors.brandTertiary;
      border = CaliforniaColors.brandPrimary;
      content = CaliforniaColors.brandPrimary;
    } else {
      background = CaliforniaColors.surfaceElevated;
      border = CaliforniaColors.borderDefault;
      content = CaliforniaColors.textSecondary;
    }

    return GestureDetector(
      onTap: _isDisabled ? null : () => onSelected!(!selected),
      child: Semantics(
        button: true,
        selected: selected,
        enabled: !_isDisabled,
        label: label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(
            horizontal: CaliforniaSpacing.xl,
            vertical: CaliforniaSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: content),
                const SizedBox(width: CaliforniaSpacing.sm),
              ],
              Text(
                label,
                style: CaliforniaTypography.p12Medium.copyWith(
                  color: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
