import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelyn/app/router/app_router.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';

class HotelynApp extends StatelessWidget {
  const HotelynApp({
    required IntroRepository preferenceRepository,
    super.key,
  }) : _preferenceRepository = preferenceRepository;

  final IntroRepository _preferenceRepository;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: _preferenceRepository),
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
