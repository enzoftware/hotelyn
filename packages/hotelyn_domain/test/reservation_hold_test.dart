import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ReservationHold', () {
    ReservationHold hold({
      String id = 'res-1',
      String hotelId = 'h1',
      String roomId = 'r1',
      String guestId = 'g1',
      DateTime? checkIn,
      DateTime? checkOut,
      DateTime? expiresAt,
      String confirmationCode = 'HZ-3F7K9Q2A',
    }) =>
        ReservationHold(
          id: id,
          hotelId: hotelId,
          roomId: roomId,
          guestId: guestId,
          checkIn: checkIn ?? DateTime.utc(2026, 9),
          checkOut: checkOut ?? DateTime.utc(2026, 9, 3),
          expiresAt: expiresAt ?? DateTime.utc(2026, 9, 1, 0, 15),
          confirmationCode: confirmationCode,
        );

    test('supports value equality', () {
      expect(hold(), equals(hold()));
      expect(hold().hashCode, hold().hashCode);
    });

    test('differs when a field differs', () {
      expect(hold(), isNot(equals(hold(id: 'res-2'))));
      expect(hold(), isNot(equals(hold(hotelId: 'h2'))));
      expect(hold(), isNot(equals(hold(roomId: 'r2'))));
      expect(hold(), isNot(equals(hold(guestId: 'g2'))));
      expect(
        hold(),
        isNot(equals(hold(checkIn: DateTime.utc(2026, 9, 2)))),
      );
      expect(
        hold(),
        isNot(equals(hold(checkOut: DateTime.utc(2026, 9, 4)))),
      );
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
