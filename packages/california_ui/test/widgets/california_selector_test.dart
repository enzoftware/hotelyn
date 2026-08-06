import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('CaliforniaSelector', () {
    testWidgets('renders the label', (tester) async {
      await tester.pumpApp(
        CaliforniaSelector(
          label: 'Wifi',
          selected: false,
          onSelected: (_) {},
        ),
      );

      expect(find.text('Wifi'), findsOneWidget);
    });

    testWidgets('renders the leading icon when provided', (tester) async {
      await tester.pumpApp(
        CaliforniaSelector(
          label: 'Wifi',
          selected: false,
          icon: CupertinoIcons.wifi,
          onSelected: (_) {},
        ),
      );

      expect(find.byIcon(CupertinoIcons.wifi), findsOneWidget);
    });

    testWidgets('calls onSelected with the toggled value when tapped', (
      tester,
    ) async {
      bool? newValue;
      await tester.pumpApp(
        CaliforniaSelector(
          label: 'Wifi',
          selected: false,
          onSelected: (value) => newValue = value,
        ),
      );

      await tester.tap(find.text('Wifi'));

      expect(newValue, isTrue);
    });

    testWidgets('toggles from selected to unselected', (tester) async {
      bool? newValue;
      await tester.pumpApp(
        CaliforniaSelector(
          label: 'Wifi',
          selected: true,
          onSelected: (value) => newValue = value,
        ),
      );

      await tester.tap(find.text('Wifi'));

      expect(newValue, isFalse);
    });

    testWidgets('does not throw when tapped while onSelected is null', (
      tester,
    ) async {
      await tester.pumpApp(
        const CaliforniaSelector(label: 'Wifi', selected: false),
      );

      await tester.tap(find.text('Wifi'));

      expect(tester.takeException(), isNull);
    });
  });
}
