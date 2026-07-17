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

  group('Reservation payment-audit invariant', () {
    // The manual-payment audit fields (paid_by/paid_at) are written together by
    // mark_reservation_paid (BE-702); a row carrying one without the other is
    // an incoherent payment record and is rejected at construction.
    Map<String, dynamic> row({String? paidBy, String? paidAt}) => {
          'id': 'res-1',
          'hotel_id': 'h1',
          'room_id': 'r1',
          'guest_id': 'g1',
          'status': 'confirmed',
          'check_in': '2026-09-01',
          'check_out': '2026-09-03',
          if (paidBy != null) 'paid_by': paidBy,
          if (paidAt != null) 'paid_at': paidAt,
        };

    test('rejects paid_by without paid_at (via fromJson)', () {
      expect(
        () => Reservation.fromJson(row(paidBy: 'staff-1')),
        throwsArgumentError,
      );
    });

    test('rejects paid_at without paid_by (via fromJson)', () {
      expect(
        () => Reservation.fromJson(row(paidAt: '2026-09-01T10:30:00Z')),
        throwsArgumentError,
      );
    });

    test('rejects a directly-constructed half-stamped payment', () {
      // A runtime throw (not an assert), so it also fires in release builds.
      expect(
        () => Reservation(
          id: 'res-1',
          hotelId: 'h1',
          roomId: 'r1',
          guestId: 'g1',
          status: ReservationStatus.confirmed,
          checkIn: DateTime.utc(2026, 9),
          checkOut: DateTime.utc(2026, 9, 3),
          paidBy: 'staff-1',
        ),
        throwsArgumentError,
      );
    });

    test('accepts a fully-stamped payment (both fields set)', () {
      final reservation = Reservation.fromJson(
        row(paidBy: 'staff-1', paidAt: '2026-09-01T10:30:00Z'),
      );

      expect(reservation.paidBy, 'staff-1');
      expect(reservation.paidAt, DateTime.utc(2026, 9, 1, 10, 30));
    });

    test('accepts an unpaid reservation (neither field set)', () {
      expect(() => Reservation.fromJson(row()), returnsNormally);
    });

    test('allows a confirmed reservation with no payment stamp (BE-503)', () {
      // Staff confirm_reservation transitions a hold to confirmed without
      // taking payment, so confirmed + no paid_by/paid_at is a valid state.
      final reservation = Reservation.fromJson(row());

      expect(reservation.status, ReservationStatus.confirmed);
      expect(reservation.paidBy, isNull);
      expect(reservation.paidAt, isNull);
    });
  });
}
