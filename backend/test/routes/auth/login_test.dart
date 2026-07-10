import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/auth/login.dart' as route;
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

  test('rejects non-POST with 405', () async {
    when(() => request.method).thenReturn(HttpMethod.get);
    final response = await route.onRequest(context);
    expect(response.statusCode, HttpStatus.methodNotAllowed);
  });

  test('400 when password is missing', () async {
    stubBody(jsonEncode({'email': 'staff@hotelyn.test'}));
    final response = await route.onRequest(context);
    expect(response.statusCode, HttpStatus.badRequest);
  });

  test('400 on a malformed JSON body', () async {
    stubBody('{not valid json');
    final response = await route.onRequest(context);
    expect(response.statusCode, HttpStatus.badRequest);
  });

  test('400 when email is an empty/whitespace string', () async {
    stubBody(jsonEncode({'email': '   ', 'password': 'password123'}));
    final response = await route.onRequest(context);
    expect(response.statusCode, HttpStatus.badRequest);
  });

  test('400 when password is empty', () async {
    stubBody(jsonEncode({'email': 'staff@hotelyn.test', 'password': ''}));
    final response = await route.onRequest(context);
    expect(response.statusCode, HttpStatus.badRequest);
  });

  test('200 with the session on valid credentials', () async {
    stubBody(
      jsonEncode({'email': 'staff@hotelyn.test', 'password': 'password123'}),
    );

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.ok);
    final body = jsonDecode(await response.body()) as Map<String, dynamic>;
    expect(body['access_token'], 'access-123');
    expect(body['user_id'], 'user-1');
    expect(client.lastEmail, 'staff@hotelyn.test');
    expect(client.lastPassword, 'password123');
  });

  test('401 with error code on invalid credentials', () async {
    stubBody(
      jsonEncode({'email': 'staff@hotelyn.test', 'password': 'wrong'}),
    );
    client.throwFailure = const AuthFailure('invalid_credentials');

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.unauthorized);
    final body = jsonDecode(await response.body()) as Map<String, dynamic>;
    expect(body['error'], 'invalid_credentials');
  });

  test('500 on an unexpected failure', () async {
    stubBody(
      jsonEncode({'email': 'staff@hotelyn.test', 'password': 'password123'}),
    );
    // A non-AuthFailure error (e.g. transport) must not leak as a 401.
    client.throwFailure = null;
    when(() => context.read<AuthClient>()).thenThrow(Exception('boom'));

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.internalServerError);
  });
}
