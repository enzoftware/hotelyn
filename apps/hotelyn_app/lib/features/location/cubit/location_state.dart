import 'package:equatable/equatable.dart';
import 'package:hotelyn/features/location/models/models.dart';

/// State of location management, permission status, and manual fallbacks.
class LocationState extends Equatable {
  const LocationState({
    this.permissionStatus = LocationPermissionStatus.unknown,
    this.userLocation = UserLocation.defaultFallback,
    this.isPrimingSheetVisible = false,
    this.isManualLocationDialogOpen = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final LocationPermissionStatus permissionStatus;
  final UserLocation userLocation;
  final bool isPrimingSheetVisible;
  final bool isManualLocationDialogOpen;
  final bool isLoading;
  final String? errorMessage;

  bool get isGranted => permissionStatus == LocationPermissionStatus.granted;
  bool get isDenied => permissionStatus == LocationPermissionStatus.denied;
  bool get isPrimed => permissionStatus == LocationPermissionStatus.primed;
  bool get isUnknown => permissionStatus == LocationPermissionStatus.unknown;

  LocationState copyWith({
    LocationPermissionStatus? permissionStatus,
    UserLocation? userLocation,
    bool? isPrimingSheetVisible,
    bool? isManualLocationDialogOpen,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LocationState(
      permissionStatus: permissionStatus ?? this.permissionStatus,
      userLocation: userLocation ?? this.userLocation,
      isPrimingSheetVisible:
          isPrimingSheetVisible ?? this.isPrimingSheetVisible,
      isManualLocationDialogOpen:
          isManualLocationDialogOpen ?? this.isManualLocationDialogOpen,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        permissionStatus,
        userLocation,
        isPrimingSheetVisible,
        isManualLocationDialogOpen,
        isLoading,
        errorMessage,
      ];
}
