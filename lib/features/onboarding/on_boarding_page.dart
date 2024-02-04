import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/buttons/hotelyn_button.dart';
import 'package:hotelyn/components/dot_indicator/dot_indicator.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/features/onboarding/data/on_boarding_data.dart';
import 'package:hotelyn/features/onboarding/on_boarding_cubit.dart';
import 'package:hotelyn/features/onboarding/on_boarding_state.dart';
import 'package:hotelyn/features/onboarding/on_boarding_welcome_page.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key, this.onBoardingCubit});

  static const route = '/on_boarding';

  @visibleForTesting
  final OnBoardingCubit? onBoardingCubit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => onBoardingCubit ?? OnBoardingCubit(),
        child: BlocBuilder<OnBoardingCubit, OnBoardingState>(
          builder: (context, state) {
            final cubit = context.watch<OnBoardingCubit>();
            final controller = PageController();
            return Column(
              children: [
                Expanded(
                  flex: 8,
                  child: PageView.builder(
                    controller: controller,
                    onPageChanged: (value) =>
                        cubit.updateCurrentPosition(value),
                    itemCount: state.data.length,
                    itemBuilder: (context, index) => OnBoardingItem(
                      data: state.data[index],
                    ),
                  ),
                ),
                GroupDotIndicator(
                  length: state.data.length,
                  selectedIndex: state.currentPosition,
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HotelynButton(
                          onPressed: () {
                            controller.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInCubic,
                            );
                          },
                          message: cubit.state.primaryButtonMessage,
                        ),
                        const SizedBox(height: 16),
                        HotelynButton.secondary(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              OnBoardingWelcomePage.route,
                            );
                          },
                          message: 'Skip',
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class OnBoardingItem extends StatelessWidget {
  const OnBoardingItem({
    super.key,
    required this.data,
  });

  final OnBoardingItemData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          data.imagePath,
          height: MediaQuery.of(context).size.height * 0.55,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                data.title,
                style: HotelynTextStyle.h1,
              ),
              const SizedBox(height: 12),
              Text(
                data.description,
                style: HotelynTextStyle.description,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
