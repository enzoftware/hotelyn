import 'package:equatable/equatable.dart';
import 'package:hotelyn/features/location/models/models.dart';

/// State of location management, permission status, and manual fallbacks.
class LocationState extends Equatable {
  const LocationState({
    this.permissionStatus = LocationPermissionStatus.unknown,
    this.userLocation = UserLocation.defaultFallback,
    this.isLoading = false,
    this.errorMessage,
  });

  final LocationPermissionStatus permissionStatus;
  final UserLocation userLocation;
  final bool isLoading;
  final String? errorMessage;

  bool get isGranted => permissionStatus == LocationPermissionStatus.granted;
  bool get isDenied => permissionStatus == LocationPermissionStatus.denied;
  bool get isPrimed => permissionStatus == LocationPermissionStatus.primed;
  bool get isUnknown => permissionStatus == LocationPermissionStatus.unknown;

  LocationState copyWith({
    LocationPermissionStatus? permissionStatus,
    UserLocation? userLocation,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LocationState(
      permissionStatus: permissionStatus ?? this.permissionStatus,
      userLocation: userLocation ?? this.userLocation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        permissionStatus,
        userLocation,
        isLoading,
        errorMessage,
      ];
}
