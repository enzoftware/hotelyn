import 'package:buscatelo/data/network/hotel_api.dart';
import 'package:buscatelo/data/repository/hotel_repository.dart';
import 'package:buscatelo/data/repository/remote_hotel_repository.dart';
import 'package:buscatelo/features/detail/domain/get_hotel_detail_use_case.dart';
import 'package:buscatelo/features/detail/provider/hotel_detail_provider.dart';
import 'package:buscatelo/features/home/domain/get_hotel_use_case.dart';
import 'package:buscatelo/features/home/provider/hotel_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

void setupDependencies() {
  /// API
  getIt.registerSingleton<HotelApi>(HotelApi());

  /// Repositories
  getIt.registerSingleton<HotelRepository>(
    RemoteHotelRepository(getIt.get<HotelApi>()),
  );

  /// Use-cases
  getIt.registerSingleton<GetHotelsUseCase>(
    GetHotelsUseCase(getIt.get<HotelRepository>()),
  );
  getIt.registerSingleton<GetHotelDetailUseCase>(
    GetHotelDetailUseCase(getIt.get<HotelRepository>()),
  );

  // Providers
  getIt.registerSingleton<HotelProvider>(
    HotelProvider(getIt.get<GetHotelsUseCase>()),
  );
  getIt.registerSingleton<HotelDetailProvider>(
    HotelDetailProvider(getIt.get<GetHotelDetailUseCase>()),
  );
}

@visibleForTesting
void setupTestDependencies() {}
