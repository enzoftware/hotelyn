import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';
import 'package:hotelyn/features/home/home.dart';
import 'package:hotelyn/features/on_boarding/on_boarding.dart';
import 'package:hotelyn/features/splash/splash.dart';

class HotelynApp extends StatelessWidget {
  const HotelynApp({
    required OnBoardingRepository preferenceRepository,
    super.key,
  }) : _preferenceRepository = preferenceRepository;

  final OnBoardingRepository _preferenceRepository;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: _preferenceRepository),
        ],
        child: MaterialApp(
          title: 'Hotelyn',
          theme: ThemeData(
            fontFamily: 'DMSans',
            appBarTheme: const AppBarTheme(),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: HotelynColors.white,
            ),
            cardTheme: const CardThemeData(
              surfaceTintColor: HotelynColors.white,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: HotelynColors.blue,
              surface: HotelynColors.white,
            ),
            navigationBarTheme: const NavigationBarThemeData(
              backgroundColor: Colors.transparent,
            ),
            useMaterial3: true,
          ),
          initialRoute: SplashScreen.route,
          routes: {
            SplashScreen.route: (_) => const SplashScreen(),
            OnBoardingPage.route: (_) => const OnBoardingPage(),
            HomePage.route: (_) => const HomePage(),
          },
        ),
      ),
    );
  }
}
