import 'package:buscatelo/features/detail/domain/get_hotel_detail_use_case.dart';
import 'package:flutter/material.dart';

class HotelDetailProvider extends ChangeNotifier {
  final GetHotelDetailUseCase _hotelDetailUseCase;

  HotelDetailProvider(this._hotelDetailUseCase);

  void fetchHotelDetail() {}
}
