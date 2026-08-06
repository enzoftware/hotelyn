import 'package:california_ui/src/theme/california_colors.dart';
import 'package:california_ui/src/theme/california_spacing.dart';
import 'package:california_ui/src/theme/california_typography.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';

/// California UI's screen-level top bar, in the shapes defined by the
/// Figma "App Bar" component (node `2:52338`).
///
/// Each named constructor mirrors one of that component's variants. All
/// variants render as a fixed-height [PreferredSizeWidget] so they can be
/// dropped straight into `Scaffold.appBar` (Material) or an equivalent
/// Cupertino/custom scaffold.
///
/// This widget never draws the OS status bar (clock/battery/signal) shown
/// in the Figma frame — that's simulator chrome, not part of the
/// reusable component.
///
/// ```dart
/// CaliforniaTopBar.general(
///   title: context.l10n.settingsTitle,
///   onBack: () => Navigator.of(context).pop(),
///   onMenuTap: () => _openOverflowMenu(context),
/// )
///
/// CaliforniaTopBar.mainScreen(
///   title: context.l10n.searchTitle,
///   hasUnreadNotifications: state.hasUnread,
///   onNotificationsTap: () => context.push('/notifications'),
/// )
/// ```
class CaliforniaTopBar extends StatelessWidget implements PreferredSizeWidget {
  /// A centered title with an optional leading back button and an optional
  /// trailing overflow ("more") button. Figma variant: `General`.
  const CaliforniaTopBar.general({
    required this.title,
    super.key,
    this.onBack,
    this.onMenuTap,
  }) : _variant = _CaliforniaTopBarVariant.general,
       leading = null,
       trailing = null,
       onSearchTap = null,
       hasUnreadNotifications = false,
       onNotificationsTap = null;

  /// A large, left-aligned screen title with a trailing notification bell.
  /// Figma variant: `Main Screen`.
  const CaliforniaTopBar.mainScreen({
    required this.title,
    super.key,
    this.hasUnreadNotifications = false,
    this.onNotificationsTap,
  }) : _variant = _CaliforniaTopBarVariant.mainScreen,
       leading = null,
       trailing = null,
       onBack = null,
       onMenuTap = null,
       onSearchTap = null;

  /// A back button beside a rounded search box showing [title] as the
  /// current search query/location. Figma variant: `Search by Map`.
  const CaliforniaTopBar.searchByMap({
    required this.title,
    super.key,
    this.onBack,
    this.onSearchTap,
  }) : _variant = _CaliforniaTopBarVariant.searchByMap,
       leading = null,
       trailing = null,
       onMenuTap = null,
       hasUnreadNotifications = false,
       onNotificationsTap = null;

  /// A back button plus [trailing] actions (e.g. share/like), floating over
  /// a transparent/blurred background — meant to sit on top of a product's
  /// hero image. Figma variant: `Detail Product`.
  const CaliforniaTopBar.detailProduct({
    super.key,
    this.onBack,
    this.trailing,
  }) : _variant = _CaliforniaTopBarVariant.detailProduct,
       title = null,
       leading = null,
       onMenuTap = null,
       onSearchTap = null,
       hasUnreadNotifications = false,
       onNotificationsTap = null;

  /// A back button, a conversation partner's avatar + name/status
  /// ([leading]), and a trailing overflow button. Figma variant: `Message`.
  const CaliforniaTopBar.message({
    required this.leading,
    super.key,
    this.onBack,
    this.onMenuTap,
  }) : _variant = _CaliforniaTopBarVariant.message,
       title = null,
       trailing = null,
       onSearchTap = null,
       hasUnreadNotifications = false,
       onNotificationsTap = null;

  final _CaliforniaTopBarVariant _variant;

  /// Screen title. Used by [CaliforniaTopBar.general],
  /// [CaliforniaTopBar.mainScreen], and [CaliforniaTopBar.searchByMap] (as
  /// the search box's query text).
  final String? title;

  /// Leading content, e.g. an avatar + name/status column for
  /// [CaliforniaTopBar.message].
  final Widget? leading;

  /// Trailing content, e.g. share/like buttons for
  /// [CaliforniaTopBar.detailProduct].
  final Widget? trailing;

  /// Called when the back button is tapped. Omit to hide the back button.
  final VoidCallback? onBack;

  /// Called when the overflow ("more") button is tapped.
  final VoidCallback? onMenuTap;

  /// Called when the search box is tapped.
  final VoidCallback? onSearchTap;

  /// Whether to show the notification-bell's unread dot.
  final bool hasUnreadNotifications;

  /// Called when the notification bell is tapped.
  final VoidCallback? onNotificationsTap;

