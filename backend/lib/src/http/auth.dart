import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/src/data/auth_client.dart';
import 'package:hotelyn_server/src/data/hotel_data_client.dart';
import 'package:hotelyn_server/src/http/query_params.dart';

/// Raised when a request lacks a usable `Authorization: Bearer <jwt>` and the
/// acting user cannot be determined. Route handlers map it to a `401`.
class UnauthorizedException implements Exception {
  const UnauthorizedException([
    this.message = 'Authentication is required for this request.',
  ]);

  final String message;
}

/// Runs a staff-authenticated action: resolves the acting user via
/// [actorIdOrNull], invokes [action] with it, and maps the common failures to
/// responses — a missing/invalid token → `401`, [RpcException] → its business
/// status (via [rpcErrorResponse]), anything else → `500`.
///
/// Centralizes the auth + error-mapping boilerplate the staff routes share, so
/// each handler is just its method guard plus the [action] body. The handler
/// stays directly callable in tests (no middleware indirection).
Future<Response> staffAction(
  RequestContext context,
  Future<Response> Function(String actorId) action,
) async {
  final actorId = actorIdOrNull(context);
  if (actorId == null) {
    return unauthorized('Authentication is required for this request.');
  }

  try {
    return await action(actorId);
  } on RpcException catch (error) {
    return rpcErrorResponse(error);
  } on Object catch (error, stackTrace) {
    // Surface unexpected failures to the server log (stderr) so they reach
    // monitoring, while the client only ever sees a generic 500.
    stderr.writeln('Unexpected error in staffAction: $error\n$stackTrace');
    return internalError();
  }
}

/// Runs an auth-route [action] (identified by [label] for logs) and maps the
/// common failures — [AuthFailure] → its auth status (via
/// [authFailureResponse]), anything else → `500` (logged to stderr so 5xx are
/// diagnosable). Centralizes the try/catch the three auth routes share.
Future<Response> authAction(
  String label,
  Future<Response> Function() action,
) async {
  try {
    return await action();
  } on AuthFailure catch (failure) {
    return authFailureResponse(failure);
  } on Object catch (error, stackTrace) {
    stderr.writeln('Unexpected error in $label: $error\n$stackTrace');
    return internalError();
  }
}

/// Parses the request JSON body and pulls out [requiredStringFields] as
/// trimmed, non-empty strings. Returns the values keyed by field name on
/// success, or a `400` [Response] describing what was wrong — the single place
/// the auth routes validate their bodies.
Future<Object> parseJsonBody(
  RequestContext context, {
  required List<String> requiredStringFields,
  List<String> rawStringFields = const [],
}) async {
  final dynamic decoded;
  try {
    decoded = jsonDecode(await context.request.body());
  } on FormatException {
    return badRequest('Request body was not valid JSON.');
  }
  if (decoded is! Map<String, dynamic>) {
    return badRequest('Body must be a JSON object.');
  }

  final values = <String, String>{};
  for (final field in requiredStringFields) {
    final value = decoded[field];
    if (value is! String) {
      return badRequest('"$field" is required and must be a string.');
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return badRequest('"$field" must not be empty.');
    }
    values[field] = trimmed;
  }
  // Fields kept verbatim (e.g. a password, which may legitimately have spaces),
  // still required and non-empty but not trimmed.
  for (final field in rawStringFields) {
    final value = decoded[field];
    if (value is! String || value.isEmpty) {
      return badRequest('"$field" is required and must not be empty.');
    }
    values[field] = value;
  }
  return values;
}

/// Extracts the acting user's id (the JWT `sub` claim) from the request's
/// `Authorization: Bearer <jwt>` header, or throws [UnauthorizedException].
///
/// SECURITY — TRUST BOUNDARY. This decodes the JWT payload but does NOT verify
/// its signature, so on its own it is forgeable (anyone could send a token with
/// an arbitrary `sub`). It is safe here ONLY because this server is not the
/// authentication boundary:
///
///   * This server must sit behind an ingress that verifies the Supabase JWT
///     before forwarding; it must never be directly reachable by clients.
///   * The ownership RPCs it calls are granted to `service_role` only (see the
///     hotel_inventory migration), so even a forged `sub` cannot reach them
///     except through this trusted server.
///
/// Verifying the signature against the Supabase JWT secret here (defence in
/// depth, so a misconfigured ingress can't become a full auth bypass) is a
/// tracked follow-up. See the README "Auth note".
String requireActorId(RequestContext context) {
  final actorId = actorIdOrNull(context);
  if (actorId == null) {
    throw const UnauthorizedException();
  }
  return actorId;
}

