/// Status of the location permission request flow.
enum LocationPermissionStatus {
  /// Permission has not yet been requested or primed.
  unknown,

  /// Priming screen or explanation was shown to the user before requesting.
  primed,

  /// Location permission has been granted by the user.
  granted,

  /// Location permission was denied by the user.
  denied,
}
