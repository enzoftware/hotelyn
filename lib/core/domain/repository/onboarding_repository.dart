import 'package:hotelyn/core/data/storage/storage.dart';

/// Handles information stored on the local storage of the app.
class OnBoardingRepository {
  OnBoardingRepository({
    required SharedStorage sharedStorage,
  }) : _sharedStorage = sharedStorage;

  final SharedStorage _sharedStorage;

  /// Returns if the user already passed trough the on boarding process.
  ///
  /// Depending on the result the user will be redirected to the Home flow
  /// or to the on on boarding flow.
  Future<bool> isOnBoardingPassed() async {
    await Future.delayed(const Duration(seconds: 1));
    return await _sharedStorage.isOnBoardingPassed();
  }

  /// Set that the user already passed trough the on boarding process.
  void setOnBoardingPassed() => _sharedStorage.setOnBoaardingPassed();
}
