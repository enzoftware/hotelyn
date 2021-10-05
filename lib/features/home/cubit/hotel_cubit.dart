// ignore_for_file: avoid_void_async

import 'package:bloc/bloc.dart';
import 'package:hotel_booking_app/data/repository/hotel_repository.dart';
import 'package:hotel_booking_app/features/base/result_state.dart';
import 'package:hotel_booking_app/model/hotel_model.dart';

class HotelCubit extends Cubit<ResultState<List<Hotel>>> {
  HotelCubit(this._repository) : super(const Initial());

  final HotelRepository _repository;

  void loadHotels() async {
    emit(const ResultState.loading());
    final result = await _repository.fetchHotels();
    result.when(
      success: (data) => emit(ResultState.data(data)),
      failure: (e) => emit(ResultState.error(e)),
    );
  }
}
