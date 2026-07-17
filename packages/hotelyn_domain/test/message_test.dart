import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Message', () {
    Message message({
      String id = 'm1',
      String reservationId = 'res-1',
      String senderId = 'u1',
      String body = 'Hi',
      DateTime? sentAt,
    }) =>
        Message(
          id: id,
          reservationId: reservationId,
          senderId: senderId,
          body: body,
          sentAt: sentAt ?? DateTime.utc(2026, 9, 1, 10, 30),
        );

    test('supports value equality', () {
      expect(message(), equals(message()));
      expect(message().hashCode, message().hashCode);
    });

    test('differs when any field differs', () {
      final base = message();
      expect(base, isNot(equals(message(id: 'm2'))));
      expect(base, isNot(equals(message(reservationId: 'res-2'))));
      expect(base, isNot(equals(message(senderId: 'u2'))));
      expect(base, isNot(equals(message(body: 'Bye'))));
      expect(
        base,
        isNot(equals(message(sentAt: DateTime.utc(2026, 9, 2)))),
      );
    });

    test('exposes its fields', () {
      final m = message();
      expect(m.id, 'm1');
      expect(m.reservationId, 'res-1');
      expect(m.senderId, 'u1');
      expect(m.body, 'Hi');
      expect(m.sentAt, DateTime.utc(2026, 9, 1, 10, 30));
    });
  });
}
