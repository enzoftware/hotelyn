import 'package:buscatelo/data/network/hotel_api.dart';
import 'package:buscatelo/data/repository/hotel_repository.dart';
import 'package:buscatelo/data/repository/remote_hotel_repository.dart';
import 'package:buscatelo/features/home/domain/get_hotel_use_case.dart';
import 'package:buscatelo/features/home/provider/hotel_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<HotelApi>(HotelApi());
  getIt.registerSingleton<HotelRepository>(
    RemoteHotelRepository(getIt.get<HotelApi>()),
  );
  getIt.registerSingleton<GetHotelsUseCase>(
    GetHotelsUseCase(getIt.get<HotelRepository>()),
  );
  getIt.registerSingleton<HotelProvider>(
    HotelProvider(getIt.get<GetHotelsUseCase>()),
  );
}

@visibleForTesting
void setupTestDependencies() {}
