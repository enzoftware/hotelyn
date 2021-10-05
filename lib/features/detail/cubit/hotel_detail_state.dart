import 'package:equatable/equatable.dart';

enum HotelDetailStatus { initial, loading, success, error }

extension XHotelDetailStatus on HotelDetailStatus {
  bool get isInitial => this == HotelDetailStatus.initial;
  bool get isLoading => this == HotelDetailStatus.loading;
  bool get isSuccess => this == HotelDetailStatus.success;
  bool get isFailure => this == HotelDetailStatus.error;
}

class HotelDetailState extends Equatable {
  @override
  List<Object?> get props => throw UnimplementedError();
}
