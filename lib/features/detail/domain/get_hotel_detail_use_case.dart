import 'package:hotel_booking_app/data/repository/hotel_repository.dart';
import 'package:hotel_booking_app/model/hotel_model.dart';

class GetHotelDetailUseCase {
  GetHotelDetailUseCase(this._hotelRepository);

  final HotelRepository _hotelRepository;

  Future<HotelModel> fetchHotelDetail(String name) async {
    final response = await _hotelRepository.fetchHotelDetail(name);
    return response;
  }
}
