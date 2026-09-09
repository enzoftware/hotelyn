import 'package:hotelyn_api_client/hotelyn_api_client.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;

/// App-level implementation of [domain.HotelRepository] backed by
/// [HotelynApiClient].
///
/// Falls back gracefully: if the recommended endpoint returns an empty list,
/// the nearby endpoint is tried; if that is also empty, a small local mock
/// catalogue is returned so the UI never shows an empty state on first launch.
class AppHotelRepository implements domain.HotelRepository {
  /// Creates a repository backed by [apiClient].
  ///
  /// Set [fallbackToMock] to `false` to propagate [ApiException]s and return
  /// empty lists directly from the API without substituting [_mockHotels].
  /// Defaults to `true` to ensure the home screen never renders empty in
  /// local development before the backend is running and seeded.
  const AppHotelRepository({
    required this.apiClient,
    this.fallbackToMock = true,
  });

  /// The underlying API client.
  final HotelynApiClient apiClient;

  /// Whether to fallback to [_mockHotels] when the API returns an empty list
  /// or throws an [ApiException].
  final bool fallbackToMock;

  @override
  Future<List<domain.Hotel>> recommendedHotels({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      final hotels = await apiClient.getRecommendedHotels(
        lat: latitude,
        lng: longitude,
        radiusKm: radiusKm,
      );
      if (hotels.isNotEmpty) return hotels;

      // Fallback: try nearby if recommended is empty.
      final nearby = await apiClient.getNearbyHotels(
        lat: latitude,
        lng: longitude,
        radiusKm: radiusKm,
      );
      if (nearby.isNotEmpty) return nearby;

      if (!fallbackToMock) return <domain.Hotel>[];
      return _mockHotels;
    } on ApiException {
      if (!fallbackToMock) rethrow;
      return _mockHotels;
    }
  }

  @override
  Future<List<domain.Hotel>> nearbyHotels({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      final hotels = await apiClient.getNearbyHotels(
        lat: latitude,
        lng: longitude,
        radiusKm: radiusKm,
      );
      if (hotels.isNotEmpty || !fallbackToMock) return hotels;
      return _mockHotels;
    } on ApiException {
      if (!fallbackToMock) rethrow;
      return _mockHotels;
    }
  }

  @override
  Future<domain.Hotel?> hotelById(String hotelId) async {
    // Not needed for FE-1302; will be implemented in FE-1305.
    return null;
  }

  /// Hard-coded catalogue so the home screen never renders empty before the
  /// backend is running / seeded.
  static const _mockHotels = <domain.Hotel>[
    domain.Hotel(
      id: 'mock-1',
      name: 'Grand Royal Hotel',
      city: 'Purwokerto',
      country: 'Indonesia',
      description: 'A luxurious hotel with stunning views.',
      popularity: 95,
    ),
    domain.Hotel(
      id: 'mock-2',
      name: 'Paradise Beach Resort',
      city: 'Bali',
      country: 'Indonesia',
      description: 'Beachfront resort with world-class amenities.',
      popularity: 88,
    ),
    domain.Hotel(
      id: 'mock-3',
      name: 'Mountain View Lodge',
      city: 'Yogyakarta',
      country: 'Indonesia',
      description: 'Nestled in the mountains with panoramic views.',
      popularity: 72,
    ),
  ];
}
