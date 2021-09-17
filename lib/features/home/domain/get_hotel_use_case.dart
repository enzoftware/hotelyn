import 'package:hotel_booking_app/data/repository/hotel_repository.dart';
import 'package:hotel_booking_app/model/hotel_model.dart';

class GetHotelsUseCase {
  final HotelRepository _hotelRepository;

  GetHotelsUseCase(this._hotelRepository);

  Future<List<HotelModel>> fetchHotels() async {
    final response = await _hotelRepository.fetchHotels();
    return response;
  }
}
