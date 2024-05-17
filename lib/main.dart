import 'package:flutter/material.dart';
import 'package:hotelyn/app.dart';
import 'package:hotelyn/core/data/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/domain/repository/repository.dart';

void main() async {
  final localDataSource = SharedStorage(
    sharedPreferences: await SharedPreferences.getInstance(),
  );
  final preferenceRepository = OnBoardingRepository(
    sharedStorage: localDataSource,
  );

  runApp(
    HotelynApp(
      preferenceRepository: preferenceRepository,
    ),
  );
}
