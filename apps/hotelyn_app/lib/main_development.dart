import 'dart:async';

import 'package:hotelyn/app/view/app.dart';
import 'package:hotelyn/bootstrap.dart';
import 'package:hotelyn/core/config/app_config.dart';
import 'package:hotelyn/core/data/storage/storage.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:hotelyn_api_client/hotelyn_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  unawaited(
    bootstrap(() async {
      final localDataSource = SharedStorage(
        sharedPreferences: await SharedPreferences.getInstance(),
      );
      final preferenceRepository = IntroRepository(
        sharedStorage: localDataSource,
      );
      final authRepository = AuthRepository(
        sharedStorage: localDataSource,
      );
      final locationRepository = LocationRepository(
        sharedStorage: localDataSource,
      );

      final clarityService = ClarityService();

      final apiClient = HotelynApiClient(
        baseUrl: AppConfig.apiBaseUrl,
      );
      final hotelRepository = AppHotelRepository(apiClient: apiClient);

      return HotelynApp(
        preferenceRepository: preferenceRepository,
        authRepository: authRepository,
        clarityService: clarityService,
        locationRepository: locationRepository,
        hotelRepository: hotelRepository,
      );
    }),
  );
}
