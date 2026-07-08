/// Compile-time configuration values injected via `--dart-define` or
/// `--dart-define-from-file`.
///
/// **Usage**
/// ```sh
/// # From individual flags:
/// flutter run -t lib/main_development.dart \
///   --dart-define=API_BASE_URL=http://127.0.0.1:8080
///
/// # From a dart-define file (recommended):
/// flutter run -t lib/main_development.dart \
///   --dart-define-from-file=.dart_defines/local.json
/// ```
///
/// See `.dart_defines/*.json.example` for the expected file format.
class AppConfig {
  const AppConfig._();

  /// Base URL of the Hotelyn REST backend (no path suffix).
  ///
  /// Default resolves to the local Dart Frog server on the same host
  /// (simulator / desktop). Override for Android emulator or physical device:
  ///   - Android emulator: `http://10.0.2.2:8080`
  ///   - Physical device: `http://<LAN-IP>:8080`
  ///   - Staging: `https://api.staging.hotelyn.com`
  ///   - Production: `https://api.hotelyn.com`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );
}
