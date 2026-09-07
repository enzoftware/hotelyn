import 'package:bloc/bloc.dart';
import 'package:hotelyn/features/location/cubit/location_state.dart';
import 'package:hotelyn/features/location/models/models.dart';
import 'package:hotelyn/features/location/repository/location_repository.dart';

/// Cubit managing location state, permission priming, OS permission requests,
/// and manual fallback destinations.
class LocationCubit extends Cubit<LocationState> {
  LocationCubit({
    required this.locationRepository,
  }) : super(const LocationState());

  final LocationRepository locationRepository;

  /// Loads persisted permission status and active location.
  Future<void> loadLocation() async {
    emit(state.copyWith(isLoading: true));
    try {
      final status = await locationRepository.getPermissionStatus();
      final location = await locationRepository.getLocation();
      emit(
        state.copyWith(
          permissionStatus: status,
          userLocation: location,
          isLoading: false,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Triggers the priming sheet before the OS permission prompt.
  /// If permission was already granted, priming is skipped.
  Future<void> triggerPriming() async {
    if (state.permissionStatus == LocationPermissionStatus.granted) {
      return;
    }
    await locationRepository.markAsPrimed();
    emit(
      state.copyWith(
        permissionStatus: LocationPermissionStatus.primed,
      ),
    );
  }

  /// Invoked when the user taps "Enable Location" from the priming sheet.
  /// Requests OS permission and updates location and permission status.
  Future<void> requestPermissionFromPriming() async {
    emit(state.copyWith(isLoading: true));

    try {
      final result = await locationRepository.requestPermission();
      emit(
        state.copyWith(
          permissionStatus: result.status,
          userLocation: result.location,
          isLoading: false,
        ),
      );
    } on Exception catch (e) {
      final fallback = await locationRepository.setManualLocation();
      emit(
        state.copyWith(
          permissionStatus: LocationPermissionStatus.denied,
          userLocation: fallback,
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Invoked when user taps "Maybe Later" or "Enter Location Manually"
  /// from priming sheet.
  Future<void> enterLocationManuallyFromPriming() async {
    await locationRepository.savePermissionStatus(
      LocationPermissionStatus.denied,
    );
    final fallback = await locationRepository.setManualLocation();
    emit(
      state.copyWith(
        permissionStatus: LocationPermissionStatus.denied,
        userLocation: fallback,
      ),
    );
  }

  /// Sets a manual fallback location chosen by the user.
  Future<void> setManualLocation(UserLocation location) async {
    emit(state.copyWith(isLoading: true));
    try {
      final saved = await locationRepository.setManualLocation(
        location: location,
      );
      emit(
        state.copyWith(
          userLocation: saved,
          isLoading: false,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Sets the default fallback location ("Purwokerto, IND").
  Future<void> selectDefaultFallback() async {
    await setManualLocation(UserLocation.defaultFallback);
  }
}
