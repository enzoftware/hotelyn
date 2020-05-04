import 'package:buscatelo/data/network/hotel_api.dart';
import 'package:buscatelo/data/repository/hotel_repository.dart';
import 'package:buscatelo/model/hotel_model.dart';

class RemoteHotelRepository extends HotelRepository {
  @override
  Future<List<HotelModel>> fetchHotels() async {
    final api = HotelApi();
    return await api.getHotels();
  }
}
