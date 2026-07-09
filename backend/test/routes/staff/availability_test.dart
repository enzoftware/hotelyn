import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/staff/rooms/[id]/availability.dart' as route;
import '../../helpers/fake_hotel_data_client.dart';

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

void main() {
  late _MockRequestContext context;
  late _MockRequest request;
  late FakeHotelDataClient client;

  const jwt = 'x.eyJzdWIiOiJzdGFmZi0xIn0.y'; // {"sub":"staff-1"}

  setUp(() {
    context = _MockRequestContext();
    request = _MockRequest();
    client = FakeHotelDataClient();
    when(() => context.request).thenReturn(request);
    when(() => context.read<HotelDataClient>()).thenReturn(client);
    when(() => request.headers).thenReturn({
      HttpHeaders.authorizationHeader: 'Bearer $jwt',
    });
  });

  void stubBody(String body) {
    when(() => request.method).thenReturn(HttpMethod.patch);
    when(request.body).thenAnswer((_) async => body);
  }

  test('rejects non-PATCH with 405', () async {
    when(() => request.method).thenReturn(HttpMethod.get);
    final response = await route.onRequest(context, 'r1');
    expect(response.statusCode, HttpStatus.methodNotAllowed);
  });

  test('401 when unauthenticated', () async {
    when(() => request.headers).thenReturn(<String, String>{});
    stubBody(jsonEncode({'is_available': false}));
    final response = await route.onRequest(context, 'r1');
    expect(response.statusCode, HttpStatus.unauthorized);
  });

  test('400 when is_available is not a bool', () async {
    stubBody(jsonEncode({'is_available': 'nope'}));
    final response = await route.onRequest(context, 'r1');
    expect(response.statusCode, HttpStatus.badRequest);
  });

  test('400 when is_available is missing', () async {
    stubBody(jsonEncode(<String, dynamic>{}));
    final response = await route.onRequest(context, 'r1');
    expect(response.statusCode, HttpStatus.badRequest);
  });

  test('toggles and returns the updated room with its status', () async {
    stubBody(jsonEncode({'is_available': false}));

    final response = await route.onRequest(context, 'r1');

    expect(response.statusCode, HttpStatus.ok);
    final body = jsonDecode(await response.body()) as Map<String, dynamic>;
    expect(body['is_available'], false);
    expect(body['status'], 'unavailable');
    expect(client.lastRoomId, 'r1');
    expect(client.lastIsAvailable, false);
    expect(client.lastActorId, 'staff-1');
  });

  test('maps room_has_active_reservation to 409', () async {
    stubBody(jsonEncode({'is_available': true}));
    client.throwRpc = const RpcException('room_has_active_reservation');

    final response = await route.onRequest(context, 'r1');

    expect(response.statusCode, HttpStatus.conflict);
  });

  test('maps room_not_found to 404', () async {
    stubBody(jsonEncode({'is_available': true}));
    client.throwRpc = const RpcException('room_not_found');

    final response = await route.onRequest(context, 'r1');

    expect(response.statusCode, HttpStatus.notFound);
  });

  test('500 on an unexpected data-layer failure', () async {
    stubBody(jsonEncode({'is_available': false}));
    client.throwGeneric = Exception('supabase down');

    final response = await route.onRequest(context, 'r1');

    expect(response.statusCode, HttpStatus.internalServerError);
  });
}
