import 'package:flutter/material.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';
import 'package:hotelyn/features/home/home_tab.dart';
import 'package:hotelyn/features/onboarding/on_boarding_page.dart';
import 'package:hotelyn/features/onboarding/on_boarding_welcome_page.dart';

class HotelynApp extends StatelessWidget {
  const HotelynApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotelyn',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: HotelynAppColors.white,
        ),
        cardTheme: const CardTheme(
          surfaceTintColor: HotelynAppColors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: HotelynAppColors.blue,
          background: HotelynAppColors.white,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.transparent,
        ),
        useMaterial3: true,
      ),
      initialRoute: HomePage.route,
      routes: {
        OnBoardingPage.route: (_) => const OnBoardingPage(),
        OnBoardingWelcomePage.route: (_) => const OnBoardingWelcomePage(),
        HomePage.route: (_) => const HomePage(),
      },
    );
  }
}
