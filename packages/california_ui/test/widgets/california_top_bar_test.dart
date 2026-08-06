import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('CaliforniaTopBar.general', () {
    testWidgets('renders the title and calls onBack/onMenuTap', (
      tester,
    ) async {
      var backTapped = false;
      var menuTapped = false;

      await tester.pumpApp(
        CaliforniaTopBar.general(
          title: 'Settings',
          backButtonLabel: 'Back',
          menuButtonLabel: 'More options',
          onBack: () => backTapped = true,
          onMenuTap: () => menuTapped = true,
        ),
      );

      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.back));
      expect(backTapped, isTrue);

      await tester.tap(find.byIcon(CupertinoIcons.ellipsis));
      expect(menuTapped, isTrue);
    });
  });

  group('CaliforniaTopBar.mainScreen', () {
    testWidgets('renders the title and a notification badge when unread', (
      tester,
    ) async {
      await tester.pumpApp(
        const CaliforniaTopBar.mainScreen(
          title: 'Search',
          notificationsButtonLabel: 'Notifications',
          hasUnreadNotifications: true,
        ),
      );

      expect(find.text('Search'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.bell), findsOneWidget);

      final semantics = tester.getSemantics(find.byIcon(CupertinoIcons.bell));
      expect(semantics.label, 'Notifications');

      final unreadBadgeFinder = find.descendant(
        of: find.byType(CaliforniaTopBar),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).color ==
                  CaliforniaColors.error,
        ),
      );
      expect(unreadBadgeFinder, findsOneWidget);
    });

    testWidgets('calls onNotificationsTap when the bell is tapped', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpApp(
        CaliforniaTopBar.mainScreen(
          title: 'Search',
          notificationsButtonLabel: 'Notifications',
          onNotificationsTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byIcon(CupertinoIcons.bell));

      expect(tapped, isTrue);
    });
  });

  group('CaliforniaTopBar.searchByMap', () {
    testWidgets('renders the query and calls onSearchTap', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        CaliforniaTopBar.searchByMap(
          title: 'Purwokerto',
          backButtonLabel: 'Back',
          onSearchTap: () => tapped = true,
        ),
      );

      expect(find.text('Purwokerto'), findsOneWidget);

      await tester.tap(find.text('Purwokerto'));

      expect(tapped, isTrue);
    });
  });

  group('CaliforniaTopBar.detailProduct', () {
    testWidgets('renders trailing actions and calls onBack', (tester) async {
      var backTapped = false;
      await tester.pumpApp(
        CaliforniaTopBar.detailProduct(
          backButtonLabel: 'Back',
          onBack: () => backTapped = true,
          trailing: const Icon(CupertinoIcons.heart),
        ),
      );

      expect(find.byIcon(CupertinoIcons.heart), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.back));
      expect(backTapped, isTrue);
    });
  });

  group('CaliforniaTopBar.message', () {
    testWidgets('renders the leading widget', (tester) async {
      await tester.pumpApp(
        const CaliforniaTopBar.message(
          leading: Text('Kim Hayo'),
          backButtonLabel: 'Back',
          menuButtonLabel: 'More options',
        ),
      );

      expect(find.text('Kim Hayo'), findsOneWidget);
    });
  });
}
