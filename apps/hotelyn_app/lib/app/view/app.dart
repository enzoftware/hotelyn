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

class HotelynApp extends StatelessWidget {
  const HotelynApp({
    required IntroRepository preferenceRepository,
    required AuthRepository authRepository,
    required ClarityService clarityService,
    required LocationRepository locationRepository,
    super.key,
  })  : _preferenceRepository = preferenceRepository,
        _authRepository = authRepository,
        _clarityService = clarityService,
        _locationRepository = locationRepository;

  final IntroRepository _preferenceRepository;
  final AuthRepository _authRepository;
  final ClarityService _clarityService;
  final LocationRepository _locationRepository;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: _preferenceRepository),
          RepositoryProvider.value(value: _authRepository),
          RepositoryProvider.value(value: _clarityService),
          RepositoryProvider.value(value: _locationRepository),
        ],
        child: BlocProvider(
          create: (_) {
            final cubit = LocationCubit(
              locationRepository: _locationRepository,
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
