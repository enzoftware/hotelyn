import 'package:california_ui/src/theme/california_colors.dart';
import 'package:california_ui/src/theme/california_spacing.dart';
import 'package:california_ui/src/theme/california_typography.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

/// California UI's text input field.
///
/// Supports two shapes, mirroring the Figma "Form Input" component:
///
///  * The default constructor renders a free-typing field, optionally with
///    a [leadingIcon] (e.g. a user icon for a name field).
///  * [CaliforniaInputField.selector] renders a read-only, tappable field
///    with a trailing chevron — used for dropdowns, pickers, and any field
///    whose value is chosen rather than typed (e.g. "Room Type", date
///    pickers, currency/quantity selects).
///
/// The field's visual state (default / typing / filled / focused-selected)
/// is derived automatically from [controller] and [FocusNode] state, so
/// callers don't need to track it manually.
///
/// ```dart
/// CaliforniaInputField(
///   title: context.l10n.guestNameLabel,
///   placeholder: context.l10n.guestNamePlaceholder,
///   controller: _nameController,
///   leadingIcon: CupertinoIcons.person,
/// )
///
/// CaliforniaInputField.selector(
///   title: context.l10n.roomTypeLabel,
///   value: state.selectedRoomType?.label,
///   placeholder: context.l10n.roomTypePlaceholder,
///   onTap: () => _showRoomTypePicker(context),
/// )
/// ```
class CaliforniaInputField extends StatefulWidget {
  /// Creates a free-typing California UI input field.
  const CaliforniaInputField({
    required this.title,
    required this.placeholder,
    super.key,
    this.controller,
    this.leadingIcon,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
  }) : isSelector = false,
       value = null,
       onTap = null;

  /// Creates a read-only "selector" field: tap it to open a picker/dropdown
  /// (e.g. a bottom sheet, a date picker) rather than typing directly.
  ///
  /// [value] is the currently chosen option's display text, shown in place
  /// of [placeholder] once non-null.
  const CaliforniaInputField.selector({
    required this.title,
    required this.placeholder,
    super.key,
    this.value,
    this.onTap,
    this.enabled = true,
  }) : isSelector = true,
       controller = null,
       leadingIcon = null,
       keyboardType = null,
       obscureText = false,
       onChanged = null,
       onSubmitted = null;

  /// Label shown above the field.
  final String title;

  /// Text shown when the field is empty (or, for a selector, unselected).
  final String placeholder;

  /// Text-editing controller. Only used by the free-typing constructor.
  final TextEditingController? controller;

  /// Icon shown at the leading edge of a free-typing field.
  final IconData? leadingIcon;

  /// Keyboard type for a free-typing field.
  final TextInputType? keyboardType;

  /// Whether to obscure input, e.g. for passwords.
  final bool obscureText;

  /// Whether the field accepts input/taps.
  final bool enabled;

  /// Called on every keystroke in a free-typing field.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits a free-typing field via the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// The selector's currently-chosen display value, if any.
  final String? value;

  /// Called when a selector field is tapped.
  final VoidCallback? onTap;

  /// Whether this instance was built via [CaliforniaInputField.selector].
  final bool isSelector;

  @override
  State<CaliforniaInputField> createState() => _CaliforniaInputFieldState();
}

class _CaliforniaInputFieldState extends State<CaliforniaInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    widget.controller?.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(CaliforniaInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChange);
      widget.controller?.addListener(_handleControllerChange);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    widget.controller?.removeListener(_handleControllerChange);
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  void _handleControllerChange() {
    setState(() {});
  }

  bool get _isFilled => widget.isSelector
      ? widget.value != null && widget.value!.isNotEmpty
      : (widget.controller?.text.isNotEmpty ?? false);

  Color get _borderColor {
    if (_hasFocus) return CaliforniaColors.borderFocused;
    return CaliforniaColors.borderDefault;
  }

  Color get _contentColor {
    if (_hasFocus || _isFilled) return CaliforniaColors.textPrimary;
    return CaliforniaColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.title, style: CaliforniaTypography.p16Medium),
        const SizedBox(height: CaliforniaSpacing.lg),
        _buildField(context),
      ],
    );
  }

  Widget _buildField(BuildContext context) {
    final field = DecoratedBox(
      decoration: BoxDecoration(
        color: CaliforniaColors.surfaceElevated,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26A7AEC1),
            blurRadius: 35,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CaliforniaSpacing.xxl,
          vertical: CaliforniaSpacing.xxl,
        ),
        child: Row(
          children: [
            if (widget.leadingIcon != null) ...[
              Icon(widget.leadingIcon, size: 20, color: _contentColor),
              const SizedBox(width: CaliforniaSpacing.lg),
            ],
            Expanded(child: _buildContent(context)),
            if (widget.isSelector) ...[
              const SizedBox(width: CaliforniaSpacing.lg),
              Icon(
                CupertinoIcons.chevron_down,
                size: 16,
                color: _contentColor,
              ),
            ],
          ],
        ),
      ),
    );

    if (!widget.isSelector) return field;

    return FocusableActionDetector(
      enabled: widget.enabled,
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<Intent>(
          onInvoke: (intent) => widget.enabled ? widget.onTap?.call() : null,
        ),
      },
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: field,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final style = CaliforniaTypography.p14Regular.copyWith(
      color: _contentColor,
    );

    if (widget.isSelector) {
      return Text(
        widget.value ?? widget.placeholder,
        style: style,
        overflow: TextOverflow.ellipsis,
      );
    }

    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      onChanged: (value) {
        setState(() {});
        widget.onChanged?.call(value);
      },
      onSubmitted: widget.onSubmitted,
      style: style,
      cursorColor: CaliforniaColors.brandPrimary,
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: style.copyWith(color: CaliforniaColors.textSecondary),
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
