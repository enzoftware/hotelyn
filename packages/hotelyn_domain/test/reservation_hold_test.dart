import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ReservationHold', () {
    ReservationHold hold({
      String id = 'res-1',
      DateTime? expiresAt,
      String confirmationCode = 'HZ-3F7K9Q2A',
    }) =>
        ReservationHold(
          id: id,
          hotelId: 'h1',
          roomId: 'r1',
          guestId: 'g1',
          checkIn: DateTime.utc(2026, 9),
          checkOut: DateTime.utc(2026, 9, 3),
          expiresAt: expiresAt ?? DateTime.utc(2026, 9, 1, 0, 15),
          confirmationCode: confirmationCode,
        );

    test('supports value equality', () {
      expect(hold(), equals(hold()));
      expect(hold().hashCode, hold().hashCode);
    });

    test('differs when a field differs', () {
      expect(hold(), isNot(equals(hold(id: 'res-2'))));
      expect(hold(), isNot(equals(hold(confirmationCode: 'HZ-OTHER'))));
      expect(
        hold(),
        isNot(equals(hold(expiresAt: DateTime.utc(2026, 9, 1, 0, 30)))),
      );
    });

    test('carries a non-null expiry and confirmation code', () {
      final h = hold();
      expect(h.expiresAt, DateTime.utc(2026, 9, 1, 0, 15));
      expect(h.confirmationCode, 'HZ-3F7K9Q2A');
    });
  });
}
