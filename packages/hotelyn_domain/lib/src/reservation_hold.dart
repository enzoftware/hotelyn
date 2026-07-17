import 'package:equatable/equatable.dart';

/// A short-lived hold placed on a room while a guest completes a booking
/// (BE-401/BE-402).
///
/// A narrower projection of a `held` `Reservation`: where `Reservation` models
/// the whole lifecycle (and so carries a *nullable* `holdExpiresAt` and no
/// enforced status), a `ReservationHold` is specifically the live hold, with a
/// **guaranteed non-null** [expiresAt] and a [confirmationCode]. Repository
/// methods that create a hold return this, making "this is a ticking hold, and
/// here is when it lapses" true by construction rather than by convention.
///
/// A pure value type: value equality via [Equatable], no JSON coupling.
class ReservationHold extends Equatable {
  const ReservationHold({
    required this.id,
    required this.hotelId,
    required this.roomId,
    required this.guestId,
    required this.checkIn,
    required this.checkOut,
    required this.expiresAt,
    required this.confirmationCode,
  });

  /// The underlying reservation's id.
  final String id;

  final String hotelId;
  final String roomId;
  final String guestId;

  /// Check-in day (a calendar date; see `Reservation.checkIn` for the
  /// UTC-anchored date contract).
  final DateTime checkIn;

  /// Check-out day.
  final DateTime checkOut;

  /// When the hold lapses and stops blocking the room. Never `null` — a live
  /// hold always ticks.
  final DateTime expiresAt;

  /// Human-quotable booking handle (e.g. `HZ-3F7K9Q2A`), generated server-side.
  final String confirmationCode;

  @override
  List<Object?> get props => [
        id,
        hotelId,
        roomId,
        guestId,
        checkIn,
        checkOut,
        expiresAt,
        confirmationCode,
      ];
}
