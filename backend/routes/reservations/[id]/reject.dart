import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// `POST /reservations/{id}/reject`
///
/// Owning-hotel staff reject a reservation (BE-503). Sets it to `rejected` and
/// frees the room immediately. `403` if the caller is not the hotel's staff,
/// `409` if the reservation is not active. Returns the rejected reservation.
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  return staffAction(context, (actorId) async {
    final reservation = await context.read<HotelDataClient>().rejectReservation(
          actorId: actorId,
          reservationId: id,
        );
    return Response.json(body: reservation.toJson());
  });
}
