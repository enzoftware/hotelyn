import 'package:buscatelo/data/network/failure_error_handler.dart';
import 'package:buscatelo/features/detail/domain/get_hotel_detail_use_case.dart';
import 'package:buscatelo/model/hotel_model.dart';
import 'package:flutter/material.dart';

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
