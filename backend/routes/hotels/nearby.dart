import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// `GET /hotels/nearby?lat=&lng=&radiusKm=`
///
/// Hotels within `radiusKm` of (`lat`, `lng`), nearest-first. Responds with a
/// JSON array of hotels, `400` for a missing/invalid param, `500` on a data
/// failure (internal detail is not leaked).
Future<Response> onRequest(RequestContext context) => handleHotelSearchRoute(
      context,
      search: context.read<HotelDataClient>().nearbyHotels,
    );
