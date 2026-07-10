import 'dart:async';

import 'package:supabase/supabase.dart' as gotrue;
import 'package:supabase/supabase.dart'
    show AuthResponse, GoTrueClient, OtpType;

/// A completed authentication: the session tokens the app persists to stay
/// signed in, plus the authenticated user's id.
///
/// This is the REST-facing shape — the app never sees GoTrue's `Session`
/// directly, only these fields it needs to attach the bearer token and refresh.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.expiresIn,
    required this.tokenType,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;

  /// Seconds until [accessToken] expires.
  final int expiresIn;
  final String tokenType;

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'user_id': userId,
        'expires_in': expiresIn,
        'token_type': tokenType,
      };
}

/// A recognized authentication failure, carrying a stable [code] the route
/// handlers map to an HTTP status and the client maps to an actionable message.
///
///   * `invalid_credentials` – wrong email/password (staff login)
///   * `otp_expired`         – the OTP is expired or incorrect
///   * `over_email_rate_limit` / `over_request_rate_limit` – cooldown; see
///     [retryAfterSeconds]
///   * `email_not_confirmed`, `user_banned`, … – other GoTrue conditions
class AuthFailure implements Exception {
  const AuthFailure(this.code, {this.statusCode, this.retryAfterSeconds});

  /// Stable machine-readable token (GoTrue error code, snake_case).
  final String code;

  /// The upstream HTTP status GoTrue returned (e.g. 401, 429), when known —
  /// lets callers branch on the class of failure without string-matching.
  final int? statusCode;

  /// For a rate-limit error, the seconds the caller should wait before
  /// retrying, when the server provided it.
  final int? retryAfterSeconds;

  @override
  String toString() => 'AuthFailure($code)';
}

/// The single seam through which the REST auth routes reach Supabase Auth
/// (GoTrue). No `gotrue`/`supabase` auth call originates outside an
/// implementation of this interface.
abstract class AuthClient {
  /// Requests an email OTP for [email]. A brand-new address is created on
  /// verification (no separate signup), so this always "works" for a valid
  /// email; it throws [AuthFailure] only for a rate-limit/cooldown.
  Future<void> requestEmailOtp(String email);

  /// Exchanges a valid [token] emailed to [email] for a session. Throws
  /// [AuthFailure] `otp_expired` for an expired/incorrect code.
  Future<AuthSession> verifyEmailOtp({
    required String email,
    required String token,
  });

  /// Signs a staff member in with [email] + [password]. Throws [AuthFailure]
  /// `invalid_credentials` when they do not match. There is no signup here:
  /// staff accounts are provisioned invite-only (Admin API / dashboard).
  Future<AuthSession> signInWithPassword({
    required String email,
    required String password,
  });
}

/// [AuthClient] backed by a GoTrue client using the project's ANON key.
///
/// Auth is a public flow (a signed-out user requesting/verifying a code), so it
/// runs with the anon key — NOT the service-role key the data client uses. The
/// service role would bypass the very rate limits and checks GoTrue enforces.
class SupabaseAuthClient implements AuthClient {
  const SupabaseAuthClient(
    this._auth, {
    this.requestTimeout = const Duration(seconds: 10),
  });

  final GoTrueClient _auth;

  /// Upper bound on a single GoTrue round-trip. A slow or unreachable Supabase
  /// Auth fails fast with a [TimeoutException] (which the routes turn into a
  /// `500`) instead of blocking the request thread indefinitely.
  final Duration requestTimeout;

  @override
  Future<void> requestEmailOtp(String email) async {
    try {
      await _auth.signInWithOtp(email: email).timeout(requestTimeout);
    } on gotrue.AuthException catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<AuthSession> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _auth
          .verifyOTP(email: email, token: token, type: OtpType.email)
          .timeout(requestTimeout);
      return _session(response);
    } on gotrue.AuthException catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<AuthSession> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth
          .signInWithPassword(email: email, password: password)
          .timeout(requestTimeout);
      return _session(response);
    } on gotrue.AuthException catch (error) {
      throw _mapError(error);
    }
  }

  AuthSession _session(AuthResponse response) {
    final session = response.session;
    // A usable session must carry a refresh token — without it the app can
    // never refresh silently, so treat its absence as a failed exchange rather
    // than returning a half-authenticated result (same as the null-session
    // case). expires_in defaults to the configured 1 h when GoTrue omits it.
    if (session == null || session.refreshToken == null) {
      throw const AuthFailure('no_session');
    }
    return AuthSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken!,
      userId: session.user.id,
      expiresIn: session.expiresIn ?? 3600,
      tokenType: session.tokenType,
    );
  }

  AuthFailure _mapError(gotrue.AuthException error) {
    final status = int.tryParse(error.statusCode ?? '');
    final code = error.code ?? _codeFromMessage(error.message, status);
    return AuthFailure(
      code,
      statusCode: status,
      retryAfterSeconds: _retryAfterFromMessage(error.message),
    );
  }

  /// Older GoTrue responses may omit a machine code; fall back to a coarse
  /// token derived from the [status] / [message] so callers still get something
  /// stable-ish.
  String _codeFromMessage(String message, int? status) {
    final lower = message.toLowerCase();
    if (status == 429 ||
        lower.contains('rate limit') ||
        lower.contains('too many')) {
      return 'over_request_rate_limit';
    }
    if (lower.contains('expired') || lower.contains('invalid')) {
      return 'otp_expired';
    }
    return 'auth_error';
  }

  /// GoTrue's cooldown message reads like "... after N seconds"; pull N out so
  /// the client can surface the remaining wait (BE-601). `null` when absent.
  int? _retryAfterFromMessage(String message) {
    final match =
        RegExp(r'after (\d+) seconds?').firstMatch(message.toLowerCase());
    return match == null ? null : int.tryParse(match.group(1)!);
  }
}
