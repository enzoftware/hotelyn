import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    group('apiBaseUrl', () {
      test('uses the default localhost value when no dart-define is supplied',
          () {
        expect(
          AppConfig.apiBaseUrl,
          'http://127.0.0.1:8080',
        );
      });

      test('is a non-empty string', () {
        expect(AppConfig.apiBaseUrl, isNotEmpty);
      });

      test('starts with http scheme', () {
        expect(
          AppConfig.apiBaseUrl,
          startsWith('http'),
        );
      });
    });
  });
}
