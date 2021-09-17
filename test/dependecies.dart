import 'package:get_it/get_it.dart';
import 'package:hotel_booking_app/data/network/hotel_api.dart';
import 'package:hotel_booking_app/data/repository/hotel_repository.dart';
import 'package:hotel_booking_app/features/detail/domain/get_hotel_detail_use_case.dart';
import 'package:hotel_booking_app/features/detail/provider/hotel_detail_provider.dart';
import 'package:hotel_booking_app/features/home/domain/get_hotel_use_case.dart';
import 'package:hotel_booking_app/features/home/provider/hotel_provider.dart';

import 'repository/hotel_repository_test.dart';
import 'repository/mock_hotel_repository.dart';

GetIt getIt = GetIt.instance;

void setupTestDependencies() {
  /// API
  getIt.registerSingleton<HotelApi>(MockApi());

  /// Repositories
  getIt.registerSingleton<HotelRepository>(MockHotelRepository());

  /// Use-cases
  getIt.registerSingleton(GetHotelsUseCase(getIt.get<HotelRepository>()));
  getIt.registerSingleton(GetHotelDetailUseCase(getIt.get<HotelRepository>()));

  // Providers
  getIt.registerSingleton<HotelProvider>(
    HotelProvider(getIt.get<GetHotelsUseCase>()),
  );
  getIt.registerSingleton<HotelDetailProvider>(
    HotelDetailProvider(getIt.get<GetHotelDetailUseCase>()),
  );
}
