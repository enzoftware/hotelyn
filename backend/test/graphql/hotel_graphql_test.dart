import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:test/test.dart';

/// In-memory [HotelDataClient] that records the arguments it was called with
/// and returns canned domain entities, so the schema/resolvers can be exercised
/// without a live Supabase connection.
class _FakeHotelDataClient implements HotelDataClient {
  _FakeHotelDataClient({
    this.hotels = const [],
    this.recommended = const [],
    this.rooms = const [],
  });

  final List<Hotel> hotels;
  final List<Hotel> recommended;
  final List<Room> rooms;

  double? lastLat;
  double? lastLng;
  double? lastRadiusKm;
  String? lastHotelId;
  bool roomsCalled = false;

  @override
  Future<List<Hotel>> nearbyHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    lastLat = lat;
    lastLng = lng;
    lastRadiusKm = radiusKm;
    return hotels;
  }

  @override
  Future<List<Hotel>> recommendedHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    lastLat = lat;
    lastLng = lng;
    lastRadiusKm = radiusKm;
    return recommended;
  }

  @override
  Future<List<Room>> roomsAvailability({String? hotelId}) async {
    roomsCalled = true;
    lastHotelId = hotelId;
    return rooms;
  }
}

void main() {
  group('buildGraphQL', () {
    test('nearbyHotels resolves rows and forwards the radius args', () async {
      final client = _FakeHotelDataClient(
        hotels: const [
          Hotel(
            id: 'h1',
            name: 'Miraflores Bay Hotel',
            city: 'Lima',
            country: 'Peru',
            latitude: -12.12,
            longitude: -77.04,
            distanceKm: 1.9,
          ),
        ],
      );
      final graphQL = buildGraphQL(client);

      final data = await graphQL.parseAndExecute(
        '{ nearbyHotels(lat: -12.11, lng: -77.03, radiusKm: 200.0) '
        '{ id name city distanceKm } }',
      ) as Map<String, dynamic>;

      expect(client.lastLat, closeTo(-12.11, 1e-9));
      expect(client.lastLng, closeTo(-77.03, 1e-9));
      expect(client.lastRadiusKm, closeTo(200, 1e-9));

      final rows = data['nearbyHotels'] as List<dynamic>;
      expect(rows, hasLength(1));
      expect(
        rows.first,
        {
          'id': 'h1',
          'name': 'Miraflores Bay Hotel',
          'city': 'Lima',
          'distanceKm': 1.9,
        },
      );
    });

    test('nearbyHotels returns an empty list when nothing is in range',
        () async {
      final graphQL = buildGraphQL(_FakeHotelDataClient());

      final data = await graphQL.parseAndExecute(
        '{ nearbyHotels(lat: 0.0, lng: 0.0, radiusKm: 10.0) { id } }',
      ) as Map<String, dynamic>;

      expect(data['nearbyHotels'], isEmpty);
    });

    test('recommendedHotels exposes the popularity projection', () async {
      final client = _FakeHotelDataClient(
        recommended: const [
          Hotel(
            id: 'h1',
            name: 'Zona Rosa Suites',
            city: 'Bogota',
            country: 'Colombia',
            distanceKm: 5,
            popularity: 2,
          ),
        ],
      );
      final graphQL = buildGraphQL(client);

      final data = await graphQL.parseAndExecute(
        '{ recommendedHotels(lat: 4.7, lng: -74.0, radiusKm: 50.0) '
        '{ id popularity } }',
      ) as Map<String, dynamic>;

      final rows = data['recommendedHotels'] as List<dynamic>;
      expect(rows.first, {'id': 'h1', 'popularity': 2});
    });

    test('roomsAvailability forwards the hotelId and maps availableNow',
        () async {
      final client = _FakeHotelDataClient(
        rooms: const [
          Room(
            id: 'r1',
            hotelId: 'h1',
            name: 'Ocean View 101',
            roomType: 'double',
            capacity: 2,
            pricePerNight: 180,
            isAvailable: true,
            availableNow: false,
          ),
        ],
      );
      final graphQL = buildGraphQL(client);

      final data = await graphQL.parseAndExecute(
        '{ roomsAvailability(hotelId: "h1") '
        '{ id availableNow pricePerNight } }',
      ) as Map<String, dynamic>;

      expect(client.roomsCalled, isTrue);
      expect(client.lastHotelId, 'h1');
      final rows = data['roomsAvailability'] as List<dynamic>;
      expect(rows.first, {
        'id': 'r1',
        'availableNow': false,
        'pricePerNight': 180.0,
      });
    });

    test('rejects a query that omits a required radius argument', () async {
      final graphQL = buildGraphQL(_FakeHotelDataClient());

      expect(
        () => graphQL.parseAndExecute('{ nearbyHotels(lat: 1.0, lng: 2.0) '
            '{ id } }'),
        throwsA(anything),
      );
    });

    test('supports query variables', () async {
      final client = _FakeHotelDataClient();
      final graphQL = buildGraphQL(client);

      await graphQL.parseAndExecute(
        r'query Nearby($lat: Float!, $lng: Float!, $r: Float!) '
        r'{ nearbyHotels(lat: $lat, lng: $lng, radiusKm: $r) { id } }',
        variableValues: const {'lat': 25.76, 'lng': -80.19, 'r': 12.5},
      );

      expect(client.lastLat, closeTo(25.76, 1e-9));
      expect(client.lastLng, closeTo(-80.19, 1e-9));
      expect(client.lastRadiusKm, closeTo(12.5, 1e-9));
    });
  });
}
