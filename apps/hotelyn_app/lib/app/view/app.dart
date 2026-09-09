import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelyn/app/router/app_router.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;

class HotelynApp extends StatelessWidget {
  const HotelynApp({
    required this.preferenceRepository,
    required this.authRepository,
    required this.clarityService,
    required this.locationRepository,
    required this.hotelRepository,
    super.key,
  });

  final IntroRepository preferenceRepository;
  final AuthRepository authRepository;
  final ClarityService clarityService;
  final LocationRepository locationRepository;
  final domain.HotelRepository hotelRepository;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: preferenceRepository),
          RepositoryProvider.value(value: authRepository),
          RepositoryProvider.value(value: clarityService),
          RepositoryProvider.value(value: locationRepository),
          RepositoryProvider<domain.HotelRepository>.value(
            value: hotelRepository,
          ),
        ],
        child: BlocProvider(
          create: (_) {
            final cubit = LocationCubit(
              locationRepository: locationRepository,
            );
            unawaited(
              cubit.loadLocation().catchError((Object error, StackTrace stack) {
                log(
                  'Failed to load initial location',
                  error: error,
                  stackTrace: stack,
                  name: 'HotelynApp',
                );
              }),
            );
            return cubit;
          },
          child: MaterialApp.router(
            routerConfig: AppRouter.router,
            title: 'Hotelyn',
            theme: ThemeData(
              fontFamily: 'DMSans',
              appBarTheme: const AppBarTheme(),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: PrimaryColors.white,
              ),
              cardTheme: const CardThemeData(
                surfaceTintColor: PrimaryColors.white,
              ),
              colorScheme: ColorScheme.fromSeed(
                seedColor: PrimaryColors.blue,
                surface: PrimaryColors.white,
              ),
              navigationBarTheme: const NavigationBarThemeData(
                backgroundColor: Colors.transparent,
              ),
              useMaterial3: true,
            ),
          ),
        ),
      ),
    );
  }
}
