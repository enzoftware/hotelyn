part of 'hotel_detail_cubit.dart';

/// Status of the hotel detail loading lifecycle.
enum HotelDetailStatus {
  initial,
  loading,
  loaded,
  failure,
}

/// State for [HotelDetailCubit].
class HotelDetailState extends Equatable {
  const HotelDetailState({
    required this.hotel,
    this.status = HotelDetailStatus.initial,
    this.rooms = const [],
    this.hasAvailableRoom = true,
    this.errorMessage,
  });

  /// Factory constructor for the initial state of a given hotel.
  factory HotelDetailState.initial({required domain.Hotel hotel}) {
    return HotelDetailState(hotel: hotel);
  }

  final domain.Hotel hotel;
  final HotelDetailStatus status;
  final List<domain.Room> rooms;
  final bool hasAvailableRoom;
  final String? errorMessage;

  HotelDetailState copyWith({
    domain.Hotel? hotel,
    HotelDetailStatus? status,
    List<domain.Room>? rooms,
    bool? hasAvailableRoom,
    String? errorMessage,
  }) {
    return HotelDetailState(
      hotel: hotel ?? this.hotel,
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      hasAvailableRoom: hasAvailableRoom ?? this.hasAvailableRoom,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    hotel,
    status,
    rooms,
    hasAvailableRoom,
    errorMessage,
  ];
}
