import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/hotels/nearby.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

class _FakeHotelDataClient implements HotelDataClient {
  double? lastLat;
  double? lastLng;
  double? lastRadiusKm;
  bool throwOnCall = false;

  @override
  Future<List<Hotel>> nearbyHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    if (throwOnCall) throw Exception('supabase down');
    lastLat = lat;
    lastLng = lng;
    lastRadiusKm = radiusKm;
    return const [
      Hotel(id: 'h1', name: 'Miraflores', city: 'Lima', country: 'Peru'),
    ];
  }

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
  late _FakeHotelDataClient client;

  setUp(() {
    context = _MockRequestContext();
    request = _MockRequest();
    client = _FakeHotelDataClient();
    when(() => context.request).thenReturn(request);
    when(() => context.read<HotelDataClient>()).thenReturn(client);
  });

  void stubUri(Map<String, String> query) {
    when(() => request.method).thenReturn(HttpMethod.get);
    when(() => request.uri).thenReturn(
      Uri.parse('/hotels/nearby').replace(queryParameters: query),
    );
  }

  test('rejects non-GET with 405', () async {
    when(() => request.method).thenReturn(HttpMethod.post);
    final response = await route.onRequest(context);
    expect(response.statusCode, HttpStatus.methodNotAllowed);
  });

  test('returns hotels and forwards the radius args', () async {
    stubUri({'lat': '-12.11', 'lng': '-77.03', 'radiusKm': '200'});

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.ok);
    final body = jsonDecode(await response.body()) as List<dynamic>;
    expect((body.first as Map)['id'], 'h1');
    expect(client.lastLat, -12.11);
    expect(client.lastRadiusKm, 200.0);
  });

  test('returns 400 when a required param is missing', () async {
    stubUri({'lat': '-12.11', 'lng': '-77.03'});

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.badRequest);
    final body = jsonDecode(await response.body()) as Map<String, dynamic>;
    expect(body['errors'], isNotEmpty);
  });

  test('returns 400 when a param is not a number', () async {
    stubUri({'lat': 'nope', 'lng': '-77.03', 'radiusKm': '200'});

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.badRequest);
  });

  test('returns 500 when the data client throws', () async {
    client.throwOnCall = true;
    stubUri({'lat': '-12.11', 'lng': '-77.03', 'radiusKm': '200'});

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.internalServerError);
  });
}
