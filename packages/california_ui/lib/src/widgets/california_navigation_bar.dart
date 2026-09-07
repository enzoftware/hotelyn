import 'package:california_ui/src/theme/california_colors.dart';
import 'package:california_ui/src/theme/california_spacing.dart';
import 'package:california_ui/src/theme/california_typography.dart';
import 'package:flutter/widgets.dart';

/// A destination in a [CaliforniaNavigationBar].
///
/// California UI does not hardcode a fixed set of tabs — pass whichever
/// [CaliforniaNavigationBarItem]s the host screen needs, in the order they
/// should appear. Labels are provided by the caller (not this package) so
/// they can flow through the app's own localization.
@immutable
class CaliforniaNavigationBarItem {
  /// Creates a navigation bar destination.
  const CaliforniaNavigationBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  /// Icon shown when this destination is not selected.
  final IconData icon;

  /// Icon shown when this destination is selected.
  final IconData activeIcon;

  /// Label shown below the icon. Supply an already-localized string.
  final String label;
}

/// California UI's bottom navigation bar.
///
/// Renders a row of [items], each with an icon and label. The item at
/// [currentIndex] is highlighted with its `activeIcon`, a brand-colored
/// label, and an underline indicator; other items render muted.
///
/// This is a controlled widget: it does not own selection state itself.
/// Wire [onTap] to your own state management (a `Cubit`, `ValueNotifier`,
/// etc.) and pass the resulting index back in as [currentIndex].
///
/// ```dart
/// CaliforniaNavigationBar(
///   currentIndex: state.tabIndex,
///   onTap: (index) => context.read<NavigationCubit>().select(index),
///   items: [
///     CaliforniaNavigationBarItem(
///       icon: CupertinoIcons.house,
///       activeIcon: CupertinoIcons.house_fill,
///       label: context.l10n.navHome,
///     ),
///     // ...
///   ],
/// )
/// ```
class CaliforniaNavigationBar extends StatelessWidget {
  /// Creates a California UI navigation bar.
  const CaliforniaNavigationBar({
    required this.items,
    required this.currentIndex,
    super.key,
    this.onTap,
  })  : assert(
          items.length >= 2,
          'CaliforniaNavigationBar needs at least 2 items.',
        ),
        assert(
          currentIndex >= 0 && currentIndex < items.length,
          'currentIndex must be a valid index into items.',
        );

  /// The destinations to render, in display order.
  final List<CaliforniaNavigationBarItem> items;

  /// Index into [items] of the currently-selected destination.
  final int currentIndex;

  /// Called with the tapped item's index. If null, the bar is inert.
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CaliforniaColors.surfaceElevated,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CaliforniaSpacing.huge,
            vertical: CaliforniaSpacing.xl,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < items.length; i++)
                _CaliforniaNavigationBarTile(
                  item: items[i],
                  selected: i == currentIndex,
                  onTap: onTap == null ? null : () => onTap!(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaliforniaNavigationBarTile extends StatelessWidget {
  const _CaliforniaNavigationBarTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final CaliforniaNavigationBarItem item;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? CaliforniaColors.brandPrimary
        : CaliforniaColors.textSecondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Semantics(
        selected: selected,
        button: true,
        enabled: onTap != null,
        label: item.label,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: CaliforniaSpacing.xs),
            Text(
              item.label,
              style: CaliforniaTypography.p12Medium.copyWith(color: color),
            ),
            const SizedBox(height: CaliforniaSpacing.md),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 2,
              width: selected ? 32 : 0,
              color: CaliforniaColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
