import 'dart:convert';

import 'package:hotelyn_api_client/src/api_exception.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:http/http.dart' as http;

/// Supplies the current bearer token (Supabase JWT) for authenticated requests,
/// or `null` when the user is signed out.
typedef TokenProvider = Future<String?> Function();

/// Typed REST client for the Hotelyn Dart Frog API.
///
/// It is the single seam through which the Flutter apps reach the backend: it
/// builds request URLs, attaches the JWT (via the token provider) to the
/// `Authorization` header, and decodes JSON responses into `hotelyn_domain`
/// entities. Non-2xx responses surface as an [ApiException].
class HotelynApiClient {
  /// Creates a client rooted at [baseUrl] (e.g. `http://127.0.0.1:8080`).
  ///
  /// [httpClient] can be injected in tests (e.g. `http`'s `MockClient`).
  /// [tokenProvider] is called before each request to obtain the bearer token;
  /// when it returns `null` no `Authorization` header is sent.
  HotelynApiClient({
    required String baseUrl,
    http.Client? httpClient,
    TokenProvider? tokenProvider,
  })  : _baseUrl = Uri.parse(baseUrl),
        _httpClient = httpClient ?? http.Client(),
        _tokenProvider = tokenProvider;

  final Uri _baseUrl;
  final http.Client _httpClient;
  final TokenProvider? _tokenProvider;

