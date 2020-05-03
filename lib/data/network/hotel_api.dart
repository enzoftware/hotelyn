import 'dart:async';
import 'package:buscatelo/model/hotel_model.dart';

class HotelApi {
  final String _baseUrl = 'buscatelo-api-rest.herokuapp.com';

  Future<List<HotelModel>> getHotels() async {}

  Future<List<dynamic>> _getJson(Uri uri) async {
    try {} on Exception catch (e) {
      print('Api._getJson($uri) exception thrown $e');
      return null;
    }
  }
}
