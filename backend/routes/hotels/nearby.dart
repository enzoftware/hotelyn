import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// `GET /hotels/nearby?lat=&lng=&radiusKm=`
///
/// Hotels within `radiusKm` of (`lat`, `lng`), nearest-first. Responds with a
/// JSON array of hotels, `400` for a missing/invalid param, `500` on a data
/// failure (internal detail is not leaked).
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final double lat;
  final double lng;
  final double radiusKm;
  try {
    lat = requiredDouble(context, 'lat');
    lng = requiredDouble(context, 'lng');
    radiusKm = requiredDouble(context, 'radiusKm');
  } on BadRequestException catch (error) {
    return badRequest(error.message);
  }

  try {
    final hotels = await context.read<HotelDataClient>().nearbyHotels(
          lat: lat,
          lng: lng,
          radiusKm: radiusKm,
        );
    return Response.json(body: hotels.map((h) => h.toJson()).toList());
  } on Object {
    return internalError();
  }
}
