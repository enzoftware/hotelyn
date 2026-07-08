import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// Signature of a radius-search over the [HotelDataClient]: `nearbyHotels` and
/// `recommendedHotels` both match it, differing only in ranking.
typedef HotelSearch = Future<List<Hotel>> Function({
  required double lat,
  required double lng,
  required double radiusKm,
});

/// Shared handler for the `/hotels/nearby` and `/hotels/recommended` routes,
/// which have an identical request/response contract.
///
/// Enforces `GET`, parses the required `lat`/`lng`/`radiusKm` query params,
/// calls [search], and serializes the resulting hotels to a JSON array.
/// Responds `405` for a wrong method, `400` for a missing/invalid param, and
/// `500` on a data failure (internal detail is not leaked).
Future<Response> handleHotelSearchRoute(
  RequestContext context, {
  required HotelSearch search,
}) async {
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
    final hotels = await search(lat: lat, lng: lng, radiusKm: radiusKm);
    return Response.json(body: hotels.map((h) => h.toJson()).toList());
  } on Object {
    return internalError();
  }
}
