import 'package:hotelyn_server/hotelyn_server.dart';

/// A configurable in-memory [AuthClient] for auth-route tests.
///
/// Records the last arguments and returns a canned [AuthSession]; set
/// [throwFailure] to make every method raise it instead.
class FakeAuthClient implements AuthClient {
  String? lastEmail;
  String? lastToken;
  String? lastPassword;

  /// When set, every method throws this instead of succeeding.
  AuthFailure? throwFailure;

  static const _session = AuthSession(
    accessToken: 'access-123',
    refreshToken: 'refresh-456',
    userId: 'user-1',
    expiresIn: 3600,
    tokenType: 'bearer',
  );

  @override
  Future<void> requestEmailOtp(String email) async {
    if (throwFailure != null) throw throwFailure!;
    lastEmail = email;
  }

  @override
  Future<AuthSession> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    if (throwFailure != null) throw throwFailure!;
    lastEmail = email;
    lastToken = token;
    return _session;
  }

  @override
  Future<AuthSession> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (throwFailure != null) throw throwFailure!;
    lastEmail = email;
    lastPassword = password;
    return _session;
  }
}
