import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/features/home/home_tab.dart';
import 'package:hotelyn/features/onboarding/on_boarding_page.dart';
import 'package:hotelyn/features/splash/splash_cubit.dart';
import 'package:hotelyn/features/splash/splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const route = '/splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => SplashCubit(),
        child: BlocConsumer<SplashCubit, SplashState>(
          listener: (context, state) {
            if (state is SplashToHome) {
              Navigator.pushNamed(context, HomePage.route);
            }

            if (state is SplashToOnBoarding) {
              Navigator.pushNamed(context, OnBoardingPage.route);
            }
          },
          builder: (context, state) {
            return const SplashScreenBody();
          },
        ),
      ),
    );
  }
}

class SplashScreenBody extends StatelessWidget {
  const SplashScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/hotelyn/hotelyn.png',
        height: 50,
      ),
    );
  }
}
