import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/staff/rooms/index.dart' as route;
import '../../helpers/fake_hotel_data_client.dart';

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

void main() {
  late _MockRequestContext context;
  late _MockRequest request;
  late FakeHotelDataClient client;

  // A JWT whose middle segment base64url-decodes to {"sub":"staff-1"}. The
  // backend only decodes the payload, so the header/signature are placeholders.
  const jwt = 'x.eyJzdWIiOiJzdGFmZi0xIn0.y';

  setUp(() {
    context = _MockRequestContext();
    request = _MockRequest();
    client = FakeHotelDataClient();
    when(() => context.request).thenReturn(request);
    when(() => context.read<HotelDataClient>()).thenReturn(client);
  });

  void auth(String? header) {
    when(() => request.headers).thenReturn({
      if (header != null) HttpHeaders.authorizationHeader: header,
    });
  }

  test('rejects non-GET with 405', () async {
    when(() => request.method).thenReturn(HttpMethod.post);
    auth('Bearer $jwt');
    final response = await route.onRequest(context);
    expect(response.statusCode, HttpStatus.methodNotAllowed);
  });

  test('401 when no Authorization header', () async {
    when(() => request.method).thenReturn(HttpMethod.get);
    auth(null);
    final response = await route.onRequest(context);
    expect(response.statusCode, HttpStatus.unauthorized);
  });

  test('returns the staff room list for the JWT actor', () async {
    when(() => request.method).thenReturn(HttpMethod.get);
    auth('Bearer $jwt');

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.ok);
    final body = jsonDecode(await response.body()) as List<dynamic>;
    expect((body.single as Map)['status'], 'available');
    expect(client.lastActorId, 'staff-1');
  });

  test('maps not_authorized to 403', () async {
    when(() => request.method).thenReturn(HttpMethod.get);
    auth('Bearer $jwt');
    client.throwRpc = const RpcException('not_authorized');

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.forbidden);
  });

  test('maps an unrecognized RPC code to 500, not a benign 409', () async {
    when(() => request.method).thenReturn(HttpMethod.get);
    auth('Bearer $jwt');
    client.throwRpc = const RpcException('some_unexpected_pg_error');

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.internalServerError);
  });

  test('500 on an unexpected data-layer failure', () async {
    when(() => request.method).thenReturn(HttpMethod.get);
    auth('Bearer $jwt');
    client.throwGeneric = Exception('supabase down');

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.internalServerError);
  });
}
