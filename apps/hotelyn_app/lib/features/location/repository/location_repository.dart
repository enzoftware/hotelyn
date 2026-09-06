import 'package:hotelyn/core/data/storage/storage.dart';
import 'package:hotelyn/features/location/models/models.dart';
import 'package:hotelyn/features/location/services/location_service.dart';

/// Repository managing location permissions, hardware location queries,
/// manual fallback locations, and persistence in [SharedStorage].
class LocationRepository {
  LocationRepository({
    required SharedStorage sharedStorage,
    LocationService? locationService,
  })  : _sharedStorage = sharedStorage,
        _locationService = locationService ?? DefaultLocationService();

  final SharedStorage _sharedStorage;
  final LocationService _locationService;

  /// Retrieves the current stored permission status, or checks the system
  /// status if no status has been recorded yet.
  Future<LocationPermissionStatus> getPermissionStatus() async {
    final stored = _sharedStorage.getLocationPermissionStatus();
    if (stored != null && stored != LocationPermissionStatus.unknown) {
      return stored;
    }
    final systemStatus = await _locationService.checkPermission();
    if (systemStatus != LocationPermissionStatus.unknown) {
      await _sharedStorage.saveLocationPermissionStatus(systemStatus);
    }
    return systemStatus;
  }

  /// Records that the user was primed with product rationale.
  Future<void> markAsPrimed() async {
    await _sharedStorage.saveLocationPermissionStatus(
      LocationPermissionStatus.primed,
    );
  }

  /// Requests the OS permission dialog.
  ///
  /// If granted, retrieves current coordinates and updates storage.
  /// If denied, ensures a manual fallback is available so downstream features
  /// have valid data.
  Future<({LocationPermissionStatus status, UserLocation location})>
      requestPermission() async {
    final status = await _locationService.requestPermission();
    await _sharedStorage.saveLocationPermissionStatus(status);

    if (status == LocationPermissionStatus.granted) {
      final acquired = await _locationService.getCurrentLocation();
      final location = acquired ??
          UserLocation.defaultFallback.copyWith(isManualFallback: false);
      await _sharedStorage.saveUserLocation(location);
      return (status: status, location: location);
    } else {
      final fallback =
          _sharedStorage.getUserLocation() ?? UserLocation.defaultFallback;
      await _sharedStorage.saveUserLocation(fallback);
      return (status: status, location: fallback);
    }
  }

  /// Retrieves the active location, returning persisted data or falling back
  /// to [UserLocation.defaultFallback].
  Future<UserLocation> getLocation() async {
    final stored = _sharedStorage.getUserLocation();
    if (stored != null) {
      return stored;
    }
    const defaultLoc = UserLocation.defaultFallback;
    await _sharedStorage.saveUserLocation(defaultLoc);
    return defaultLoc;
  }

  /// Sets a manual fallback location chosen by the user (or defaults
  /// to Purwokerto).
  Future<UserLocation> setManualLocation({UserLocation? location}) async {
    final chosen = location ?? UserLocation.defaultFallback;
    final manualLoc = chosen.copyWith(isManualFallback: true);
    await _sharedStorage.saveUserLocation(manualLoc);
    return manualLoc;
  }

  /// Persists permission status directly.
  Future<void> savePermissionStatus(LocationPermissionStatus status) async {
    await _sharedStorage.saveLocationPermissionStatus(status);
  }
}
