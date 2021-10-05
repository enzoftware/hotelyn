import 'dart:async';

import 'package:hotel_booking_app/data/network/api_result.dart';
import 'package:hotel_booking_app/model/hotel_model.dart';

abstract class HotelRepository {
  Future<ApiResult<List<Hotel>>> fetchHotels();

  /// This would be search by unique identifier, but just for educational
  /// porpouse this would be a name.
  ///
  /// Don't do it this way.
  Future<ApiResult<Hotel>> fetchHotelDetail(String name);
}
