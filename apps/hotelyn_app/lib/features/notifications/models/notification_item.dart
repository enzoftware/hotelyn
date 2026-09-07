import 'package:equatable/equatable.dart';

/// Notification category type.
enum NotificationType {
  message,
  systemAlert,
  promotion,
  bookingUpdate,
}

/// A user notification item.
///
/// Designed with discretion safety: generic sender and preview text
/// without exposing sensitive or explicit details.
class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.type,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final NotificationType type;
  final bool isRead;

  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    String? timeAgo,
    NotificationType? type,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timeAgo: timeAgo ?? this.timeAgo,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    timeAgo,
    type,
    isRead,
  ];
}
