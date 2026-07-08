import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// Liveness probe. Returns `200 OK` for any GET, `405` otherwise.
Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
  return Response.json(body: {'status': 'ok'});
}
