import 'package:flutter/material.dart';
import 'package:hotel_booking_app/data/network/failure_error_handler.dart';
import 'package:hotel_booking_app/features/detail/domain/get_hotel_detail_use_case.dart';
import 'package:hotel_booking_app/model/hotel_model.dart';

class HotelDetailProvider extends ChangeNotifier {
  final GetHotelDetailUseCase _hotelDetailUseCase;

  HotelDetailProvider(this._hotelDetailUseCase);

  HotelModel? _hotelModel;

  HotelModel? get hotelModel => _hotelModel;

  /// [Failure] instance
  Failure? _failure;
  Failure? get failure => _failure;

  void fetchHotelDetail(String name) async {
    try {
      _hotelModel = await _hotelDetailUseCase.fetchHotelDetail(name);
    } on Failure catch (e) {
      _failure = e;
    }
    notifyListeners();
  }
}
