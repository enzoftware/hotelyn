import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/notifications/notifications.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsCubit extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

void main() {
  group('NotificationsPage', () {
    late MockNotificationsCubit mockCubit;
    const item1 = NotificationItem(
      id: 'n1',
      title: 'Booking Confirmed',
      description: 'Your booking at Grand Plaza is confirmed.',
      timeAgo: '5 m ago',
      type: NotificationType.bookingUpdate,
    );

    const item2 = NotificationItem(
      id: 'n2',
      title: 'Discount Code',
      description: 'Use code SAVE20 for your next stay.',
      timeAgo: '1 h ago',
      type: NotificationType.promotion,
    );

    setUp(() {
      mockCubit = MockNotificationsCubit();
      when(() => mockCubit.state).thenReturn(
        const NotificationsState(
          notifications: [item1, item2],
        ),
      );
    });

    Widget buildSubject() {
      return MaterialApp(
        home: NotificationsPage(
          cubit: mockCubit,
        ),
      );
    }

    testWidgets('renders notifications list with Recent header and tiles', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Notification'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);
      expect(find.text('Booking Confirmed'), findsOneWidget);
      expect(find.text('Discount Code'), findsOneWidget);
      expect(find.text('Mark All Read'), findsOneWidget);
    });

    testWidgets('tapping notification tile triggers markAsRead', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Booking Confirmed'));
      await tester.pumpAndSettle();

      verify(() => mockCubit.markAsRead('n1')).called(1);
    });

    testWidgets('tapping Mark All Read triggers markAllAsRead', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mark All Read'));
      await tester.pumpAndSettle();

      verify(() => mockCubit.markAllAsRead()).called(1);
    });

    testWidgets('renders empty state when notifications are empty', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        const NotificationsState(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('No Notifications'), findsOneWidget);
      expect(
        find.text('You have no unread notifications at the moment.'),
        findsOneWidget,
      );
    });
  });
}
