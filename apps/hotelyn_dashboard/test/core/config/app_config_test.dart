import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn_dashboard/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    group('graphqlUrl', () {
      test('uses the default localhost value when no dart-define is supplied',
          () {
        expect(
          AppConfig.graphqlUrl,
          'http://127.0.0.1:8080/graphql',
        );
      });

      test('is a non-empty string', () {
        expect(AppConfig.graphqlUrl, isNotEmpty);
      });

      test('starts with http scheme', () {
        expect(
          AppConfig.graphqlUrl,
          startsWith('http'),
        );
      });
    });
  });
}
