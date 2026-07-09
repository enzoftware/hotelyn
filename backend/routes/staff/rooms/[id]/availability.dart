import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// `PATCH /staff/rooms/{id}/availability`  body: `{ "is_available": bool }`
///
/// Staff toggle of a room's availability (BE-502). Refuses to re-enable a room
/// that has an active hold/confirmed reservation. Returns the updated room with
/// its freshly derived status.
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.patch) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  return staffAction(context, (actorId) async {
    final bool isAvailable;
    try {
      final body = jsonDecode(await context.request.body());
      if (body is! Map<String, dynamic> || body['is_available'] is! bool) {
        return badRequest('Body must be a JSON object with a boolean '
            '"is_available".');
      }
      isAvailable = body['is_available'] as bool;
    } on FormatException {
      return badRequest('Request body was not valid JSON.');
    }

    final room = await context.read<HotelDataClient>().setRoomAvailability(
          actorId: actorId,
          roomId: id,
          isAvailable: isAvailable,
        );
    return Response.json(body: room.toJson());
  });
}
