import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: CaliforniaSelector)
Widget buildCaliforniaSelectorInteractiveUseCase(BuildContext context) {
  return _InteractiveSelector(
    initialSelected: context.knobs.boolean(label: 'initial selected'),
    label: context.knobs.string(label: 'label', initialValue: 'Wifi'),
    withIcon: context.knobs.boolean(label: 'with icon', initialValue: true),
    enabled: context.knobs.boolean(label: 'enabled', initialValue: true),
  );
}

@widgetbook.UseCase(name: 'All states', type: CaliforniaSelector)
Widget buildCaliforniaSelectorAllStatesUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        CaliforniaSelector(
          label: 'Unselected',
          selected: false,
          onSelected: (_) {},
        ),
        CaliforniaSelector(
          label: 'Selected',
          selected: true,
          onSelected: (_) {},
        ),
        CaliforniaSelector(
          label: 'With icon',
          icon: CupertinoIcons.wifi,
          selected: true,
          onSelected: (_) {},
        ),
        const CaliforniaSelector(label: 'Disabled', selected: false),
      ],
    ),
  );
}

/// Wraps [CaliforniaSelector] with local state so its `Interactive`
/// use-case is actually toggleable in the Widgetbook UI.
class _InteractiveSelector extends StatefulWidget {
  const _InteractiveSelector({
    required this.initialSelected,
    required this.label,
    required this.withIcon,
    required this.enabled,
  });

  final bool initialSelected;
  final String label;
  final bool withIcon;
  final bool enabled;

  @override
  State<_InteractiveSelector> createState() => _InteractiveSelectorState();
}

class _InteractiveSelectorState extends State<_InteractiveSelector> {
  late bool _selected = widget.initialSelected;

  @override
  void didUpdateWidget(_InteractiveSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelected != widget.initialSelected) {
      _selected = widget.initialSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CaliforniaSelector(
      label: widget.label,
      icon: widget.withIcon ? CupertinoIcons.wifi : null,
      selected: _selected,
      onSelected: widget.enabled
          ? (value) => setState(() => _selected = value)
          : null,
    );
  }
}
