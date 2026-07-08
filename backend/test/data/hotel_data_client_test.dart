import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:test/test.dart';

// The data client decodes `nearby_hotels` / `recommended_hotels` /
// `rooms_with_availability` RPC rows via `Hotel.fromJson` / `Room.fromJson`.
// These tests pin the RPC row shape the server relies on.
void main() {
  group('Hotel.fromJson (RPC row)', () {
    test('maps a full nearby/recommended row into a Hotel', () {
      final hotel = Hotel.fromJson(const {
        'id': 'h1',
        'name': 'Miraflores Bay Hotel',
        'description': 'Oceanfront',
        'address': 'Malecon 615',
        'city': 'Lima',
        'country': 'Peru',
        'latitude': -12.1219,
        'longitude': -77.0428,
        'distance_km': 1.9,
        'popularity': 3,
      });

      expect(hotel.id, 'h1');
      expect(hotel.name, 'Miraflores Bay Hotel');
      expect(hotel.city, 'Lima');
      expect(hotel.country, 'Peru');
      expect(hotel.latitude, closeTo(-12.1219, 1e-9));
      expect(hotel.longitude, closeTo(-77.0428, 1e-9));
      expect(hotel.distanceKm, closeTo(1.9, 1e-9));
      expect(hotel.popularity, 3);
    });

    test('tolerates nullable projections and integer coordinates', () {
      final hotel = Hotel.fromJson(const {
        'id': 'h2',
        'name': 'Reforma Grand',
        'description': null,
        'address': null,
        'city': 'Mexico City',
        'country': 'Mexico',
        'latitude': 19, // integer from JSON
        'longitude': -99,
        'distance_km': null,
        'popularity': null,
      });

      expect(hotel.description, isNull);
      expect(hotel.address, isNull);
      expect(hotel.distanceKm, isNull);
      expect(hotel.popularity, isNull);
      expect(hotel.latitude, 19.0);
      expect(hotel.longitude, -99.0);
    });
  });

  group('Room.fromJson (RPC row)', () {
    test('maps a rooms_with_availability row into a Room', () {
      final room = Room.fromJson(const {
        'id': 'r1',
        'hotel_id': 'h1',
        'name': 'Ocean View 101',
        'room_type': 'double',
        'capacity': 2,
        'price_per_night': 180.0,
        'is_available': true,
        'available_now': false,
      });

      expect(room.id, 'r1');
      expect(room.hotelId, 'h1');
      expect(room.roomType, 'double');
      expect(room.capacity, 2);
      expect(room.pricePerNight, 180.0);
      expect(room.isAvailable, isTrue);
      expect(room.availableNow, isFalse);
    });

    test('coerces an integer price into a double', () {
      final room = Room.fromJson(const {
        'id': 'r2',
        'hotel_id': 'h1',
        'name': 'City View 102',
        'room_type': 'single',
        'capacity': 1,
        'price_per_night': 90, // integer from JSON
        'is_available': false,
        'available_now': false,
      });

      expect(room.pricePerNight, 90.0);
    });
  });
}
