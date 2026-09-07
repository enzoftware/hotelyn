import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/core/domain/repository/hotel_repository.dart';
import 'package:hotelyn_api_client/hotelyn_api_client.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;
import 'package:mocktail/mocktail.dart';

class _MockHotelynApiClient extends Mock implements HotelynApiClient {}

void main() {
  late _MockHotelynApiClient mockApiClient;
  late AppHotelRepository repository;

  setUp(() {
    mockApiClient = _MockHotelynApiClient();
    repository = AppHotelRepository(apiClient: mockApiClient);
  });

  const testHotels = <domain.Hotel>[
    domain.Hotel(id: '1', name: 'Hotel A', city: 'Bali', country: 'Indonesia'),
  ];

  group('AppHotelRepository', () {
    group('recommendedHotels', () {
      test('returns recommended hotels when API returns data', () async {
        when(
          () => mockApiClient.getRecommendedHotels(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenAnswer((_) async => testHotels);

        final result = await repository.recommendedHotels(
          latitude: -7.42,
          longitude: 109.23,
          radiusKm: 50,
        );

        expect(result, testHotels);
        verifyNever(
          () => mockApiClient.getNearbyHotels(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            radiusKm: any(named: 'radiusKm'),
          ),
        );
      });

      test('falls back to nearby when recommended is empty', () async {
        when(
          () => mockApiClient.getRecommendedHotels(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenAnswer((_) async => <domain.Hotel>[]);

        when(
          () => mockApiClient.getNearbyHotels(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenAnswer((_) async => testHotels);

        final result = await repository.recommendedHotels(
          latitude: -7.42,
          longitude: 109.23,
          radiusKm: 50,
        );

        expect(result, testHotels);
      });

      test('falls back to mock when both APIs return empty', () async {
        when(
          () => mockApiClient.getRecommendedHotels(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenAnswer((_) async => <domain.Hotel>[]);

        when(
          () => mockApiClient.getNearbyHotels(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenAnswer((_) async => <domain.Hotel>[]);

        final result = await repository.recommendedHotels(
          latitude: -7.42,
          longitude: 109.23,
          radiusKm: 50,
        );

        expect(result, isNotEmpty);
        expect(result.first.id, 'mock-1');
      });

      test('falls back to mock on API exception', () async {
        when(
          () => mockApiClient.getRecommendedHotels(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenThrow(
          const ApiException('Server error', statusCode: 500),
        );

        final result = await repository.recommendedHotels(
          latitude: -7.42,
          longitude: 109.23,
          radiusKm: 50,
        );

        expect(result, isNotEmpty);
        expect(result.first.id, 'mock-1');
      });
    });

    group('nearbyHotels', () {
      test('returns nearby hotels when API returns data', () async {
        when(
          () => mockApiClient.getNearbyHotels(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenAnswer((_) async => testHotels);

        final result = await repository.nearbyHotels(
          latitude: -7.42,
          longitude: 109.23,
          radiusKm: 50,
        );

        expect(result, testHotels);
      });

      test('falls back to mock when nearby is empty', () async {
        when(
          () => mockApiClient.getNearbyHotels(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenAnswer((_) async => <domain.Hotel>[]);

        final result = await repository.nearbyHotels(
          latitude: -7.42,
          longitude: 109.23,
          radiusKm: 50,
        );

        expect(result, isNotEmpty);
        expect(result.first.id, 'mock-1');
      });

      test('falls back to mock on API exception', () async {
        when(
          () => mockApiClient.getNearbyHotels(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenThrow(
          const ApiException('Timeout', statusCode: 408),
        );

        final result = await repository.nearbyHotels(
          latitude: -7.42,
          longitude: 109.23,
          radiusKm: 50,
        );

        expect(result, isNotEmpty);
      });
    });

    group('hotelById', () {
      test('returns null (stub for FE-1305)', () async {
        final result = await repository.hotelById('some-id');
        expect(result, isNull);
      });
    });
  });
}
