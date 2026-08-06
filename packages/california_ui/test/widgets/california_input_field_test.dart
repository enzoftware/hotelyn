import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('CaliforniaInputField (free-typing)', () {
    testWidgets('renders title and placeholder', (tester) async {
      await tester.pumpApp(
        const CaliforniaInputField(
          title: 'Guest name',
          placeholder: 'Enter your name',
        ),
      );

      expect(find.text('Guest name'), findsOneWidget);
      expect(find.text('Enter your name'), findsOneWidget);
    });

    testWidgets('renders the leading icon when provided', (tester) async {
      await tester.pumpApp(
        const CaliforniaInputField(
          title: 'Guest name',
          placeholder: 'Enter your name',
          leadingIcon: CupertinoIcons.person,
        ),
      );

      expect(find.byIcon(CupertinoIcons.person), findsOneWidget);
    });

    testWidgets('calls onChanged as the user types', (tester) async {
      String? typed;
      await tester.pumpApp(
        CaliforniaInputField(
          title: 'Guest name',
          placeholder: 'Enter your name',
          onChanged: (value) => typed = value,
        ),
      );

      await tester.enterText(find.byType(TextField), 'Enzo');

      expect(typed, 'Enzo');
    });

    testWidgets('is not editable when disabled', (tester) async {
      await tester.pumpApp(
        const CaliforniaInputField(
          title: 'Guest name',
          placeholder: 'Enter your name',
          enabled: false,
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });
  });

  group('CaliforniaInputField.selector', () {
    testWidgets('shows placeholder when no value is chosen', (tester) async {
      await tester.pumpApp(
        const CaliforniaInputField.selector(
          title: 'Room type',
          placeholder: 'Select a room',
        ),
      );

      expect(find.text('Select a room'), findsOneWidget);
    });

    testWidgets('shows the chosen value instead of the placeholder', (
      tester,
    ) async {
      await tester.pumpApp(
        const CaliforniaInputField.selector(
          title: 'Room type',
          placeholder: 'Select a room',
          value: 'Deluxe Suite',
        ),
      );

      expect(find.text('Deluxe Suite'), findsOneWidget);
      expect(find.text('Select a room'), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        CaliforniaInputField.selector(
          title: 'Room type',
          placeholder: 'Select a room',
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.text('Select a room'));

      expect(tapped, isTrue);
    });

    testWidgets('renders no TextField (read-only)', (tester) async {
      await tester.pumpApp(
        const CaliforniaInputField.selector(
          title: 'Room type',
          placeholder: 'Select a room',
        ),
      );

      expect(find.byType(TextField), findsNothing);
    });
  });
}
