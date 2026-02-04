import 'dart:async';

import 'package:hotelyn/app/view/app.dart';
import 'package:hotelyn/bootstrap.dart';
import 'package:hotelyn/core/data/storage/storage.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
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

      final clarityService = ClarityService();

      return HotelynApp(
        preferenceRepository: preferenceRepository,
        clarityService: clarityService,
      );
    }),
  );
}
