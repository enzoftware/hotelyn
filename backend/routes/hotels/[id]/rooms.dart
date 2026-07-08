import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// `GET /hotels/{id}/rooms`
///
/// Rooms for a single hotel, each with a computed `available_now` flag.
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final rooms =
        await context.read<HotelDataClient>().roomsAvailability(hotelId: id);
    return Response.json(body: rooms.map((r) => r.toJson()).toList());
  } on Object {
    return internalError();
  }
}
