import 'package:hotel_booking_app/data/network/api_result.dart';
import 'package:hotel_booking_app/data/network/hotel_api.dart';
import 'package:hotel_booking_app/data/repository/hotel_repository.dart';
import 'package:hotel_booking_app/model/hotel_model.dart';

class RemoteHotelRepository extends HotelRepository {
  RemoteHotelRepository(this._api);

  final RestClient _api;

  @override
  Future<ApiResult<Hotel>> fetchHotelDetail(String name) async {
    try {
      final response = await _api.getHotels();
      final hotel = response.firstWhere(
        (element) => element.name == name,
        orElse: () => Hotel.empty(),
      );
      return ApiResult.success(hotel);
    } catch (e) {
      return ApiResult.failure(Exception(e));
    }
  }

  @override
  Future<ApiResult<List<Hotel>>> fetchHotels() async {
    try {
      final response = await _api.getHotels();
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(Exception(e));
    }
  }
}
