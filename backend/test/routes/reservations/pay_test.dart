import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/reservations/[id]/pay.dart' as pay;
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

  test('rejects non-POST with 405', () async {
    when(() => request.method).thenReturn(HttpMethod.get);
    final response = await pay.onRequest(context, 'res-1');
    expect(response.statusCode, HttpStatus.methodNotAllowed);
  });

  test('401 when unauthenticated', () async {
    when(() => request.method).thenReturn(HttpMethod.post);
    when(() => request.headers).thenReturn(<String, String>{});
    final response = await pay.onRequest(context, 'res-1');
    expect(response.statusCode, HttpStatus.unauthorized);
  });

  test('marks paid and returns the confirmed reservation', () async {
    when(() => request.method).thenReturn(HttpMethod.post);

    final response = await pay.onRequest(context, 'res-1');

    expect(response.statusCode, HttpStatus.ok);
    final body = jsonDecode(await response.body()) as Map<String, dynamic>;
    expect(body['status'], 'confirmed');
    // The audit metadata must survive serialization to the HTTP response.
    expect(body['paid_by'], 'staff-1');
    expect(body['paid_at'], '2026-09-01T10:30:00.000Z');
    expect(client.lastReservationId, 'res-1');
    expect(client.lastActorId, 'staff-1');
  });

  test('maps not_authorized to 403', () async {
    when(() => request.method).thenReturn(HttpMethod.post);
    client.throwRpc = const RpcException('not_authorized');

    final response = await pay.onRequest(context, 'res-1');

    expect(response.statusCode, HttpStatus.forbidden);
  });

  test('maps reservation_not_found to 404', () async {
    when(() => request.method).thenReturn(HttpMethod.post);
    client.throwRpc = const RpcException('reservation_not_found');

    final response = await pay.onRequest(context, 'res-1');

    expect(response.statusCode, HttpStatus.notFound);
  });

  test('maps reservation_not_payable to 409', () async {
    when(() => request.method).thenReturn(HttpMethod.post);
    client.throwRpc = const RpcException('reservation_not_payable');

    final response = await pay.onRequest(context, 'res-1');

    expect(response.statusCode, HttpStatus.conflict);
    final body = jsonDecode(await response.body()) as Map<String, dynamic>;
    final errors = body['errors'] as List<dynamic>;
    expect(
      (errors.first as Map<String, dynamic>)['message'],
      'This reservation cannot be marked paid; it is not a live hold.',
    );
  });

  test('500 on an unexpected data-layer failure', () async {
    when(() => request.method).thenReturn(HttpMethod.post);
    client.throwGeneric = Exception('supabase down');

    final response = await pay.onRequest(context, 'res-1');

    expect(response.statusCode, HttpStatus.internalServerError);
  });
}
