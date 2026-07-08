import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/graphql.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

class _FakeHotelDataClient implements HotelDataClient {
  @override
  Future<List<Hotel>> nearbyHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async =>
      const [
        Hotel(id: 'h1', name: 'Miraflores', city: 'Lima', country: 'Peru'),
      ];

  @override
  Future<List<Hotel>> recommendedHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async =>
      const [];

  @override
  Future<List<Room>> roomsAvailability({String? hotelId}) async => const [];
}

void main() {
  late _MockRequestContext context;
  late _MockRequest request;

  setUp(() {
    context = _MockRequestContext();
    request = _MockRequest();
    when(() => context.request).thenReturn(request);
    when(() => context.read<HotelDataClient>())
        .thenReturn(_FakeHotelDataClient());
  });

  test('rejects non-POST methods with 405', () async {
    when(() => request.method).thenReturn(HttpMethod.get);

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.methodNotAllowed);
  });

  test('rejects a body without a query field with 400', () async {
    when(() => request.method).thenReturn(HttpMethod.post);
    when(request.json).thenAnswer((_) async => <String, dynamic>{});

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.badRequest);
  });

  test('executes a valid query and returns data', () async {
    when(() => request.method).thenReturn(HttpMethod.post);
    when(request.json).thenAnswer(
      (_) async => {
        'query': '{ nearbyHotels(lat: -12.11, lng: -77.03, radiusKm: 200.0) '
            '{ id name } }',
      },
    );

    final response = await route.onRequest(context);
    expect(response.statusCode, HttpStatus.ok);

    final body = jsonDecode(await response.body()) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    final rows = data['nearbyHotels'] as List<dynamic>;
    expect(rows.first, {'id': 'h1', 'name': 'Miraflores'});
  });

  test('returns 400 when the JSON body is malformed', () async {
    when(() => request.method).thenReturn(HttpMethod.post);
    when(request.json).thenThrow(const FormatException('bad json'));

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.badRequest);
    final body = jsonDecode(await response.body()) as Map<String, dynamic>;
    expect(body['errors'], isNotEmpty);
  });

  test('returns 400 when variables is not an object', () async {
    when(() => request.method).thenReturn(HttpMethod.post);
    when(request.json).thenAnswer(
      (_) async => {'query': '{ nearbyHotels { id } }', 'variables': 'nope'},
    );

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.badRequest);
  });

  test('returns 400 with errors for a malformed query', () async {
    when(() => request.method).thenReturn(HttpMethod.post);
    when(request.json).thenAnswer(
      // Unterminated selection set — a parse error surfaced as a GraphQL error.
      (_) async => {'query': '{ nearbyHotels(lat: 1.0'},
    );

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.badRequest);
    final body = jsonDecode(await response.body()) as Map<String, dynamic>;
    expect(body['errors'], isNotEmpty);
  });
}
