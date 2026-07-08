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
