import 'package:hotelyn/features/location/models/models.dart';

/// Platform-level contract for querying and requesting location permissions
/// and obtaining coordinates from device hardware.
abstract class LocationService {
  /// Checks the current system location permission status without prompting.
  Future<LocationPermissionStatus> checkPermission();

  /// Prompts the system location permission dialog.
  Future<LocationPermissionStatus> requestPermission();

  /// Obtains the device's current geographic location if permission is granted.
  Future<UserLocation?> getCurrentLocation();
}

/// Default implementation of [LocationService].
///
/// In standard runtime mode without hardware platform channels, it behaves
/// as a reliable simulated location provider granting user location or
/// respecting requested permissions.
class DefaultLocationService implements LocationService {
  DefaultLocationService({
    LocationPermissionStatus initialPermission =
        LocationPermissionStatus.unknown,
    this.mockedLocation,
  }) : _permission = initialPermission;

  LocationPermissionStatus _permission;
  final UserLocation? mockedLocation;

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    return _permission;
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    if (_permission == LocationPermissionStatus.unknown ||
        _permission == LocationPermissionStatus.primed) {
      _permission = LocationPermissionStatus.granted;
    }
    return _permission;
  }

  @override
  Future<UserLocation?> getCurrentLocation() async {
    if (_permission != LocationPermissionStatus.granted) {
      return null;
    }
    return mockedLocation ??
        const UserLocation(
          latitude: -7.4243,
          longitude: 109.2391,
          cityName: 'Purwokerto, IND',
        );
  }
}