/// Like [requireActorId], but returns `null` instead of throwing when the
/// request carries no usable `Bearer` token — for callers that guard with an
/// `if` rather than a `try`/`catch`.
String? actorIdOrNull(RequestContext context) {
  final header = context.request.headers[HttpHeaders.authorizationHeader];
  if (header == null || !header.startsWith('Bearer ')) {
    return null;
  }
  final token = header.substring('Bearer '.length).trim();
  final sub = _subFromJwt(token);
  if (sub == null || sub.isEmpty) {
    return null;
  }
  return sub;
}

/// Pulls the `sub` claim out of a JWT payload, or `null` if it cannot be read.
String? _subFromJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final normalized = base64Url.normalize(parts[1]);
    final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
    if (payload is Map<String, dynamic> && payload['sub'] is String) {
      return payload['sub'] as String;
    }
  } on Object {
    return null;
  }
  return null;
}

/// A JSON `401` response with a single error [message].
Response unauthorized(String message) =>
    errorResponse(HttpStatus.unauthorized, message);

/// A JSON `403` response with a single error [message].
Response forbidden(String message) =>
    errorResponse(HttpStatus.forbidden, message);

/// A JSON `404` response with a single error [message].
Response notFound(String message) =>
    errorResponse(HttpStatus.notFound, message);

/// A JSON `409` response with a single error [message].
Response conflict(String message) =>
    errorResponse(HttpStatus.conflict, message);

/// Maps a business-rule [RpcException] (raised by a SQL function) to the right
/// HTTP response. The code is a stable token the RPC raised.
///
/// Only recognized business-rule tokens map to a 4xx; an unrecognized code is a
/// genuinely unexpected DB failure (not a deliberate rule violation), so it
/// surfaces as `500` rather than a misleading `409` — that way real bugs reach
/// error monitoring instead of being reported to clients as benign conflicts.
Response rpcErrorResponse(RpcException error) {
  switch (error.code) {
    case 'not_authorized':
      return forbidden('You are not allowed to perform this action.');
    case 'room_not_found':
    case 'reservation_not_found':
      return notFound('The requested resource was not found.');
    case 'room_has_active_reservation':
      return conflict(
        'This room has an active reservation and cannot be made available.',
      );
    case 'hold_expired':
      return conflict('This hold has expired and can no longer be confirmed.');
    case 'reservation_not_held':
      return conflict('This reservation is not awaiting confirmation.');
    case 'reservation_not_active':
      return conflict('This reservation is not active.');
    case 'reservation_not_payable':
      return conflict(
        'This reservation cannot be marked paid; it is not a live hold.',
      );
    default:
      return internalError();
  }
}

/// Maps an [AuthFailure] (from the auth client) to an HTTP response with a
/// stable `error` code the client turns into an actionable message.
///
///   * rate limit → `429` with `retry_after_seconds` so the UI can show the
///     remaining cooldown (BE-601);
///   * bad/expired code or wrong password → `401`;
///   * anything unrecognized → `401` (a failed auth attempt, not a server bug).
Response authFailureResponse(AuthFailure failure) {
  // Prefer the upstream status when GoTrue provided it; fall back to the code
  // for older responses that omit a status.
  final isRateLimit = failure.statusCode == HttpStatus.tooManyRequests ||
      failure.code.contains('rate_limit');

  if (isRateLimit) {
    return Response.json(
      statusCode: HttpStatus.tooManyRequests,
      body: {
        'error': failure.code,
        if (failure.retryAfterSeconds != null)
          'retry_after_seconds': failure.retryAfterSeconds,
        'errors': [
          {'message': 'Too many attempts. Please wait before trying again.'},
        ],
      },
    );
  }

  // An upstream 5xx is a GoTrue/server fault, not a rejected credential — pass
  // the status through rather than masking it as a 401 auth failure.
  final statusCode = failure.statusCode;
  if (statusCode != null && statusCode >= HttpStatus.internalServerError) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'error': failure.code,
        'errors': [
          {'message': 'The authentication service is temporarily unavailable.'},
        ],
      },
    );
  }

  return Response.json(
    statusCode: HttpStatus.unauthorized,
    body: {
      'error': failure.code,
      'errors': [
        {'message': 'Authentication failed. Check your code or credentials.'},
      ],
    },
  );
}
