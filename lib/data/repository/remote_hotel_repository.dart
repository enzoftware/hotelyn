import 'package:buscatelo/data/network/hotel_api.dart';
import 'package:buscatelo/data/repository/hotel_repository.dart';
import 'package:buscatelo/model/hotel_model.dart';

class RemoteHotelRepository extends HotelRepository {
  final HotelApi _api;

  RemoteHotelRepository(this._api);
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
