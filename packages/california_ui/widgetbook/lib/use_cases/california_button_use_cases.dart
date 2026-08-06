import 'package:california_ui/california_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Primary', type: CaliforniaButton)
Widget buildCaliforniaButtonPrimaryUseCase(BuildContext context) {
  return CaliforniaButton.primary(
    label: context.knobs.string(label: 'label', initialValue: 'Button'),
    size: context.knobs.object.dropdown<CaliforniaButtonSize>(
      label: 'size',
      labelBuilder: (value) => value.name,
      options: CaliforniaButtonSize.values,
    ),
    onPressed: context.knobs.boolean(label: 'enabled', initialValue: true)
        ? () {}
        : null,
  );
}

@widgetbook.UseCase(name: 'Ghost', type: CaliforniaButton)
Widget buildCaliforniaButtonGhostUseCase(BuildContext context) {
  return CaliforniaButton.ghost(
    label: context.knobs.string(label: 'label', initialValue: 'Button'),
    size: context.knobs.object.dropdown<CaliforniaButtonSize>(
      label: 'size',
      labelBuilder: (value) => value.name,
      options: CaliforniaButtonSize.values,
    ),
    onPressed: context.knobs.boolean(label: 'enabled', initialValue: true)
        ? () {}
        : null,
  );
}

@widgetbook.UseCase(name: 'All variants', type: CaliforniaButton)
Widget buildCaliforniaButtonAllVariantsUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final size in CaliforniaButtonSize.values) ...[
          Text(size.name, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              CaliforniaButton.primary(
                label: 'Active',
                size: size,
                onPressed: () {},
              ),
              const CaliforniaButton.primary(
                label: 'Disabled',
                onPressed: null,
              ),
              CaliforniaButton.ghost(
                label: 'Ghost',
                size: size,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ],
    ),
  );
}
