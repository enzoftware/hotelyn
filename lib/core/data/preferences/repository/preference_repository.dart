/// Handles information stored on the local storage of the app.
abstract class PreferenceRepository {
  /// Returns if the user already passed trough the on boarding process.
  ///
  /// Depending on the result the user will be redirected to the Home flow
  /// or to the on on boarding flow.
  Future<bool> isOnBoardingPassed();

  /// Set that the user already passed trough the on boarding process.
  void setOnBoardingPassed();
}
