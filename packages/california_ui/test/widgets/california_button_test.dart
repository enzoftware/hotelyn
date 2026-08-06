import 'package:california_ui/california_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('CaliforniaButton.primary', () {
    testWidgets('renders the label', (tester) async {
      await tester.pumpApp(
        CaliforniaButton.primary(label: 'Confirm', onPressed: () {}),
      );

      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        CaliforniaButton.primary(
          label: 'Confirm',
          onPressed: () => tapped = true,
        ),
      );

      await tester.tap(find.text('Confirm'));

      expect(tapped, isTrue);
    });

    testWidgets('does not throw when tapped while onPressed is null', (
      tester,
    ) async {
      await tester.pumpApp(
        const CaliforniaButton.primary(label: 'Confirm', onPressed: null),
      );

      await tester.tap(find.text('Confirm'));

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders at the expected width for each size', (
      tester,
    ) async {
      const expectedWidths = {
        CaliforniaButtonSize.large: 327.0,
        CaliforniaButtonSize.medium: 258.0,
        CaliforniaButtonSize.small: 173.0,
      };

      for (final entry in expectedWidths.entries) {
        await tester.pumpApp(
          CaliforniaButton.primary(
            label: 'Confirm',
            size: entry.key,
            onPressed: () {},
          ),
        );

        final size = tester.getSize(find.byType(CaliforniaButton));
        expect(size.width, entry.value);
      }
    });
  });

  group('CaliforniaButton.ghost', () {
    testWidgets('renders the label', (tester) async {
      await tester.pumpApp(
        CaliforniaButton.ghost(label: 'Cancel', onPressed: () {}),
      );

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        CaliforniaButton.ghost(
          label: 'Cancel',
          onPressed: () => tapped = true,
        ),
      );

      await tester.tap(find.text('Cancel'));

      expect(tapped, isTrue);
    });
  });
}
