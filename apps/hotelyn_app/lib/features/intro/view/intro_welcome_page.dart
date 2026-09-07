import 'package:california_ui/california_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelyn/components/icons/hotelyn_icon.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';
import 'package:hotelyn/features/home/home.dart';
import 'package:hotelyn/features/login/view/login_page.dart';

class IntroWelcomePage extends StatelessWidget {
  const IntroWelcomePage({super.key});

  static const route = '/intro/welcome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CaliforniaColors.surfacePrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const HotelynIcon(),
              const SizedBox(height: 30),
              const Text(
                'Welcome to Hotelyn',
                style: CaliforniaTypography.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'If you are new here please create your account first before '
                'book the hotel.',
                style: CaliforniaTypography.p14Regular.copyWith(
                  color: CaliforniaColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CaliforniaButton.primary(
                width: double.infinity,
                label: 'Create Account / Login',
                onPressed: () {
                  context.read<IntroRepository>().setIntroPassed();
                  context.go(LoginPage.route);
                },
              ),
              const SizedBox(height: 16),
              CaliforniaButton.ghost(
                width: double.infinity,
                label: 'Go To Homepage',
                onPressed: () {
                  context.read<IntroRepository>().setIntroPassed();
                  context.go(HomePage.route);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
