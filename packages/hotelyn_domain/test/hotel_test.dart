import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Hotel', () {
    test('supports value equality', () {
      const a = Hotel(id: 'h1', name: 'Bay', city: 'Lima', country: 'Peru');
      const b = Hotel(id: 'h1', name: 'Bay', city: 'Lima', country: 'Peru');
      expect(a, equals(b));
    });

    test('differs when a search projection differs', () {
      const a = Hotel(id: 'h1', name: 'Bay', city: 'Lima', country: 'Peru');
      const b = Hotel(
        id: 'h1',
        name: 'Bay',
        city: 'Lima',
        country: 'Peru',
        distanceKm: 1.9,
      );
      expect(a, isNot(equals(b)));
    });

    test('leaves search projections null by default', () {
      const hotel = Hotel(id: 'h1', name: 'Bay', city: 'Lima', country: 'Peru');
      expect(hotel.distanceKm, isNull);
      expect(hotel.popularity, isNull);
    });
  });

  group('Room', () {
    test('supports value equality', () {
      const a = Room(
        id: 'r1',
        hotelId: 'h1',
        name: '101',
        roomType: 'double',
        capacity: 2,
        pricePerNight: 180,
        isAvailable: true,
        availableNow: true,
      );
      const b = Room(
        id: 'r1',
        hotelId: 'h1',
        name: '101',
        roomType: 'double',
        capacity: 2,
        pricePerNight: 180,
        isAvailable: true,
        availableNow: true,
      );
      expect(a, equals(b));
    });

    test('distinguishes availableNow from isAvailable', () {
      const room = Room(
        id: 'r1',
        hotelId: 'h1',
        name: '101',
        roomType: 'double',
        capacity: 2,
        pricePerNight: 180,
        isAvailable: true,
        availableNow: false,
      );
      expect(room.isAvailable, isTrue);
      expect(room.availableNow, isFalse);
    });
  });
}
