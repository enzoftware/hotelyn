import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// A `400 Bad Request` carrying a client-facing [message], raised while parsing
/// request input.
///
/// Route handlers catch this and convert it to a JSON error response via
/// [badRequest]; keeping it a typed exception lets the parsing helpers below
/// stay expression-bodied.
class BadRequestException implements Exception {
  const BadRequestException(this.message);

  final String message;
}

/// Reads a required `double` query parameter [name], or throws
/// [BadRequestException] when it is missing or not a number.
double requiredDouble(RequestContext context, String name) {
  final raw = context.request.uri.queryParameters[name];
  if (raw == null) {
    throw BadRequestException('Missing required query parameter "$name".');
  }
  final value = double.tryParse(raw);
  if (value == null) {
    throw BadRequestException('Query parameter "$name" must be a number.');
  }
  if (value.isNaN || value.isInfinite) {
    throw BadRequestException(
      'Query parameter "$name" must be a finite number.',
    );
  }
  return value;
}

/// A JSON `400` response with a single error [message].
Response badRequest(String message) => Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'errors': [
          {'message': message},
        ],
      },
    );

/// A JSON `500` response that never leaks internal detail to the client.
Response internalError() => Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'errors': [
          {'message': 'Unexpected error while handling the request.'},
        ],
      },
    );
