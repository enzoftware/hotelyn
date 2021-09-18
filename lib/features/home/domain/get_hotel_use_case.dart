import 'package:hotel_booking_app/data/repository/hotel_repository.dart';
import 'package:hotel_booking_app/model/hotel_model.dart';

class GetHotelsUseCase {
  GetHotelsUseCase(this._hotelRepository);

  final HotelRepository _hotelRepository;

  // Future<List<Hotel>> fetchHotels() async {
  //   final response = await _hotelRepository.fetchHotels();
  //   return response;
  // }
}
