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

    test('decodes a snake_case JSON row from the REST API / RPC', () {
      final hotel = Hotel.fromJson(const {
        'id': 'h1',
        'name': 'Miraflores',
        'city': 'Lima',
        'country': 'Peru',
        'description': 'By the sea',
        'address': 'Av. Larco 1',
        'latitude': -12.11,
        'longitude': -77.03,
        'distance_km': 1.9,
        'popularity': 42,
      });

      expect(hotel.id, 'h1');
      expect(hotel.distanceKm, 1.9);
      expect(hotel.popularity, 42);
      expect(hotel.latitude, -12.11);
    });

    test('tolerates integer-typed coordinates from the RPC', () {
      final hotel = Hotel.fromJson(const {
        'id': 'h1',
        'name': 'Bay',
        'city': 'Lima',
        'country': 'Peru',
        'latitude': 0,
        'longitude': 0,
      });

      expect(hotel.latitude, 0.0);
      expect(hotel.longitude, 0.0);
    });

    test('round-trips through toJson/fromJson', () {
      const hotel = Hotel(
        id: 'h1',
        name: 'Bay',
        city: 'Lima',
        country: 'Peru',
        distanceKm: 2.5,
        popularity: 7,
      );

      expect(Hotel.fromJson(hotel.toJson()), equals(hotel));
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

    test('decodes a snake_case JSON row from the REST API / RPC', () {
      final room = Room.fromJson(const {
        'id': 'r1',
        'hotel_id': 'h1',
        'name': '101',
        'room_type': 'double',
        'capacity': 2,
        'price_per_night': 180.5,
        'is_available': true,
        'available_now': false,
      });

      expect(room.hotelId, 'h1');
      expect(room.roomType, 'double');
      expect(room.pricePerNight, 180.5);
      expect(room.availableNow, isFalse);
    });

    test('round-trips through toJson/fromJson', () {
      const room = Room(
        id: 'r1',
        hotelId: 'h1',
        name: '101',
        roomType: 'double',
        capacity: 2,
        pricePerNight: 180,
        isAvailable: true,
        availableNow: true,
      );

      expect(Room.fromJson(room.toJson()), equals(room));
    });
  });
}
