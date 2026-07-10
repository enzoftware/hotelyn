import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/auth/otp/request.dart' as request_route;
import '../../../routes/auth/otp/verify.dart' as verify_route;
import '../../helpers/fake_auth_client.dart';

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

void main() {
  late _MockRequestContext context;
  late _MockRequest request;
  late FakeAuthClient client;

  setUp(() {
    context = _MockRequestContext();
    request = _MockRequest();
    client = FakeAuthClient();
    when(() => context.request).thenReturn(request);
    when(() => context.read<AuthClient>()).thenReturn(client);
  });

  void stubBody(String body) {
    when(() => request.method).thenReturn(HttpMethod.post);
    when(request.body).thenAnswer((_) async => body);
  }

  group('POST /auth/otp/request', () {
    test('rejects non-POST with 405', () async {
      when(() => request.method).thenReturn(HttpMethod.get);
      final response = await request_route.onRequest(context);
      expect(response.statusCode, HttpStatus.methodNotAllowed);
    });

    test('400 when email is missing', () async {
      stubBody(jsonEncode(<String, dynamic>{}));
      final response = await request_route.onRequest(context);
      expect(response.statusCode, HttpStatus.badRequest);
    });

    test('400 on non-JSON body', () async {
      stubBody('not json');
      final response = await request_route.onRequest(context);
      expect(response.statusCode, HttpStatus.badRequest);
    });

    test('202 and forwards the trimmed email', () async {
      stubBody(jsonEncode({'email': '  guest@hotelyn.test  '}));

      final response = await request_route.onRequest(context);

      expect(response.statusCode, HttpStatus.accepted);
      expect(client.lastEmail, 'guest@hotelyn.test');
    });

    test('429 with retry_after_seconds on a rate-limit failure', () async {
      stubBody(jsonEncode({'email': 'guest@hotelyn.test'}));
      client.throwFailure = const AuthFailure(
        'over_email_send_rate_limit',
        retryAfterSeconds: 42,
      );

      final response = await request_route.onRequest(context);

      expect(response.statusCode, HttpStatus.tooManyRequests);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;
      expect(body['error'], 'over_email_send_rate_limit');
      expect(body['retry_after_seconds'], 42);
    });
  });

  group('POST /auth/otp/verify', () {
    test('rejects non-POST with 405', () async {
      when(() => request.method).thenReturn(HttpMethod.get);
      final response = await verify_route.onRequest(context);
      expect(response.statusCode, HttpStatus.methodNotAllowed);
    });

    test('400 when token is missing', () async {
      stubBody(jsonEncode({'email': 'guest@hotelyn.test'}));
      final response = await verify_route.onRequest(context);
      expect(response.statusCode, HttpStatus.badRequest);
    });

    test('200 with the session on a valid code', () async {
      stubBody(jsonEncode({'email': 'guest@hotelyn.test', 'token': '123456'}));

      final response = await verify_route.onRequest(context);

      expect(response.statusCode, HttpStatus.ok);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;
      expect(body['access_token'], 'access-123');
      expect(body['refresh_token'], 'refresh-456');
      expect(body['user_id'], 'user-1');
      expect(client.lastToken, '123456');
    });

    test('401 with a distinct error code on an expired code', () async {
      stubBody(jsonEncode({'email': 'guest@hotelyn.test', 'token': '000000'}));
      client.throwFailure = const AuthFailure('otp_expired');

      final response = await verify_route.onRequest(context);

      expect(response.statusCode, HttpStatus.unauthorized);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;
      expect(body['error'], 'otp_expired');
    });
  });
}
