import 'package:shared_preferences/shared_preferences.dart';

class SharedStorage {
  SharedStorage({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  static const introItemKey = 'intro_passed';

  Future<bool> isIntroPassed() async {
    return sharedPreferences.getBool(introItemKey) ?? false;
  }

  void setIntroPassed() => sharedPreferences.setBool(introItemKey, true);
}
