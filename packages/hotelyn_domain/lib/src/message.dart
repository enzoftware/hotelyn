import 'package:equatable/equatable.dart';

/// A message exchanged about a reservation — a guest ↔ hotel note or
/// notification.
///
/// Forward-looking shared vocabulary: no backend `messages` table exists yet,
/// so this defines the contract a future messaging feature (and its
/// `MessageRepository`) will speak, without committing to a wire shape.
///
/// A pure value type: value equality via [Equatable], no JSON coupling.
class Message extends Equatable {
  const Message({
    required this.id,
    required this.reservationId,
    required this.senderId,
    required this.body,
    required this.sentAt,
  });

  /// The message's id.
  final String id;

  /// The reservation this message is about — the thread it belongs to.
  final String reservationId;

  /// The id of whoever sent it (a guest or a staff member).
  final String senderId;

  /// The message text.
  final String body;

  /// When the message was sent.
  final DateTime sentAt;

  @override
  List<Object?> get props => [id, reservationId, senderId, body, sentAt];
}
