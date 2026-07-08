import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/health.dart' as route;

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

  test('returns 200 ok for GET', () async {
    when(() => request.method).thenReturn(HttpMethod.get);

    final response = route.onRequest(context);

    expect(response.statusCode, HttpStatus.ok);
    final body = jsonDecode(await response.body()) as Map<String, dynamic>;
    expect(body['status'], 'ok');
  });

  test('rejects non-GET with 405', () {
    when(() => request.method).thenReturn(HttpMethod.post);

    final response = route.onRequest(context);

    expect(response.statusCode, HttpStatus.methodNotAllowed);
  });
}
