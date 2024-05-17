import 'package:shared_preferences/shared_preferences.dart';

class PreferenceLocalDataSource {
  PreferenceLocalDataSource({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  static const onBoardingItemKey = 'on_boarding_passed';

  Future<bool> isOnBoardingPassed() async {
    return sharedPreferences.getBool(onBoardingItemKey) ?? false;
  }

  void setOnBoaardingPassed() async =>
      sharedPreferences.setBool(onBoardingItemKey, true);
}
