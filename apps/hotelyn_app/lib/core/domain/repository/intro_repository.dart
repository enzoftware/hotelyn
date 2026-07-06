import 'package:hotelyn/core/data/storage/storage.dart';

/// Handles information stored on the local storage of the app.
class IntroRepository {
  IntroRepository({
    required SharedStorage sharedStorage,
  }) : _sharedStorage = sharedStorage;

  final SharedStorage _sharedStorage;

  /// Returns if the user already passed trough the intro process.
  ///
  /// Depending on the result the user will be redirected to the Home flow
  /// or to the intro flow.
  Future<bool> isIntroPassed() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return _sharedStorage.isIntroPassed();
  }

  /// Set that the user already passed trough the intro process.
  void setIntroPassed() => _sharedStorage.setIntroPassed();
}
