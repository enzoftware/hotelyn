import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:hotelyn/features/home/cubit/recommended_hotels_state.dart';
import 'package:hotelyn_api_client/hotelyn_api_client.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;

export 'recommended_hotels_state.dart';

/// Cubit that loads recommended hotels for the user's current location.
///
/// The hotel repository handles the API call and its own fallback logic
/// (recommended → nearby → mock catalogue). This cubit therefore treats an
/// empty list as a valid success state (it would only happen if the
/// repository itself had no fallback data).
class RecommendedHotelsCubit extends Cubit<RecommendedHotelsState> {
  RecommendedHotelsCubit({
    required this.hotelRepository,
  }) : super(const RecommendedHotelsInitial());

  /// Creates a dummy cubit without an active repository, useful in widget
  /// tests.
  RecommendedHotelsCubit.uninitialized()
    : hotelRepository = null,
      super(const RecommendedHotelsInitial());

  /// The repository providing hotel catalogue and proximity queries.
  final domain.HotelRepository? hotelRepository;

  /// Default search radius in kilometres.
  static const _defaultRadiusKm = 50.0;

  /// Loads recommended hotels for the given coordinates.
  ///
  /// Safe to call multiple times; a subsequent call cancels the prior result
  /// by simply emitting a new loading state.
  Future<void> loadRecommendedHotels({
    required double latitude,
    required double longitude,
    double radiusKm = _defaultRadiusKm,
  }) async {
    final repo = hotelRepository;
    if (repo == null) return;

    emit(const RecommendedHotelsLoading());
    try {
      final hotels = await repo.recommendedHotels(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      emit(RecommendedHotelsLoaded(hotels: hotels));
    } on ApiException catch (error, stack) {
      log(
        'API error loading recommended hotels',
        error: error,
        stackTrace: stack,
        name: 'RecommendedHotelsCubit',
      );
      emit(RecommendedHotelsFailure(message: error.toString()));
    } on Exception catch (error, stack) {
      log(
        'Failed to load recommended hotels',
        error: error,
        stackTrace: stack,
        name: 'RecommendedHotelsCubit',
      );
      emit(RecommendedHotelsFailure(message: error.toString()));
    }
  }
}
