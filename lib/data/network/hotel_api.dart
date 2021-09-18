import 'package:dio/dio.dart';
import 'package:hotel_booking_app/model/hotel_model.dart';
import 'package:retrofit/retrofit.dart';

part 'hotel_api.g.dart';

@RestApi(baseUrl: 'https://raw.githubusercontent.com')
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @GET('/enzoftware/hotel_booking_app/master/server/hotels.json')
  Future<List<Hotel>> getHotels();
}
