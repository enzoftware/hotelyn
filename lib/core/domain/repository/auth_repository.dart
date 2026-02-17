import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:hotelyn/core/data/storage/storage.dart';

/// Repository for handling authentication persistence and Clarity user
/// tracking.
///
/// This repository manages user session persistence using SharedPreferences
/// and integrates with Microsoft Clarity for user identification tracking.
class AuthRepository {
  AuthRepository({
    required SharedStorage sharedStorage,
  }) : _sharedStorage = sharedStorage;

  final SharedStorage _sharedStorage;

  /// Checks if a user is currently authenticated.
  ///
  /// Returns `true` if a user ID exists in local storage.
  bool get isAuthenticated => _sharedStorage.getUserId() != null;

  /// Returns the current user ID if authenticated, `null` otherwise.
  String? get currentUserId => _sharedStorage.getUserId();

  /// Performs login by generating and storing a unique user ID.
  ///
  /// Also sets the custom user ID in Clarity for session tracking.
  /// Returns the generated user ID.
  Future<String> login() async {
    final userId = await _sharedStorage.setUserId();
    Clarity.setCustomUserId(userId);
    Clarity.setCustomTag('login_success', 'credentials');
    return userId;
  }

  /// Performs logout by clearing the stored user ID.
  Future<void> logout() async {
    await _sharedStorage.clearUserId();
  }

  /// Initializes Clarity tracking with the stored user ID on app startup.
  ///
  /// Call this method during app initialization to ensure returning users
  /// are tracked with their existing user ID in Clarity sessions.
  void initializeClarityUser() {
    final userId = currentUserId;
    if (userId != null) {
      Clarity.setCustomUserId(userId);
    }
  }
}
