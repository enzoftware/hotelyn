import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:test/test.dart';

// Reservation decodes a create_reservation_hold RPC row (BE-402). These pin the
// snake_case row shape and enum mapping the client relies on.
void main() {
  group('Reservation.fromJson (hold RPC row)', () {
    test('maps a held reservation row', () {
      final reservation = Reservation.fromJson(const {
        'id': 'res-1',
        'hotel_id': 'h1',
        'room_id': 'r1',
        'guest_id': 'g1',
        'status': 'held',
        'check_in': '2026-09-01',
        'check_out': '2026-09-03',
        'hold_expires_at': '2026-09-01T00:15:00Z',
        'confirmation_code': 'HZ-3F7K9Q2A',
      });

      expect(reservation.id, 'res-1');
      expect(reservation.roomId, 'r1');
      expect(reservation.status, ReservationStatus.held);
      // Bare YYYY-MM-DD dates decode as UTC-anchored midnight, so the calendar
      // day is stable regardless of the device timezone.
      expect(reservation.checkIn, DateTime.utc(2026, 9));
      expect(reservation.checkIn.isUtc, isTrue);
      expect(reservation.checkOut, DateTime.utc(2026, 9, 3));
      expect(reservation.holdExpiresAt, isNotNull);
      expect(reservation.confirmationCode, 'HZ-3F7K9Q2A');
    });

    test('tolerates a null expiry and confirmation code', () {
      final reservation = Reservation.fromJson(const {
        'id': 'res-2',
        'hotel_id': 'h1',
        'room_id': 'r1',
        'guest_id': 'g1',
        'status': 'cancelled',
        'check_in': '2026-09-01',
        'check_out': '2026-09-03',
        'hold_expires_at': null,
        'confirmation_code': null,
      });

      expect(reservation.status, ReservationStatus.cancelled);
      expect(reservation.holdExpiresAt, isNull);
      expect(reservation.confirmationCode, isNull);
    });

    test('maps a paid (confirmed) reservation row with audit fields', () {
      final reservation = Reservation.fromJson(const {
        'id': 'res-3',
        'hotel_id': 'h1',
        'room_id': 'r1',
        'guest_id': 'g1',
        'status': 'confirmed',
        'check_in': '2026-09-01',
        'check_out': '2026-09-03',
        'hold_expires_at': null,
        'confirmation_code': 'HZ-3F7K9Q2A',
        'paid_by': 'staff-1',
        'paid_at': '2026-09-01T10:30:00Z',
      });

      expect(reservation.status, ReservationStatus.confirmed);
      expect(reservation.paidBy, 'staff-1');
      expect(reservation.paidAt, DateTime.utc(2026, 9, 1, 10, 30));
    });

    test('tolerates null paid_by / paid_at on an unpaid reservation', () {
      final reservation = Reservation.fromJson(const {
        'id': 'res-4',
        'hotel_id': 'h1',
        'room_id': 'r1',
        'guest_id': 'g1',
        'status': 'held',
        'check_in': '2026-09-01',
        'check_out': '2026-09-03',
      });

      expect(reservation.paidBy, isNull);
      expect(reservation.paidAt, isNull);
    });

    test('decodes each reservation_status enum value', () {
      Reservation withStatus(String status) => Reservation.fromJson({
            'id': 'res',
            'hotel_id': 'h1',
            'room_id': 'r1',
            'guest_id': 'g1',
            'status': status,
            'check_in': '2026-09-01',
            'check_out': '2026-09-03',
          });

      expect(withStatus('held').status, ReservationStatus.held);
      expect(withStatus('confirmed').status, ReservationStatus.confirmed);
      expect(withStatus('cancelled').status, ReservationStatus.cancelled);
      expect(withStatus('rejected').status, ReservationStatus.rejected);
      expect(withStatus('expired').status, ReservationStatus.expired);
    });

    test('check_in/check_out survive a fromJson -> toJson round-trip', () {
      const row = {
        'id': 'res-1',
        'hotel_id': 'h1',
        'room_id': 'r1',
        'guest_id': 'g1',
        'status': 'held',
        'check_in': '2026-09-01',
        'check_out': '2026-09-03',
      };

      final json = Reservation.fromJson(row).toJson();

      // The emitted strings still represent the same calendar days — no drift
      // from timezone-dependent parsing.
      expect(json['check_in'], '2026-09-01');
      expect(json['check_out'], '2026-09-03');
    });

    test('a date-time with a zone offset keeps its UTC calendar day', () {
      // 2026-09-01T23:00-05:00 is 2026-09-02T04:00Z — the UTC day is the 2nd.
      final reservation = Reservation.fromJson(const {
        'id': 'res-1',
        'hotel_id': 'h1',
        'room_id': 'r1',
        'guest_id': 'g1',
        'status': 'held',
        'check_in': '2026-09-01T23:00:00-05:00',
        'check_out': '2026-09-03',
      });

      expect(reservation.checkIn, DateTime.utc(2026, 9, 2));
      expect(reservation.toJson()['check_in'], '2026-09-02');
    });

    test('supports value equality', () {
      final a = Reservation.fromJson(const {
        'id': 'res-1',
        'hotel_id': 'h1',
        'room_id': 'r1',
        'guest_id': 'g1',
        'status': 'held',
        'check_in': '2026-09-01',
        'check_out': '2026-09-03',
      });
      final b = Reservation.fromJson(const {
        'id': 'res-1',
        'hotel_id': 'h1',
        'room_id': 'r1',
        'guest_id': 'g1',
        'status': 'held',
        'check_in': '2026-09-01',
        'check_out': '2026-09-03',
      });

      expect(a, equals(b));
    });
  });
}
