import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';
import 'package:hotelyn/features/home/home.dart';
import 'package:hotelyn/features/intro/intro.dart';
import 'package:hotelyn/features/login/view/login_page.dart';
import 'package:hotelyn/features/splash/splash.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const route = '/splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => SplashBloc(
          introRepository: context.read<IntroRepository>(),
          authRepository: context.read<AuthRepository>(),
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
          context.go(HomePage.route);
        }

        if (state is SplashToIntro) {
          context.go(IntroPage.route);
        }

        if (state is SplashToLogin) {
          context.go(LoginPage.route);
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
