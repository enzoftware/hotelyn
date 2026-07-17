import 'package:hotelyn_domain/src/hotel.dart';

/// Read access to the hotel catalogue and proximity search.
///
/// A shared-vocabulary contract: the Dart Frog service layer (BE-902)
/// implements it, and any future client speaks the same interface. Every method
/// takes and returns domain types only — no Supabase `PostgrestList`, no Ferry
/// `GData`.
abstract class HotelRepository {
  /// Hotels within [radiusKm] of ([latitude], [longitude]), nearest-first.
  Future<List<Hotel>> nearbyHotels({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  /// Popular-yet-nearby hotels within [radiusKm] of ([latitude], [longitude]).
  Future<List<Hotel>> recommendedHotels({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  /// The hotel with [hotelId], or `null` if none exists.
  Future<Hotel?> hotelById(String hotelId);
}
