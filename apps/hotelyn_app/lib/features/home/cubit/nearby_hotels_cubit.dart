import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:hotelyn/features/home/cubit/nearby_hotels_state.dart';
import 'package:hotelyn_api_client/hotelyn_api_client.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;

export 'nearby_hotels_state.dart';

/// Cubit that loads nearby hotels for the user's current location.
///
/// Consumes [domain.HotelRepository.nearbyHotels] and manages loading,
/// loaded, and failure states.
class NearbyHotelsCubit extends Cubit<NearbyHotelsState> {
  NearbyHotelsCubit({
    required this.hotelRepository,
  }) : super(const NearbyHotelsInitial());

  /// Creates a dummy cubit without an active repository, useful in widget
  /// tests.
  NearbyHotelsCubit.uninitialized()
    : hotelRepository = null,
      super(const NearbyHotelsInitial());

  /// The repository providing hotel catalogue and proximity queries.
  final domain.HotelRepository? hotelRepository;

  /// Default search radius in kilometres.
  static const _defaultRadiusKm = 50.0;

  /// Loads nearby hotels for the given coordinates.
  Future<void> loadNearbyHotels({
    required double latitude,
    required double longitude,
    double radiusKm = _defaultRadiusKm,
  }) async {
    final repo = hotelRepository;
    if (repo == null) return;

    emit(const NearbyHotelsLoading());
    try {
      final hotels = await repo.nearbyHotels(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      emit(NearbyHotelsLoaded(hotels: hotels));
    } on ApiException catch (error, stack) {
      log(
        'API error loading nearby hotels',
        error: error,
        stackTrace: stack,
        name: 'NearbyHotelsCubit',
      );
      emit(NearbyHotelsFailure(message: error.toString()));
    } on Exception catch (error, stack) {
      log(
        'Failed to load nearby hotels',
        error: error,
        stackTrace: stack,
        name: 'NearbyHotelsCubit',
      );
      emit(NearbyHotelsFailure(message: error.toString()));
    }
  }
}
