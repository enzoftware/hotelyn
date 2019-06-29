import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:barbarian/barbarian.dart';
import 'package:buscatelo/model/hotel_model.dart';
import 'package:http/http.dart';

class HotelApi {
  final String _baseUrl = 'buscatelo-api-rest.herokuapp.com';
  final String _hotelUrl = '/hotel'; 

  HotelApi() {
    Barbarian.init();
  }

  Future<List<HotelModel>> getHotels() async {
    final uri = Uri.https(_baseUrl, _hotelUrl);
    final response = await _getJson(uri);
    if (response == null) {
      print('Api.getHotels() : Error jwt');
      return null;
    }
    return _convert(response);
  }

  Future<List<dynamic>> _getJson(Uri uri) async {
    try {
      String jwt = Barbarian.read('userJwt') ?? 'webadaDeJsonWebToken';
      final headers = {'auth': jwt};
      var response = await get(uri, headers: headers);
      if (response.statusCode == HttpStatus.ok) {
        return json.decode(response.body);
      } else {
        print('Api._getHotel($uri) status code is ${response.statusCode}');
        return null;
      }
    } on Exception catch (e) {
      print('Api._getJson($uri) exception thrown $e');
      return null;
    }
  }

  List<HotelModel> _convert(List productJson) {
    List<HotelModel> items = <HotelModel>[];
    productJson.forEach((item) {
      items.add(HotelModel.fromJson(item));
    });
    return items;
  }
}
