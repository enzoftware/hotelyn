import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn_api_client/hotelyn_api_client.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;

part 'hotel_detail_state.dart';

/// Cubit managing hotel detail data and live room availability check.
class HotelDetailCubit extends Cubit<HotelDetailState> {
  HotelDetailCubit({
    required this.hotel,
    required this.apiClient,
  }) : super(HotelDetailState.initial(hotel: hotel));

  final domain.Hotel hotel;
  final HotelynApiClient apiClient;

  /// Fetches rooms for the current hotel and updates live availability.
  Future<void> checkAvailability() async {
    emit(state.copyWith(status: HotelDetailStatus.loading));
    try {
      final rooms = await apiClient.getRooms(hotelId: hotel.id);
      final hasAvailableRoom =
          rooms.isEmpty || rooms.any((room) => room.availableNow);
      emit(
        state.copyWith(
          status: HotelDetailStatus.loaded,
          rooms: rooms,
          hasAvailableRoom: hasAvailableRoom,
        ),
      );
    } on ApiException catch (error, stack) {
      log(
        'API error checking room availability for hotel ${hotel.id}',
        error: error,
        stackTrace: stack,
        name: 'HotelDetailCubit',
      );
      // If endpoint fails or is offline, fall back to available to not block
      // booking.
      emit(
        state.copyWith(
          status: HotelDetailStatus.loaded,
          rooms: const [],
          hasAvailableRoom: true,
        ),
      );
    } on Exception catch (error, stack) {
      log(
        'Error checking room availability for hotel ${hotel.id}',
        error: error,
        stackTrace: stack,
        name: 'HotelDetailCubit',
      );
      emit(
        state.copyWith(
          status: HotelDetailStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
