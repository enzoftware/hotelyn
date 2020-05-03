import 'dart:async';

import 'package:buscatelo/model/hotel_model.dart';

abstract class HotelRepository {
  Future<List<HotelModel>> fetchHotels();
}
