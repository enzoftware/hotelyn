import 'package:california_ui/california_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: CaliforniaCheckbox)
Widget buildCaliforniaCheckboxInteractiveUseCase(BuildContext context) {
  return _InteractiveCheckbox(
    initialValue: context.knobs.boolean(
      label: 'initial value',
    ),
    label: context.knobs.stringOrNull(
      label: 'label',
      initialValue: 'Accept terms and conditions',
    ),
    enabled: context.knobs.boolean(label: 'enabled', initialValue: true),
  );
}

@widgetbook.UseCase(name: 'All states', type: CaliforniaCheckbox)
Widget buildCaliforniaCheckboxAllStatesUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CaliforniaCheckbox(
          value: false,
          label: 'Unchecked',
          onChanged: (_) {},
        ),
        const SizedBox(height: 16),
        CaliforniaCheckbox(
          value: true,
          label: 'Checked',
          onChanged: (_) {},
        ),
        const SizedBox(height: 16),
        const CaliforniaCheckbox(
          value: false,
          label: 'Disabled, unchecked',
        ),
        const SizedBox(height: 16),
        const CaliforniaCheckbox(
          value: true,
          label: 'Disabled, checked',
        ),
        const SizedBox(height: 16),
        CaliforniaCheckbox(value: false, onChanged: (_) {}),
      ],
    ),
  );
}

/// Wraps [CaliforniaCheckbox] with local state so its `Interactive`
/// use-case is actually toggleable in the Widgetbook UI, rather than
/// snapping back to the knob's initial value on every tap.
class _InteractiveCheckbox extends StatefulWidget {
  const _InteractiveCheckbox({
    required this.initialValue,
    required this.enabled,
    this.label,
  });

  final bool initialValue;
  final String? label;
  final bool enabled;

  @override
  State<_InteractiveCheckbox> createState() => _InteractiveCheckboxState();
}

class _InteractiveCheckboxState extends State<_InteractiveCheckbox> {
  late bool _value = widget.initialValue;

  @override
  void didUpdateWidget(_InteractiveCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _value = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CaliforniaCheckbox(
      value: _value,
      label: widget.label,
      onChanged: widget.enabled
          ? (value) => setState(() => _value = value)
          : null,
    );
  }
}
