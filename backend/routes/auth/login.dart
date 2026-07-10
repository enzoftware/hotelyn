import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// `POST /auth/login`  body: `{ "email": "...", "password": "..." }`
///
/// Hotel-staff email/password sign-in (BE-602). Staff accounts are provisioned
/// invite-only (Admin API / dashboard) — there is deliberately no signup route
/// here. Returns the session on success; wrong credentials yield `401`.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final parsed = await parseJsonBody(
    context,
    requiredStringFields: ['email'],
    // A password is kept verbatim — leading/trailing spaces can be significant.
    rawStringFields: ['password'],
  );
  if (parsed is Response) return parsed;
  final fields = parsed as Map<String, String>;

  return authAction('POST /auth/login', () async {
    final session = await context.read<AuthClient>().signInWithPassword(
          email: fields['email']!,
          password: fields['password']!,
        );
    return Response.json(body: session.toJson());
  });
}
