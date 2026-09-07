import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/features/notifications/models/notification_item.dart';

part 'notifications_state.dart';

/// Cubit managing notification entries, unread badges, and read state.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    List<NotificationItem>? initialNotifications,
  }) : super(
         NotificationsState(
           notifications: initialNotifications ?? _defaultNotifications,
         ),
       );

  /// Mark all notifications as read.
  void markAllAsRead() {
    final updated = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    emit(state.copyWith(notifications: updated));
  }

  /// Mark a single notification by [id] as read.
  void markAsRead(String id) {
    final updated = state.notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    emit(state.copyWith(notifications: updated));
  }

  /// Clear all notifications.
  void clearAll() {
    emit(state.copyWith(notifications: const []));
  }

  /// Default mock notifications matching Figma node `115:2615`.
  /// Designed with discretion safety: generic sender/preview text.
  static const _defaultNotifications = [
    NotificationItem(
      id: 'notif-1',
      title: 'Host sent you a message',
      description: 'Are you looking for hotels? You can check recommendations.',
      timeAgo: '1 m ago',
      type: NotificationType.message,
    ),
    NotificationItem(
      id: 'notif-2',
      title: 'System Alert',
      description:
          'Please complete your profile to keep your account up to date.',
      timeAgo: '2 m ago',
      type: NotificationType.systemAlert,
    ),
    NotificationItem(
      id: 'notif-3',
      title: 'New User Discount',
      description:
          'Special offer for new users! Save up to 50% on select stays.',
      timeAgo: '19 m ago',
      type: NotificationType.promotion,
    ),
    NotificationItem(
      id: 'notif-4',
      title: 'Booking Completed',
      description: 'Your reservation is confirmed. See details for check-in.',
      timeAgo: '1 d ago',
      type: NotificationType.bookingUpdate,
    ),
  ];
}
