import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/notifications/notifications.dart';

void main() {
  group('NotificationsCubit', () {
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

    test('initial state has default mock notifications and unreadCount', () {
      final cubit = NotificationsCubit();
      expect(cubit.state.notifications, isNotEmpty);
      expect(cubit.state.unreadCount, equals(cubit.state.notifications.length));
    });

    blocTest<NotificationsCubit, NotificationsState>(
      'markAsRead marks specific notification as read and '
      'decrements unreadCount',
      build: () => NotificationsCubit(
        initialNotifications: const [item1, item2],
      ),
      act: (cubit) => cubit.markAsRead('n1'),
      expect: () => [
        NotificationsState(
          notifications: [
            item1.copyWith(isRead: true),
            item2,
          ],
        ),
      ],
      verify: (cubit) {
        expect(cubit.state.unreadCount, equals(1));
      },
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'markAllAsRead marks all notifications as read and unreadCount is 0',
      build: () => NotificationsCubit(
        initialNotifications: const [item1, item2],
      ),
      act: (cubit) => cubit.markAllAsRead(),
      expect: () => [
        NotificationsState(
          notifications: [
            item1.copyWith(isRead: true),
            item2.copyWith(isRead: true),
          ],
        ),
      ],
      verify: (cubit) {
        expect(cubit.state.unreadCount, equals(0));
      },
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'clearAll empties notification list',
      build: () => NotificationsCubit(
        initialNotifications: const [item1, item2],
      ),
      act: (cubit) => cubit.clearAll(),
      expect: () => [
        const NotificationsState(),
      ],
      verify: (cubit) {
        expect(cubit.state.unreadCount, equals(0));
      },
    );
  });
}
