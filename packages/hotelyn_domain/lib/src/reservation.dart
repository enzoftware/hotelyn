import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reservation.g.dart';

/// Lifecycle of a reservation, mirroring the Postgres `reservation_status`
/// enum.
///
/// Under the query-time-expiry model (BE-403) a row may still read [held]
/// after its `holdExpiresAt` has passed; availability is derived from the
/// expiry, not from this status alone.
enum ReservationStatus {
  held,
  confirmed,
  cancelled,
  rejected,
  expired,
}

/// A reservation (a hold or a confirmed booking) on a room.
///
/// Created via `HotelynApiClient.createReservationHold`, which places a
/// short-lived `held` reservation. [confirmationCode] is the human-quotable
/// booking handle generated server-side (BE-402); [holdExpiresAt] is when a
/// held/confirmed row stops blocking the room.
///
/// JSON keys are snake_case to match the REST API / Postgres row shape
/// (`room_id`, `hold_expires_at`, `confirmation_code`, …).
@JsonSerializable(fieldRename: FieldRename.snake)
class Reservation extends Equatable {
  const Reservation({
    required this.id,
    required this.hotelId,
    required this.roomId,
    required this.guestId,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    this.holdExpiresAt,
    this.confirmationCode,
    this.paidBy,
    this.paidAt,
  });

  /// Decodes a `Reservation` from a REST/RPC JSON row.
  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);

  final String id;
  final String hotelId;
  final String roomId;
  final String guestId;
  final ReservationStatus status;

  /// Check-in day. A bare `YYYY-MM-DD` calendar date, anchored to UTC midnight
  /// so the day is stable regardless of the device timezone.
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime checkIn;

  /// Check-out day. See [checkIn] for the date-handling contract.
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime checkOut;

  /// When a held/confirmed reservation stops blocking the room. `null` for rows
  /// that never carried an expiry.
  final DateTime? holdExpiresAt;

  /// Human-quotable booking handle (e.g. `HZ-3F7K9Q2A`), generated server-side.
  final String? confirmationCode;

  /// Staff/admin profile id that marked this reservation paid in person
  /// (BE-702). `null` unless a manual payment was recorded.
  final String? paidBy;

  /// When the in-person payment was recorded (BE-702). `null` unless paid.
  final DateTime? paidAt;

  /// Encodes this `Reservation` to a snake_case JSON map.
  Map<String, dynamic> toJson() => _$ReservationToJson(this);

  @override
  List<Object?> get props => [
        id,
        hotelId,
        roomId,
        guestId,
        status,
        checkIn,
        checkOut,
        holdExpiresAt,
        confirmationCode,
        paidBy,
        paidAt,
      ];
}

/// Parses a bare `YYYY-MM-DD` (or a fuller timestamp) into a UTC-anchored
/// `DateTime` at midnight of that calendar day.
///
/// `DateTime.parse('2026-09-01')` yields *local* midnight, so on a device west
/// of UTC the calendar day can shift on round-trip. Reading the year/month/day
/// off the parsed value and rebuilding in UTC keeps the calendar day stable
/// regardless of the device timezone.
DateTime _dateFromJson(String value) {
  final parsed = DateTime.parse(value);
  return DateTime.utc(parsed.year, parsed.month, parsed.day);
}

/// Formats a date as a bare `YYYY-MM-DD` string (the API date contract).
String _dateToJson(DateTime date) {
  final utc = date.toUtc();
  final y = utc.year.toString().padLeft(4, '0');
  final m = utc.month.toString().padLeft(2, '0');
  final d = utc.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
