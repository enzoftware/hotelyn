import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Free-typing', type: CaliforniaInputField)
Widget buildCaliforniaInputFieldFreeTypingUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: CaliforniaInputField(
      title: context.knobs.string(label: 'title', initialValue: 'Full name'),
      placeholder: context.knobs.string(
        label: 'placeholder',
        initialValue: 'Enter your name',
      ),
      leadingIcon: context.knobs.boolean(
        label: 'with leading icon',
        initialValue: true,
      )
          ? CupertinoIcons.person
          : null,
      obscureText: context.knobs.boolean(label: 'obscureText'),
      enabled: context.knobs.boolean(label: 'enabled', initialValue: true),
    ),
  );
}

@widgetbook.UseCase(name: 'Selector', type: CaliforniaInputField)
Widget buildCaliforniaInputFieldSelectorUseCase(BuildContext context) {
  final hasValue = context.knobs.boolean(
    label: 'has chosen value',
    initialValue: true,
  );

  return Padding(
    padding: const EdgeInsets.all(24),
    child: CaliforniaInputField.selector(
      title: context.knobs.string(label: 'title', initialValue: 'Room type'),
      placeholder: context.knobs.string(
        label: 'placeholder',
        initialValue: 'Select a room',
      ),
      value: hasValue
          ? context.knobs.string(
              label: 'value',
              initialValue: 'Deluxe Suite',
            )
          : null,
      enabled: context.knobs.boolean(label: 'enabled', initialValue: true),
      onTap: () {},
    ),
  );
}

@widgetbook.UseCase(name: 'All states', type: CaliforniaInputField)
Widget buildCaliforniaInputFieldAllStatesUseCase(BuildContext context) {
  return const SingleChildScrollView(
    padding: EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CaliforniaInputField(
          title: 'Default',
          placeholder: 'Placeholder',
          leadingIcon: CupertinoIcons.person,
        ),
        SizedBox(height: 24),
        CaliforniaInputField(
          title: 'Disabled',
          placeholder: 'Placeholder',
          leadingIcon: CupertinoIcons.person,
          enabled: false,
        ),
        SizedBox(height: 24),
        CaliforniaInputField.selector(
          title: 'Selector — unselected',
          placeholder: 'Select a room',
        ),
        SizedBox(height: 24),
        CaliforniaInputField.selector(
          title: 'Selector — filled',
          placeholder: 'Select a room',
          value: 'Deluxe Suite',
        ),
        SizedBox(height: 24),
        CaliforniaInputField.selector(
          title: 'Selector — disabled',
          placeholder: 'Select a room',
          enabled: false,
        ),
      ],
    ),
  );
}
