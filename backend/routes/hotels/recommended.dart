import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// `GET /hotels/recommended?lat=&lng=&radiusKm=`
///
/// Popular-yet-nearby hotels within `radiusKm` of (`lat`, `lng`). Same shape as
/// `/hotels/nearby`, ranked by popularity.
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
    final hotels = await context.read<HotelDataClient>().recommendedHotels(
          lat: lat,
          lng: lng,
          radiusKm: radiusKm,
        );
    return Response.json(body: hotels.map((h) => h.toJson()).toList());
  } on Object {
    return internalError();
  }
}
