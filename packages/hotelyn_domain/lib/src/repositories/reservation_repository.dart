import 'package:hotelyn_domain/src/reservation.dart';
import 'package:hotelyn_domain/src/reservation_hold.dart';

/// The reservation lifecycle: placing a hold, then confirming, rejecting, or
/// marking it paid.
///
/// A shared-vocabulary contract implemented by the service layer (BE-902).
/// Domain types only.
abstract class ReservationRepository {
  /// Places a short-lived hold on [roomId] for [guestId] over the
  /// [checkIn]–[checkOut] date range, returning the created [ReservationHold].
  Future<ReservationHold> createHold({
    required String roomId,
    required String guestId,
    required DateTime checkIn,
    required DateTime checkOut,
  });

  /// Reservations placed by [guestId] (their "my bookings" list).
  Future<List<Reservation>> reservationsForGuest(String guestId);

  /// Confirms a held reservation as owning-hotel staff, returning the now
  /// `confirmed` [Reservation]. [actorId] is the acting staff member.
  Future<Reservation> confirm({
    required String actorId,
    required String reservationId,
  });

  /// Rejects a reservation and frees the room, returning the now `rejected`
  /// [Reservation]. [actorId] is the acting staff member.
  Future<Reservation> reject({
    required String actorId,
    required String reservationId,
  });

  /// Marks a held reservation paid in person, transitioning it to `confirmed`
  /// and stamping who/when. [actorId] is the acting staff member.
  Future<Reservation> markPaid({
    required String actorId,
    required String reservationId,
  });
}