  @override
  Size get preferredSize => const Size.fromHeight(94);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CaliforniaSpacing.massive,
            vertical: CaliforniaSpacing.xxl,
          ),
          child: switch (_variant) {
            _CaliforniaTopBarVariant.general => _buildGeneral(),
            _CaliforniaTopBarVariant.mainScreen => _buildMainScreen(),
            _CaliforniaTopBarVariant.searchByMap => _buildSearchByMap(),
            _CaliforniaTopBarVariant.detailProduct => _buildDetailProduct(),
            _CaliforniaTopBarVariant.message => _buildMessage(),
          },
        ),
      ),
    );
  }

  Widget _buildGeneral() {
    return Row(
      children: [
        _CaliforniaTopBarCircleButton(
          icon: CupertinoIcons.back,
          onTap: onBack,
        ),
        Expanded(
          child: Text(
            title ?? '',
            textAlign: TextAlign.center,
            style: CaliforniaTypography.p16Medium,
          ),
        ),
        _CaliforniaTopBarCircleButton(
          icon: CupertinoIcons.ellipsis,
          onTap: onMenuTap,
        ),
      ],
    );
  }

  Widget _buildMainScreen() {
    return Row(
      children: [
        Expanded(child: Text(title ?? '', style: CaliforniaTypography.h1)),
        _CaliforniaTopBarCircleButton(
          icon: CupertinoIcons.bell,
          onTap: onNotificationsTap,
          showBadge: hasUnreadNotifications,
        ),
      ],
    );
  }

  Widget _buildSearchByMap() {
    return Row(
      children: [
        _CaliforniaTopBarCircleButton(
          icon: CupertinoIcons.back,
          onTap: onBack,
        ),
        const SizedBox(width: CaliforniaSpacing.xxxl),
        Expanded(
          child: GestureDetector(
            onTap: onSearchTap,
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(
                horizontal: CaliforniaSpacing.huge,
              ),
              decoration: BoxDecoration(
                color: CaliforniaColors.surfaceElevated,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: CaliforniaColors.borderDefault),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.search,
                    size: 20,
                    color: CaliforniaColors.textSecondary,
                  ),
                  const SizedBox(width: CaliforniaSpacing.xl),
                  Expanded(
                    child: Text(
                      title ?? '',
                      style: CaliforniaTypography.p14Regular,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.slider_horizontal_3,
                    size: 20,
                    color: CaliforniaColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailProduct() {
    return Row(
      children: [
        _CaliforniaTopBarCircleButton(
          icon: CupertinoIcons.back,
          onTap: onBack,
          scrim: true,
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }

  Widget _buildMessage() {
    return Row(
      children: [
        _CaliforniaTopBarCircleButton(
          icon: CupertinoIcons.back,
          onTap: onBack,
        ),
        const SizedBox(width: CaliforniaSpacing.xxl),
        Expanded(child: leading ?? const SizedBox.shrink()),
        _CaliforniaTopBarCircleButton(
          icon: CupertinoIcons.ellipsis,
          onTap: onMenuTap,
        ),
      ],
    );
  }
}

enum _CaliforniaTopBarVariant {
  general,
  mainScreen,
  searchByMap,
  detailProduct,
  message,
}

/// A round, elevated icon button used throughout [CaliforniaTopBar].
///
/// Exposed for callers building custom top-bar actions (e.g.
/// [CaliforniaTopBar.detailProduct]'s `trailing` slot) who want the same
/// circular-button look as the built-in back/menu buttons.
class CaliforniaTopBarCircleButton extends StatelessWidget {
  /// Creates a circular icon button matching California UI's top-bar style.
  const CaliforniaTopBarCircleButton({
    required this.icon,
    super.key,
    this.onTap,
    this.scrim = false,
  });

  /// Icon to display.
  final IconData icon;

  /// Called when tapped. If null, the button renders but is inert.
  final VoidCallback? onTap;

  /// Whether to use the frosted/scrim style (for buttons floating over an
  /// image, as in [CaliforniaTopBar.detailProduct]) instead of the default
  /// solid-white elevated style.
  final bool scrim;

  @override
  Widget build(BuildContext context) {
    return _CaliforniaTopBarCircleButton(
      icon: icon,
      onTap: onTap,
      scrim: scrim,
    );
  }
}

class _CaliforniaTopBarCircleButton extends StatelessWidget {
  const _CaliforniaTopBarCircleButton({
    required this.icon,
    this.onTap,
    this.scrim = false,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool scrim;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scrim
                  ? const Color(0x59151B33)
                  : CaliforniaColors.surfaceElevated,
              boxShadow: scrim
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x4DA7AEC1),
                        blurRadius: 80,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            child: Icon(
              icon,
              size: 24,
              color: scrim
                  ? CaliforniaColors.surfaceElevated
                  : CaliforniaColors.textPrimary,
            ),
          ),
          if (showBadge)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: CaliforniaColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
