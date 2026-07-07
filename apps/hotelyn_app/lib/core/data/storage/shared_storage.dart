import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SharedStorage {
  SharedStorage({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  static const introItemKey = 'intro_passed';
  static const userIdKey = 'user_id';

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
}
