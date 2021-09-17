import 'package:hotel_booking_app/data/network/hotel_api.dart';
import 'package:hotel_booking_app/data/repository/hotel_repository.dart';
import 'package:hotel_booking_app/model/hotel_model.dart';

class RemoteHotelRepository extends HotelRepository {

  RemoteHotelRepository(this._api);

  final HotelApi _api;

  @override
  Future<List<HotelModel>> fetchHotels() async {
    return await _api.getHotels();
  }

  @override
  Future<HotelModel> fetchHotelDetail(String name) async {
    final response = await _api.getHotels();
    return response.firstWhere((element) => element.name == name);
  }
}
