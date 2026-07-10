/// Thrown by `HotelynApiClient` when the server responds with a non-2xx status
/// or the response body cannot be decoded.
///
/// [statusCode] is `null` when the failure is transport-level (the request
/// never reached the server or the body was unparseable).
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  /// Human-readable description of what went wrong.
  final String message;

  /// The HTTP status code, when the server responded. `null` for transport or
  /// decoding failures.
  final int? statusCode;

  @override
  String toString() => statusCode == null
      ? 'ApiException: $message'
      : 'ApiException($statusCode): $message';
}

/// Thrown by `HotelynApiClient.createReservationHold` when the room is already
/// actively held or booked by someone else — the `409 Conflict` case (BE-402).
///
/// A typed subtype so callers can react specifically ("someone just grabbed
/// this room") without string-matching the message, while a generic
/// `on ApiException` still catches it. [statusCode] is always `409`.
class RoomAlreadyHeldException extends ApiException {
  const RoomAlreadyHeldException([
    super.message = 'This room has just been reserved by someone else.',
  ]) : super(statusCode: 409);

  @override
  String toString() => 'RoomAlreadyHeldException: $message';
}

/// Thrown by the auth methods (`requestEmailOtp`, `verifyEmailOtp`,
/// `signInWithPassword`) when authentication fails.
///
/// [code] is the server's stable error token — the caller maps it to an
/// actionable, localizable message (e.g. `otp_expired` → "That code has
/// expired", `invalid_credentials` → "Wrong email or password"). For a
/// rate-limit code, [retryAfterSeconds] carries the remaining cooldown when the
/// server provided it.
class AuthApiException extends ApiException {
  const AuthApiException(
    this.code, {
    this.retryAfterSeconds,
    super.statusCode,
  }) : super('Authentication failed: $code');

  /// Stable machine-readable error token (snake_case).
  final String code;

  /// Seconds to wait before retrying, for a rate-limit [code]; else `null`.
  final int? retryAfterSeconds;

  @override
  String toString() => 'AuthApiException($code)';
}
