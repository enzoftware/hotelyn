import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// `POST /auth/otp/verify`  body: `{ "email": "...", "token": "123456" }`
///
/// Exchanges a valid email OTP for a session (BE-601). On success returns the
/// session tokens the app persists; an expired or wrong code yields `401` with
/// a distinct `error` code so the UI can show an actionable message.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final parsed = await parseJsonBody(
    context,
    requiredStringFields: ['email', 'token'],
  );
  if (parsed is Response) return parsed;
  final fields = parsed as Map<String, String>;

  return authAction('POST /auth/otp/verify', () async {
    final session = await context.read<AuthClient>().verifyEmailOtp(
          email: fields['email']!,
          token: fields['token']!,
        );
    // Token-bearing response: keep it out of any shared/browser cache.
    return Response.json(
      body: session.toJson(),
      headers: const {
        HttpHeaders.cacheControlHeader: 'no-store',
        HttpHeaders.pragmaHeader: 'no-cache',
      },
    );
  });
}
