import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/hotels/[id]/rooms.dart' as route;
import '../../helpers/unused_staff_methods.dart';

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

class _FakeHotelDataClient extends UnusedStaffMethodsBase {
  String? lastHotelId;
  bool throwOnCall = false;

  @override
  Future<List<Hotel>> nearbyHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async =>
      const [];

  @override
  Future<List<Hotel>> recommendedHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async =>
      const [];

  @override
  Future<List<Room>> roomsAvailability({String? hotelId}) async {
    if (throwOnCall) throw Exception('supabase down');
    lastHotelId = hotelId;
    return const [
      Room(
        id: 'r1',
        hotelId: 'h1',
        name: '101',
        roomType: 'double',
        capacity: 2,
        pricePerNight: 180,
        isAvailable: true,
        availableNow: false,
      ),
    ];
  }
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

  test('rejects non-GET with 405', () async {
    when(() => request.method).thenReturn(HttpMethod.post);
    final response = await route.onRequest(context, 'h1');
    expect(response.statusCode, HttpStatus.methodNotAllowed);
  });

  test('returns rooms scoped to the path hotel id', () async {
    when(() => request.method).thenReturn(HttpMethod.get);

    final response = await route.onRequest(context, 'h1');

    expect(response.statusCode, HttpStatus.ok);
    final body = jsonDecode(await response.body()) as List<dynamic>;
    expect((body.single as Map)['available_now'], false);
    expect(client.lastHotelId, 'h1');
  });

  test('returns 500 when the data client throws', () async {
    client.throwOnCall = true;
    when(() => request.method).thenReturn(HttpMethod.get);

    final response = await route.onRequest(context, 'h1');

    expect(response.statusCode, HttpStatus.internalServerError);
  });
}
