import 'package:buscatelo/data/repository/hotel_repository.dart';
import 'package:buscatelo/model/hotel_model.dart';

class GetHotelDetailUseCase {
  final HotelRepository _hotelRepository;

  GetHotelDetailUseCase(this._hotelRepository);

  Future<HotelModel> fetchHotelDetail(String name) async {
    final response = await _hotelRepository.fetchHotelDetail(name);
    return response;
  }
}
