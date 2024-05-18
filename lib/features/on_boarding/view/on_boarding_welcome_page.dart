import 'package:flutter/material.dart';
import 'package:hotelyn/components/buttons/hotelyn_button.dart';
import 'package:hotelyn/components/icons/hotelyn_icon.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/features/home/home_tab.dart';

class OnBoardingWelcomePage extends StatelessWidget {
  const OnBoardingWelcomePage({super.key});

  static const route = '/on_boarding/welcome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HotelynIcon(),
            const SizedBox(height: 30),
            const Text(
              'Welcome to Hotelyn',
              style: HotelynTextStyle.h1,
            ),
            const SizedBox(height: 16),
            const Text(
              'If you are new here please create your account first before book the hotel.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 120),
            HotelynButton(
              message: 'Create Account / Login',
              onPressed: () {},
            ),
            const SizedBox(height: 16),
            HotelynButton.secondary(
              message: 'Go To Homepage',
              onPressed: () {
                Navigator.pushReplacementNamed(context, HomePage.route);
              },
            ),
          ],
        ),
      ),
    );
  }
}
