import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';
import 'package:hotelyn/core/domain/repository/onboarding_repository.dart';
import 'package:hotelyn/features/home/home_tab.dart';
import 'package:hotelyn/features/onboarding/on_boarding_page.dart';
import 'package:hotelyn/features/onboarding/on_boarding_welcome_page.dart';

import 'features/splash/splash.dart';

class HotelynApp extends StatelessWidget {
  const HotelynApp({
    required OnBoardingRepository preferenceRepository,
    super.key,
  }) : _preferenceRepository = preferenceRepository;

  final OnBoardingRepository _preferenceRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _preferenceRepository),
      ],
      child: MaterialApp(
        title: 'Hotelyn',
        theme: ThemeData(
          fontFamily: 'DMSans',
          appBarTheme: const AppBarTheme(),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: HotelynAppColors.white,
          ),
          cardTheme: const CardTheme(
            surfaceTintColor: HotelynAppColors.white,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: HotelynAppColors.blue,
            surface: HotelynAppColors.white,
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
          OnBoardingWelcomePage.route: (_) => const OnBoardingWelcomePage(),
          HomePage.route: (_) => const HomePage(),
        },
      ),
    );
  }
}
