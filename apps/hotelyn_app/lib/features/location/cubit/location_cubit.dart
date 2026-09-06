import 'package:bloc/bloc.dart';
import 'package:hotelyn/features/location/cubit/location_state.dart';
import 'package:hotelyn/features/location/models/models.dart';
import 'package:hotelyn/features/location/repository/location_repository.dart';

/// Cubit managing location state, permission priming, OS permission requests,
/// and manual fallback destinations.
class LocationCubit extends Cubit<LocationState> {
  LocationCubit({
    required LocationRepository locationRepository,
  })  : _locationRepository = locationRepository,
        super(const LocationState());

  final LocationRepository _locationRepository;

  /// Loads persisted permission status and active location.
  Future<void> loadLocation() async {
    emit(state.copyWith(isLoading: true));
    try {
      final status = await _locationRepository.getPermissionStatus();
      final location = await _locationRepository.getLocation();
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
    await _locationRepository.markAsPrimed();
    emit(
      state.copyWith(
        isPrimingSheetVisible: true,
        permissionStatus: LocationPermissionStatus.primed,
      ),
    );
  }

  /// Dismisses the priming sheet without taking further action.
  void dismissPriming() {
    emit(state.copyWith(isPrimingSheetVisible: false));
  }

  /// Invoked when the user taps "Enable Location" from the priming sheet.
  /// Dismisses the priming sheet and invokes the OS permission request.
  Future<void> requestPermissionFromPriming() async {
    emit(
      state.copyWith(
        isPrimingSheetVisible: false,
        isLoading: true,
      ),
    );

    try {
      final result = await _locationRepository.requestPermission();
      emit(
        state.copyWith(
          permissionStatus: result.status,
          userLocation: result.location,
          isLoading: false,
          // When denied, prompt manual location entry fallback
          isManualLocationDialogOpen:
              result.status == LocationPermissionStatus.denied,
        ),
      );
    } on Exception catch (e) {
      final fallback = await _locationRepository.setManualLocation();
      emit(
        state.copyWith(
          permissionStatus: LocationPermissionStatus.denied,
          userLocation: fallback,
          isLoading: false,
          errorMessage: e.toString(),
          isManualLocationDialogOpen: true,
        ),
      );
    }
  }

  /// Invoked when user taps "Maybe Later" or "Enter Location Manually"
  /// from priming sheet.
  Future<void> enterLocationManuallyFromPriming() async {
    emit(
      state.copyWith(
        isPrimingSheetVisible: false,
        isManualLocationDialogOpen: true,
      ),
    );
    await _locationRepository.savePermissionStatus(
      LocationPermissionStatus.denied,
    );
    final fallback = await _locationRepository.setManualLocation();
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
      final saved =
          await _locationRepository.setManualLocation(location: location);
      emit(
        state.copyWith(
          userLocation: saved,
          isManualLocationDialogOpen: false,
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

  /// Opens the manual location selector dialog/sheet.
  void openManualLocationDialog() {
    emit(state.copyWith(isManualLocationDialogOpen: true));
  }

  /// Closes the manual location selector dialog/sheet.
  void closeManualLocationDialog() {
    emit(state.copyWith(isManualLocationDialogOpen: false));
  }
}
