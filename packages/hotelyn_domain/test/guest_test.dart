import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Guest', () {
    test('supports value equality', () {
      const a = Guest(id: 'g1', fullName: 'Ada', email: 'ada@x.com');
      const b = Guest(id: 'g1', fullName: 'Ada', email: 'ada@x.com');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('differs when any field differs', () {
      Guest guest({String id = 'g1', String name = 'Ada', String? email}) =>
          Guest(id: id, fullName: name, email: email ?? 'ada@x.com');

      final base = guest();
      expect(base, isNot(equals(guest(id: 'g2')))); // id differs
      expect(base, isNot(equals(guest(name: 'Bea')))); // fullName differs
      expect(base, isNot(equals(guest(email: 'bea@x.com')))); // email differs
    });

    test('leaves fullName and email null by default', () {
      const guest = Guest(id: 'g1');
      expect(guest.fullName, isNull);
      expect(guest.email, isNull);
    });
  });
}
