import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// `POST /reservations/{id}/confirm`
///
/// Owning-hotel staff confirm a held reservation (BE-503). Fails with `409` if
/// the hold has already expired, or `403` if the caller is not the hotel's
/// staff. Returns the confirmed reservation.
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  return staffAction(context, (actorId) async {
    final reservation =
        await context.read<HotelDataClient>().confirmReservation(
              actorId: actorId,
              reservationId: id,
            );
    return Response.json(body: reservation.toJson());
  });
}
