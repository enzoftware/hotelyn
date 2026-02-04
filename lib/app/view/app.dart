import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelyn/app/router/app_router.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';
import 'package:hotelyn/core/services/clarity_service.dart';

class HotelynApp extends StatelessWidget {
  const HotelynApp({
    required IntroRepository preferenceRepository,
    required ClarityService clarityService,
    super.key,
  })  : _preferenceRepository = preferenceRepository,
        _clarityService = clarityService;

  final IntroRepository _preferenceRepository;
  final ClarityService _clarityService;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: _preferenceRepository),
          RepositoryProvider.value(value: _clarityService),
        ],
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
    );
  }
}
