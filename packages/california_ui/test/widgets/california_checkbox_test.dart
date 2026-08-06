import 'package:california_ui/california_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('CaliforniaCheckbox', () {
    testWidgets('renders the label when provided', (tester) async {
      await tester.pumpApp(
        CaliforniaCheckbox(
          value: false,
          label: 'Accept terms',
          onChanged: (_) {},
        ),
      );

      expect(find.text('Accept terms'), findsOneWidget);
    });

    testWidgets('calls onChanged with the toggled value when tapped', (
      tester,
    ) async {
      bool? newValue;
      await tester.pumpApp(
        CaliforniaCheckbox(
          value: false,
          label: 'Accept terms',
          onChanged: (value) => newValue = value,
        ),
      );

      await tester.tap(find.text('Accept terms'));

      expect(newValue, isTrue);
    });

    testWidgets('toggles from checked to unchecked', (tester) async {
      bool? newValue;
      await tester.pumpApp(
        CaliforniaCheckbox(
          value: true,
          label: 'Accept terms',
          onChanged: (value) => newValue = value,
        ),
      );

      await tester.tap(find.text('Accept terms'));

      expect(newValue, isFalse);
    });

    testWidgets('does not throw when tapped while onChanged is null', (
      tester,
    ) async {
      await tester.pumpApp(
        const CaliforniaCheckbox(value: false, label: 'Accept terms'),
      );

      await tester.tap(find.text('Accept terms'));

      expect(tester.takeException(), isNull);
    });

    testWidgets('exposes its checked state via Semantics', (tester) async {
      await tester.pumpApp(
        CaliforniaCheckbox(
          value: true,
          label: 'Accept terms',
          onChanged: (_) {},
        ),
      );

      final semantics = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(CaliforniaCheckbox),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(semantics.properties.checked, isTrue);
    });
  });
}