  /// Hotels within [radiusKm] of ([lat], [lng]), nearest-first.
  Future<List<Hotel>> getNearbyHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  }) =>
      _getHotels('/hotels/nearby', lat: lat, lng: lng, radiusKm: radiusKm);

  /// Popular-yet-nearby hotels within [radiusKm] of ([lat], [lng]).
  Future<List<Hotel>> getRecommendedHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  }) =>
      _getHotels('/hotels/recommended', lat: lat, lng: lng, radiusKm: radiusKm);

  /// Rooms for [hotelId], each with a computed `available_now` flag.
  Future<List<Room>> getRooms({required String hotelId}) async {
    final json =
        await _getJsonList('/hotels/${Uri.encodeComponent(hotelId)}/rooms');
    return json
        .map((row) => Room.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Places a short-lived hold on [roomId] for the current guest, returning the
  /// created [Reservation] (status `held`, with a confirmation code).
  ///
  /// Throws [RoomAlreadyHeldException] when the room was already taken (the
  /// server's `409`), and a plain [ApiException] for any other failure.
  Future<Reservation> createReservationHold({
    required String hotelId,
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    final json = await _sendJson(
      'POST',
      '/hotels/${Uri.encodeComponent(hotelId)}/holds',
      body: {
        'room_id': roomId,
        // Dates only — the API contract is a check-in/check-out day pair.
        'check_in': _asDate(checkIn),
        'check_out': _asDate(checkOut),
      },
      // A 409 means the room was grabbed first: surface the typed variant.
      on409: (String? message) => message == null
          ? const RoomAlreadyHeldException()
          : RoomAlreadyHeldException(message),
    );
    return Reservation.fromJson(json);
  }

  /// The acting staff member's own hotel rooms, each with a derived
  /// [RoomStatus] (BE-501). Scope comes from the caller's token, not a param.
  Future<List<StaffRoom>> getStaffRooms() async {
    final json = await _getJsonList('/staff/rooms');
    return json
        .map((row) => StaffRoom.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Sets [roomId]'s availability (BE-502), returning the updated [StaffRoom]
  /// with its freshly derived status.
  ///
  /// Throws an [ApiException] with `statusCode` 409 when the room has an active
  /// reservation and cannot be made available.
  Future<StaffRoom> setRoomAvailability({
    required String roomId,
    required bool isAvailable,
  }) async {
    final json = await _sendJson(
      'PATCH',
      '/staff/rooms/${Uri.encodeComponent(roomId)}/availability',
      body: {'is_available': isAvailable},
    );
    return StaffRoom.fromJson(json);
  }

  /// Confirms a held reservation as owning-hotel staff (BE-503), returning the
  /// now-`confirmed` [Reservation].
  ///
  /// Throws an [ApiException] with `statusCode` 409 when the hold has expired.
  Future<Reservation> confirmReservation({
    required String reservationId,
  }) async {
    final json = await _sendJson(
      'POST',
      '/reservations/${Uri.encodeComponent(reservationId)}/confirm',
    );
    return Reservation.fromJson(json);
  }

  /// Rejects a reservation as owning-hotel staff (BE-503), freeing the room
  /// immediately. Returns the now-`rejected` [Reservation].
  Future<Reservation> rejectReservation({required String reservationId}) async {
    final json = await _sendJson(
      'POST',
      '/reservations/${Uri.encodeComponent(reservationId)}/reject',
    );
    return Reservation.fromJson(json);
  }

  /// Requests an email OTP for [email] (guest sign-in, BE-601). Completes when
  /// the code is on its way. Throws [AuthApiException] with `over_*_rate_limit`
  /// (and `retryAfterSeconds` when known) if the cooldown is in effect.
  Future<void> requestEmailOtp({required String email}) async {
    await _sendJson(
      'POST',
      '/auth/otp/request',
      body: {'email': email},
      expectBody: false,
      onError: _asAuthException,
    );
  }

  /// Verifies the email OTP [token] for [email] and returns the [AuthSession]
  /// (BE-601). Throws [AuthApiException] `otp_expired` for a wrong/expired code.
  Future<AuthSession> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final json = await _sendJson(
      'POST',
      '/auth/otp/verify',
      body: {'email': email, 'token': token},
      onError: _asAuthException,
    );
    return AuthSession.fromJson(json);
  }

  /// Signs a staff member in with [email] + [password] (BE-602), returning the
  /// [AuthSession]. Throws [AuthApiException] `invalid_credentials` if wrong.
  Future<AuthSession> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final json = await _sendJson(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
      onError: _asAuthException,
    );
    return AuthSession.fromJson(json);
  }

  /// Turns a non-2xx auth response into a typed [AuthApiException], reading the
  /// server's `error` code and optional `retry_after_seconds`.
  Exception _asAuthException(int statusCode, Map<String, dynamic>? body) {
    final code = body?['error'] as String? ?? 'auth_error';
    final retryAfter = body?['retry_after_seconds'] as int?;
    return AuthApiException(
      code,
      retryAfterSeconds: retryAfter,
      statusCode: statusCode,
    );
  }

  /// Shared plumbing for the two radius searches, which share params and shape.
  Future<List<Hotel>> _getHotels(
    String path, {
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    final json = await _getJsonList(
      path,
      query: {
        'lat': '$lat',
        'lng': '$lng',
        'radiusKm': '$radiusKm',
      },
    );
    return json
        .map((row) => Hotel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Issues an authenticated GET and decodes a top-level JSON array, or throws
  /// an [ApiException] on a non-2xx status or an unexpected body shape.
  Future<List<dynamic>> _getJsonList(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = _baseUrl.replace(
      path: path,
      queryParameters: query,
    );

    const timeout = Duration(seconds: 15);

    final http.Response response;
    try {
      response = await _httpClient
          .get(uri, headers: await _headers())
          .timeout(timeout);
    } on Object catch (error) {
      throw ApiException('Request to $path failed: $error');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _extractError(response.body) ?? 'Request to $path failed.',
        statusCode: response.statusCode,
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw ApiException('Response from $path was not valid JSON.');
    }
    if (decoded is! List) {
      throw ApiException('Expected a JSON array from $path.');
    }
    return decoded;
  }

  /// Issues an authenticated request with an optional JSON [body] via [method]
  /// (`POST`/`PATCH`) and decodes a top-level JSON object. A non-2xx status or
  /// an unexpected body shape becomes an [ApiException] (carrying the status).
  ///
  /// [on409] lets a caller substitute a typed exception for a `409 Conflict`,
  /// receiving the server-provided message (or `null` when it sent none).
  /// [onError] lets a caller map ANY non-2xx to a typed exception, receiving
  /// the status and the decoded JSON body (`null` when it was not an object).
  /// [expectBody] `false` skips decoding for empty success responses (e.g.
  /// `202 Accepted`), returning an empty map.
  Future<Map<String, dynamic>> _sendJson(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Exception Function(String? message)? on409,
    Exception Function(int statusCode, Map<String, dynamic>? body)? onError,
    bool expectBody = true,
  }) async {
    final uri = _baseUrl.replace(path: path);
    final request = http.Request(method, uri)
      ..headers.addAll(await _headers(json: body != null));
    if (body != null) request.body = jsonEncode(body);

    const timeout = Duration(seconds: 15);

    final http.Response response;
    try {
      // Bound the whole exchange, not just header receipt: chaining the body
      // read inside the timeout means a stalled body stream can't hang forever.
      response = await _httpClient
          .send(request)
          .then(http.Response.fromStream)
          .timeout(timeout);
    } on Object catch (error) {
      throw ApiException('Request to $path failed: $error');
    }

    if (response.statusCode == 409 && on409 != null) {
      throw on409(_extractError(response.body));
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (onError != null) {
        throw onError(response.statusCode, _decodeObjectOrNull(response.body));
      }
      throw ApiException(
        _extractError(response.body) ?? 'Request to $path failed.',
        statusCode: response.statusCode,
      );
    }

    if (!expectBody) return const {};

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw ApiException('Response from $path was not valid JSON.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw ApiException('Expected a JSON object from $path.');
    }
    return decoded;
  }

  /// Decodes a JSON object body, or `null` when it is absent or not an object.
  Map<String, dynamic>? _decodeObjectOrNull(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  /// Formats a [DateTime] as a bare `YYYY-MM-DD` date (the API date contract).
  String _asDate(DateTime date) {
    final utc = date.toUtc();
    final y = utc.year.toString().padLeft(4, '0');
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<Map<String, String>> _headers({bool json = false}) async {
    final token = await _tokenProvider?.call();
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Pulls a server-provided error message out of an
  /// `{ "errors": [{ "message" }] }` or `{ "error": "..." }` body, returning
  /// `null` when neither is present.
  String? _extractError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final errors = decoded['errors'];
        if (errors is List && errors.isNotEmpty) {
          final first = errors.first;
          if (first is Map && first['message'] is String) {
            return first['message'] as String;
          }
        }
        if (decoded['error'] is String) return decoded['error'] as String;
      }
    } on FormatException {
      // Non-JSON error body — fall through to the generic message.
    }
    return null;
  }

  /// Releases the underlying HTTP client. Call when the client is disposed.
  void close() => _httpClient.close();
}
