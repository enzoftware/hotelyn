import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';
import 'package:hotelyn/features/home/home.dart';
import 'package:hotelyn/features/on_boarding/on_boarding.dart';
import 'package:hotelyn/features/splash/splash.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const route = '/splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => SplashBloc(
          onBoardingRepository: context.read<OnBoardingRepository>(),
        )..add(const SplashStarted()),
        child: const SplashView(),
      ),
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashToHome) {
          Navigator.pushNamed(context, HomePage.route);
        }

        if (state is SplashToOnBoarding) {
          Navigator.pushNamed(context, OnBoardingPage.route);
        }
      },
      builder: (_, __) {
        return const SplashScreenBody();
      },
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
