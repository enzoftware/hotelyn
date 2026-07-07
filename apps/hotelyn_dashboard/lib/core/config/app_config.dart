/// Compile-time configuration values injected via `--dart-define` or
/// `--dart-define-from-file`.
///
/// **Usage**
/// ```sh
/// # From individual flags:
/// flutter run -t lib/main_development.dart \
///   --dart-define=GRAPHQL_URL=http://127.0.0.1:8080/graphql
///
/// # From a dart-define file (recommended):
/// flutter run -t lib/main_development.dart \
///   --dart-define-from-file=.dart_defines/local.json
/// ```
///
/// See `.dart_defines/*.json.example` for the expected file format.
class AppConfig {
  const AppConfig._();

  /// HTTP endpoint of the Hotelyn GraphQL backend.
  ///
  /// Default resolves to the local Dart Frog server on the same host
  /// (desktop / web). Override for remote environments:
  ///   - Staging:    `https://api.staging.hotelyn.com/graphql`
  ///   - Production: `https://api.hotelyn.com/graphql`
  static const String graphqlUrl = String.fromEnvironment(
    'GRAPHQL_URL',
    defaultValue: 'http://127.0.0.1:8080/graphql',
  );
}
