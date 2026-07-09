import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
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
/// [requireActorId], invokes [action] with it, and maps the common failures to
/// responses — [UnauthorizedException] → `401`, [RpcException] → its business
/// status (via [rpcErrorResponse]), anything else → `500`.
///
/// Centralizes the auth + error-mapping boilerplate the staff routes share, so
/// each handler is just its method guard plus the [action] body. The handler
/// stays directly callable in tests (no middleware indirection).
Future<Response> staffAction(
  RequestContext context,
  Future<Response> Function(String actorId) action,
) async {
  final String actorId;
  try {
    actorId = requireActorId(context);
  } on UnauthorizedException catch (error) {
    return unauthorized(error.message);
  }

  try {
    return await action(actorId);
  } on RpcException catch (error) {
    return rpcErrorResponse(error);
  } on Object {
    return internalError();
  }
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
  final header = context.request.headers[HttpHeaders.authorizationHeader];
  if (header == null || !header.startsWith('Bearer ')) {
    throw const UnauthorizedException();
  }
  final token = header.substring('Bearer '.length).trim();
  final sub = _subFromJwt(token);
  if (sub == null || sub.isEmpty) {
    throw const UnauthorizedException('Malformed authentication token.');
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
Response unauthorized(String message) => Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {
        'errors': [
          {'message': message},
        ],
      },
    );

/// A JSON `403` response with a single error [message].
Response forbidden(String message) => Response.json(
      statusCode: HttpStatus.forbidden,
      body: {
        'errors': [
          {'message': message},
        ],
      },
    );

/// A JSON `404` response with a single error [message].
Response notFound(String message) => Response.json(
      statusCode: HttpStatus.notFound,
      body: {
        'errors': [
          {'message': message},
        ],
      },
    );

/// A JSON `409` response with a single error [message].
Response conflict(String message) => Response.json(
      statusCode: HttpStatus.conflict,
      body: {
        'errors': [
          {'message': message},
        ],
      },
    );

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
    default:
      return internalError();
  }
}
