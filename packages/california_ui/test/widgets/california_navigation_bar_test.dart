import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  const items = [
    CaliforniaNavigationBarItem(
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      label: 'Home',
    ),
    CaliforniaNavigationBarItem(
      icon: CupertinoIcons.search,
      activeIcon: CupertinoIcons.search,
      label: 'Search',
    ),
    CaliforniaNavigationBarItem(
      icon: CupertinoIcons.chat_bubble,
      activeIcon: CupertinoIcons.chat_bubble_fill,
      label: 'Messages',
    ),
  ];

  group('CaliforniaNavigationBar', () {
    testWidgets('renders a label for every item', (tester) async {
      await tester.pumpApp(
        CaliforniaNavigationBar(items: items, currentIndex: 0),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
    });

    testWidgets('shows the active icon for the selected index', (
      tester,
    ) async {
      await tester.pumpApp(
        CaliforniaNavigationBar(items: items, currentIndex: 0),
      );

      expect(find.byIcon(CupertinoIcons.house_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.house), findsNothing);
    });

    testWidgets('calls onTap with the tapped index', (tester) async {
      int? tappedIndex;
      await tester.pumpApp(
        CaliforniaNavigationBar(
          items: items,
          currentIndex: 0,
          onTap: (index) => tappedIndex = index,
        ),
      );

      await tester.tap(find.text('Messages'));
      await tester.pump();

      expect(tappedIndex, 2);
    });

    testWidgets('does not throw when onTap is null', (tester) async {
      await tester.pumpApp(
        CaliforniaNavigationBar(items: items, currentIndex: 1),
      );

      await tester.tap(find.text('Home'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    test('asserts currentIndex is within bounds', () {
      expect(
        () => CaliforniaNavigationBar(items: items, currentIndex: 99),
        throwsAssertionError,
      );
    });

    test('asserts at least 2 items are provided', () {
      expect(
        () => CaliforniaNavigationBar(
          items: items.take(1).toList(),
          currentIndex: 0,
        ),
        throwsAssertionError,
      );
    });
  });
}
