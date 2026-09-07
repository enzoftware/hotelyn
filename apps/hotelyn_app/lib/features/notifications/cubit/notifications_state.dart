part of 'notifications_cubit.dart';

/// State for [NotificationsCubit].
class NotificationsState extends Equatable {
  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
  });

  final List<NotificationItem> notifications;
  final bool isLoading;

  /// Total count of unread notifications.
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsState copyWith({
    List<NotificationItem>? notifications,
    bool? isLoading,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [notifications, isLoading];
}
