import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:test/test.dart';

// AuthSession decodes the OTP-verify / login REST body (EPIC-06).
void main() {
  group('AuthSession.fromJson', () {
    AuthSession decode() => AuthSession.fromJson(const {
          'access_token': 'access-123',
          'refresh_token': 'refresh-456',
          'user_id': 'user-1',
          'expires_in': 3600,
          'token_type': 'bearer',
        });

    test('maps the session body', () {
      final session = decode();
      expect(session.accessToken, 'access-123');
      expect(session.refreshToken, 'refresh-456');
      expect(session.userId, 'user-1');
      expect(session.expiresIn, 3600);
      expect(session.tokenType, 'bearer');
    });

    test('round-trips through toJson', () {
      expect(AuthSession.fromJson(decode().toJson()), equals(decode()));
    });

    test('supports value equality', () {
      expect(decode(), equals(decode()));
    });

    test('toString does not leak the tokens', () {
      final text = decode().toString();
      expect(text, contains('user-1'));
      expect(text, isNot(contains('access-123')));
      expect(text, isNot(contains('refresh-456')));
    });
  });
}
