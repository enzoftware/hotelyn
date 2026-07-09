import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// `GET /staff/rooms`
///
/// The acting staff member's own hotel rooms, each with a derived status
/// (available / unavailable / held / occupied). Scope comes from the caller's
/// JWT, never a client-supplied hotel id (BE-501).
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  return staffAction(context, (actorId) async {
    final rooms =
        await context.read<HotelDataClient>().staffRoomList(actorId: actorId);
    return Response.json(body: rooms.map((r) => r.toJson()).toList());
  });
}
