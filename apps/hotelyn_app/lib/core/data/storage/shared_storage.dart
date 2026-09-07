import 'dart:convert';

import 'package:hotelyn/features/location/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SharedStorage {
  SharedStorage({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  static const introItemKey = 'intro_passed';
  static const userIdKey = 'user_id';
  static const userLocationKey = 'user_location';
  static const locationPermissionKey = 'location_permission_status';

  Future<bool> isIntroPassed() async {
    return sharedPreferences.getBool(introItemKey) ?? false;
  }

  void setIntroPassed() => sharedPreferences.setBool(introItemKey, true);

  /// Returns the stored user ID if the user is authenticated.
  String? getUserId() {
    return sharedPreferences.getString(userIdKey);
  }

  /// Generates and stores a unique user ID for the authenticated user.
  /// Returns the generated user ID.
  Future<String> setUserId() async {
    final userId = const Uuid().v4();
    await sharedPreferences.setString(userIdKey, userId);
    return userId;
  }

  /// Clears the stored user ID (for logout).
  Future<void> clearUserId() async {
    await sharedPreferences.remove(userIdKey);
  }

  /// Stores the selected or acquired [UserLocation].
  Future<void> saveUserLocation(UserLocation location) async {
    await sharedPreferences.setString(
      userLocationKey,
      jsonEncode(location.toJson()),
    );
  }

  /// Retrieves the persisted [UserLocation], if any.
  UserLocation? getUserLocation() {
    final raw = sharedPreferences.getString(userLocationKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return UserLocation.fromJson(decoded);
    } on Object catch (_) {
      return null;
    }
  }

  /// Stores the current [LocationPermissionStatus].
  Future<void> saveLocationPermissionStatus(
    LocationPermissionStatus status,
  ) async {
    await sharedPreferences.setString(locationPermissionKey, status.name);
  }

  /// Retrieves the persisted [LocationPermissionStatus].
  LocationPermissionStatus? getLocationPermissionStatus() {
    final name = sharedPreferences.getString(locationPermissionKey);
    if (name == null) return null;
    for (final status in LocationPermissionStatus.values) {
      if (status.name == name) {
        return status;
      }
    }
    return LocationPermissionStatus.unknown;
  }
}
