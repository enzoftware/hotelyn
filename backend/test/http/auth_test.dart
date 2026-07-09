import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

void main() {
  late _MockRequestContext context;
  late _MockRequest request;

  setUp(() {
    context = _MockRequestContext();
    request = _MockRequest();
    when(() => context.request).thenReturn(request);
  });

  void headers(Map<String, String> h) =>
      when(() => request.headers).thenReturn(h);

  final throwsUnauthorized = throwsA(isA<UnauthorizedException>());

  group('requireActorId', () {
    // Middle segment base64url-decodes to {"sub":"user-42"}.
    const jwt = 'aaa.eyJzdWIiOiJ1c2VyLTQyIn0.bbb';

    test('extracts the sub claim from a Bearer token', () {
      headers({HttpHeaders.authorizationHeader: 'Bearer $jwt'});
      expect(requireActorId(context), 'user-42');
    });

    test('throws when there is no Authorization header', () {
      headers({});
      expect(() => requireActorId(context), throwsUnauthorized);
    });

    test('throws when the scheme is not Bearer', () {
      headers({HttpHeaders.authorizationHeader: 'Basic $jwt'});
      expect(() => requireActorId(context), throwsUnauthorized);
    });

    test('throws on a token that is not three segments', () {
      headers({HttpHeaders.authorizationHeader: 'Bearer not.ajwt'});
      expect(() => requireActorId(context), throwsUnauthorized);
    });

    test('throws when the payload has no sub claim', () {
      // {"role":"authenticated"} — no sub.
      const noSub = 'aaa.eyJyb2xlIjoiYXV0aGVudGljYXRlZCJ9.bbb';
      headers({HttpHeaders.authorizationHeader: 'Bearer $noSub'});
      expect(() => requireActorId(context), throwsUnauthorized);
    });
  });
}
