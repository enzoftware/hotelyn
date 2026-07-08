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
    final json = await _postJson(
      '/hotels/${Uri.encodeComponent(hotelId)}/holds',
      body: {
        'room_id': roomId,
        // Dates only — the API contract is a check-in/check-out day pair.
        'check_in': _asDate(checkIn),
        'check_out': _asDate(checkOut),
      },
    );
    return Reservation.fromJson(json);
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

  /// Issues an authenticated POST with a JSON [body] and decodes a top-level
  /// JSON object. Maps `409` to [RoomAlreadyHeldException]; any other non-2xx
  /// status or an unexpected body shape becomes an [ApiException].
  Future<Map<String, dynamic>> _postJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final uri = _baseUrl.replace(path: path);

    const timeout = Duration(seconds: 15);

    final http.Response response;
    try {
      response = await _httpClient
          .post(
            uri,
            headers: await _headers(json: true),
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } on Object catch (error) {
      throw ApiException('Request to $path failed: $error');
    }

    if (response.statusCode == 409) {
      // Fall back to RoomAlreadyHeldException's own default message when the
      // server sent no error detail, so the two don't drift.
      final message = _extractError(response.body);
      throw message == null
          ? const RoomAlreadyHeldException()
          : RoomAlreadyHeldException(message);
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
    if (decoded is! Map<String, dynamic>) {
      throw ApiException('Expected a JSON object from $path.');
    }
    return decoded;
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
