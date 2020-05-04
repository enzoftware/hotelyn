import 'package:buscatelo/data/repository/hotel_repository.dart';
import 'package:buscatelo/data/repository/remote_hotel_repository.dart';
import 'package:buscatelo/model/hotel_model.dart';
import 'package:flutter/material.dart';

class HotelBloc extends ChangeNotifier {
  HotelRepository repository = RemoteHotelRepository();

  /// Private list of [HotelModel]
  List<HotelModel> _hotels;

  /// Public getter for hotels
  List<HotelModel> get hotels => _hotels;

  void retrieveHotels() async {
    _hotels = await repository.fetchHotels();
    notifyListeners();
  }
}
