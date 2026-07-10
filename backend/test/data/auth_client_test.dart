import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase/supabase.dart' as gotrue;
import 'package:test/test.dart';

class _MockGoTrueClient extends Mock implements gotrue.GoTrueClient {}

void main() {
  late _MockGoTrueClient auth;
  late SupabaseAuthClient client;

  setUpAll(() {
    registerFallbackValue(gotrue.OtpType.email);
  });

  setUp(() {
    auth = _MockGoTrueClient();
    client = SupabaseAuthClient(auth);
  });

  // Builds an AuthResponse carrying a session with the given tokens.
  gotrue.AuthResponse authResponse({
    String? refreshToken = 'refresh-1',
    int? expiresIn = 3600,
  }) {
    final user = gotrue.User(
      id: 'user-1',
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: DateTime.utc(2026).toIso8601String(),
    );
    return gotrue.AuthResponse(
      session: gotrue.Session(
        accessToken: 'access-1',
        refreshToken: refreshToken,
        expiresIn: expiresIn,
        tokenType: 'bearer',
        user: user,
      ),
      user: user,
    );
  }

  void stubSignIn(gotrue.AuthResponse Function() answer) {
    when(
      () => auth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => answer());
  }

  void throwOnSignIn(gotrue.AuthException error) {
    when(
      () => auth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(error);
  }

  group('signInWithPassword', () {
    test('maps a session into an AuthSession', () async {
      stubSignIn(authResponse);

      final session = await client.signInWithPassword(
        email: 'staff@hotelyn.test',
        password: 'password123',
      );

      expect(session.accessToken, 'access-1');
      expect(session.refreshToken, 'refresh-1');
      expect(session.userId, 'user-1');
      expect(session.expiresIn, 3600);
    });

    test('a missing refresh token is a no_session failure', () async {
      stubSignIn(() => authResponse(refreshToken: null));

      await expectLater(
        client.signInWithPassword(email: 'e', password: 'p'),
        throwsA(
          isA<AuthFailure>().having((e) => e.code, 'code', 'no_session'),
        ),
      );
    });
  });

  group('_mapError (via a thrown gotrue.AuthException)', () {
    test('forwards code and parses the numeric status', () async {
      throwOnSignIn(
        const gotrue.AuthException(
          'Invalid login credentials',
          statusCode: '401',
          code: 'invalid_credentials',
        ),
      );

      await expectLater(
        client.signInWithPassword(email: 'e', password: 'p'),
        throwsA(
          isA<AuthFailure>()
              .having((e) => e.code, 'code', 'invalid_credentials')
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('derives a rate-limit code and retry-after from the message',
        () async {
      when(() => auth.signInWithOtp(email: any(named: 'email'))).thenThrow(
        const gotrue.AuthException(
          'For security purposes, you can only request this after 27 seconds.',
          statusCode: '429',
        ),
      );

      await expectLater(
        client.requestEmailOtp('guest@hotelyn.test'),
        throwsA(
          isA<AuthFailure>()
              .having((e) => e.code, 'code', 'over_request_rate_limit')
              .having((e) => e.retryAfterSeconds, 'retryAfter', 27)
              .having((e) => e.statusCode, 'statusCode', 429),
        ),
      );
    });

    test('falls back to otp_expired for an expired/invalid message', () async {
      when(
        () => auth.verifyOTP(
          email: any(named: 'email'),
          token: any(named: 'token'),
          type: any(named: 'type'),
        ),
      ).thenThrow(
        const gotrue.AuthException('Token has expired or is invalid'),
      );

      await expectLater(
        client.verifyEmailOtp(email: 'e', token: '000000'),
        throwsA(
          isA<AuthFailure>().having((e) => e.code, 'code', 'otp_expired'),
        ),
      );
    });
  });
}
