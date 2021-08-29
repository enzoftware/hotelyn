import 'dart:async';

import 'package:buscatelo/model/hotel_model.dart';

abstract class HotelRepository {
  Future<List<HotelModel>> fetchHotels();

  /// This would be search by unique identifier, but just for educational
  /// porpouse this would be a name.
  ///
  /// Don't do it this way.
  Future<HotelModel> fetchHotelDetail(String name);
}
