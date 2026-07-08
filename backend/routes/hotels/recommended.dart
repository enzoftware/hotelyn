import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// `GET /hotels/recommended?lat=&lng=&radiusKm=`
///
/// Popular-yet-nearby hotels within `radiusKm` of (`lat`, `lng`). Same shape as
/// `/hotels/nearby`, ranked by popularity.
Future<Response> onRequest(RequestContext context) => handleHotelSearchRoute(
      context,
      search: context.read<HotelDataClient>().recommendedHotels,
    );
