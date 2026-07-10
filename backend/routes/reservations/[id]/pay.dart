import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// `POST /reservations/{id}/pay`
///
/// Owning-hotel staff mark a held reservation as paid in person (BE-702),
/// completing the booking (→ `confirmed`) with no online payment integration.
/// `403` if the caller is not the hotel's staff, `404` if the reservation does
/// not exist, `409` if it is not a live hold (already confirmed, terminal, or
/// expired). Returns the confirmed reservation.
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  return staffAction(context, (actorId) async {
    final reservation =
        await context.read<HotelDataClient>().markReservationPaid(
              actorId: actorId,
              reservationId: id,
            );
    return Response.json(body: reservation.toJson());
  });
}
