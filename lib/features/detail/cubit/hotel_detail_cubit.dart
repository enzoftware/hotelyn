// ignore_for_file: avoid_void_async

import 'package:bloc/bloc.dart';
import 'package:hotel_booking_app/data/repository/hotel_repository.dart';
import 'package:hotel_booking_app/features/base/result_state.dart';
import 'package:hotel_booking_app/model/hotel_model.dart';

class HotelDetailCubit extends Cubit<ResultState<Hotel>> {
  HotelDetailCubit(this._repository) : super(const Initial());

  final HotelRepository _repository;

  void loadHotelDetail(String name) async {
    emit(const ResultState.loading());
    final result = await _repository.fetchHotelDetail(name);
    result.when(
      success: (data) => emit(ResultState.data(data)),
      failure: (e) => emit(ResultState.error(e)),
    );
  }
}
