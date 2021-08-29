import 'dart:io';

import 'package:buscatelo/data/network/failure_error_handler.dart';
import 'package:buscatelo/data/network/hotel_api.dart';
import 'package:buscatelo/data/repository/hotel_repository.dart';
import 'package:buscatelo/model/hotel_model.dart';

class RemoteHotelRepository extends HotelRepository {
  final HotelApi _api;

  RemoteHotelRepository(this._api);
  @override
  Future<List<HotelModel>> fetchHotels() async {
    try {
      return await _api.getHotels();
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

  @override
  Future<HotelModel> fetchHotelDetail(String name) async {
    try {
      final response = await _api.getHotels();
      return response.firstWhere((element) => element.name == name);
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
