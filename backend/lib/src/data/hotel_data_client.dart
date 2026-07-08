import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:supabase/supabase.dart';

/// Read-only access to Hotelyn's geolocation-search data.
///
/// This is the single seam through which the GraphQL layer reaches Supabase;
/// no `supabase` call originates outside an implementation of this interface.
abstract class HotelDataClient {
  /// Hotels within [radiusKm] of ([lat], [lng]), nearest-first
  /// (via `nearby_hotels`).
  Future<List<Hotel>> nearbyHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  });

  /// Popular-yet-nearby hotels within [radiusKm] (`recommended_hotels`).
  Future<List<Hotel>> recommendedHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  });

  /// Rooms (optionally for a single [hotelId]) with computed `available_now`
  /// (`rooms_with_availability`).
  Future<List<Room>> roomsAvailability({String? hotelId});
}

/// [HotelDataClient] backed by Supabase RPC calls to the SQL functions.
class SupabaseHotelDataClient implements HotelDataClient {
  const SupabaseHotelDataClient(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Hotel>> nearbyHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  }) =>
      _hotelsFromRpc('nearby_hotels', lat: lat, lng: lng, radiusKm: radiusKm);

  @override
  Future<List<Hotel>> recommendedHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  }) =>
      _hotelsFromRpc(
        'recommended_hotels',
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
      );

  /// Shared radius-search plumbing: `nearby_hotels` and `recommended_hotels`
  /// take the same params and row shape, differing only in ranking.
  Future<List<Hotel>> _hotelsFromRpc(
    String function, {
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    final rows = await _client.rpc<List<dynamic>>(
      function,
      params: {'lat': lat, 'lng': lng, 'radius_km': radiusKm},
    );
    return rows
        .map((row) => hotelFromRow(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Room>> roomsAvailability({String? hotelId}) async {
    final rows = await _client.rpc<List<dynamic>>(
      'rooms_with_availability',
      params: {'p_hotel_id': hotelId},
    );
    return rows.map((row) => roomFromRow(row as Map<String, dynamic>)).toList();
  }
}

/// Maps a `nearby_hotels` / `recommended_hotels` result row to a [Hotel].
///
/// Kept as a pure top-level function so it is unit-testable without a live
/// Supabase connection.
Hotel hotelFromRow(Map<String, dynamic> row) {
  return Hotel(
    id: row['id'] as String,
    name: row['name'] as String,
    city: row['city'] as String,
    country: row['country'] as String,
    description: row['description'] as String?,
    address: row['address'] as String?,
    latitude: _toDouble(row['latitude']),
    longitude: _toDouble(row['longitude']),
    distanceKm: _toDouble(row['distance_km']),
    popularity: (row['popularity'] as num?)?.toInt(),
  );
}

/// Maps a `rooms_with_availability` result row to a [Room].
Room roomFromRow(Map<String, dynamic> row) {
  return Room(
    id: row['id'] as String,
    hotelId: row['hotel_id'] as String,
    name: row['name'] as String,
    roomType: row['room_type'] as String,
    capacity: (row['capacity'] as num).toInt(),
    // price_per_night is NOT NULL in the schema; parse it directly so a missing
    // value surfaces as an error rather than a silent "free" room.
    pricePerNight: (row['price_per_night'] as num).toDouble(),
    isAvailable: row['is_available'] as bool,
    availableNow: row['available_now'] as bool,
  );
}

double? _toDouble(Object? value) => (value as num?)?.toDouble();
