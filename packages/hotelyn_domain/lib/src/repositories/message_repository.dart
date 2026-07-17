import 'package:hotelyn_domain/src/message.dart';

/// Messaging about a reservation — the guest ↔ hotel thread.
///
/// Forward-looking: no backend messaging exists yet, so this defines the
/// contract a future feature (and the service layer, BE-902) will implement.
/// Domain types only.
abstract class MessageRepository {
  /// The messages on [reservationId]'s thread, oldest-first.
  Future<List<Message>> messagesForReservation(String reservationId);

  /// Sends [body] from [senderId] on [reservationId]'s thread, returning the
  /// created [Message].
  Future<Message> sendMessage({
    required String reservationId,
    required String senderId,
    required String body,
  });
}
