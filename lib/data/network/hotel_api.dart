import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:buscatelo/model/hotel_model.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'failure_error_handler.dart';

class HotelApi {
  final String _baseUrl = 'https://raw.githubusercontent.com';
  final String _endPoint =
      '/enzoftware/hotel_booking_app/master/server/hotels.json';

  Client client = http.Client();

  Future<List<HotelModel>> getHotels() async {
    try {
      final data = await client.get(Uri.parse(_baseUrl + _endPoint));
      final responseList = json.decode(data.body);
      await Future.delayed(const Duration(seconds: 2));
      return [for (final hotel in responseList) HotelModel.fromJson(hotel)];
    } on SocketException {
      throw Failure('No internet connection', 400);
    } on HttpException {
      throw Failure('Not found request', 404);
    } on FormatException {
      throw Failure('Invalid JSON format', 666);
    } catch (e) {
      throw Failure('Unknown error', 888);
    }
  }
}
