import 'package:flutter/material.dart';
import 'package:hotel_booking_app/data/network/failure_error_handler.dart';
import 'package:hotel_booking_app/features/home/domain/get_hotel_use_case.dart';
import 'package:hotel_booking_app/model/hotel_model.dart';

class HotelProvider extends ChangeNotifier {
  final GetHotelsUseCase _hotelsUseCase;

  HotelProvider(this._hotelsUseCase);

  /// Private list of [HotelModel]
  List<HotelModel>? _hotels;

  /// Public getter for hotels
  List<HotelModel>? get hotels => _hotels;

  /// [Failure] instance
  Failure? _failure;
  Failure? get failure => _failure;

  Future<void> retrieveHotels() async {
    try {
      _hotels = await _hotelsUseCase.fetchHotels();
    } on Failure catch (e) {
      _failure = e;
    }
    notifyListeners();
  }
}
