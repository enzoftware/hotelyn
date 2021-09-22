import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hotel_booking_app/data/network/hotel_api.dart';
import 'package:hotel_booking_app/data/repository/hotel_repository.dart';
import 'package:hotel_booking_app/data/repository/remote_hotel_repository.dart';
import 'package:hotel_booking_app/features/detail/domain/get_hotel_detail_use_case.dart';
import 'package:hotel_booking_app/features/home/domain/get_hotel_use_case.dart';

GetIt getIt = GetIt.instance;

void setupDependencies() {
  getIt
    ..registerSingleton(
      Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onResponse: (res, handler) {
              log('${res.statusCode} - ${res.data}');
              if (res.headers.map[Headers.contentTypeHeader]?.first
                      .startsWith('text') ==
                  true) {
                res.data = jsonDecode(res.data as String);
                return handler.next(res);
              }
              return handler.next(res);
            },
            onError: (e, handler) {
              log('${e.response?.statusCode} - ${e.message}');
              handler.next(e);
            },
          ),
        ),
    )
    ..registerSingleton(RestClient(getIt.get<Dio>()))
    ..registerSingleton<HotelRepository>(
        RemoteHotelRepository(getIt.get<RestClient>()))
    ..registerSingleton<GetHotelsUseCase>(GetHotelsUseCase())
    ..registerSingleton<GetHotelDetailUseCase>(GetHotelDetailUseCase());
}
