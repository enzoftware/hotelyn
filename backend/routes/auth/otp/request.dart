import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// `POST /auth/otp/request`  body: `{ "email": "..." }`
///
/// Requests an email OTP for a guest (BE-601). A brand-new address is created
/// on verify, so there is no separate signup. Responds `202 Accepted` (the code
/// is on its way; we never reveal whether the address already existed), or
/// `429` with `retry_after_seconds` when the Supabase Auth cooldown applies.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final parsed = await parseJsonBody(context, requiredStringFields: ['email']);
  if (parsed is Response) return parsed;
  final fields = parsed as Map<String, String>;

  return authAction('POST /auth/otp/request', () async {
    await context.read<AuthClient>().requestEmailOtp(fields['email']!);
    return Response(statusCode: HttpStatus.accepted);
  });
}
