import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/components.dart';
import 'package:hotelyn/components/hotelyn_button.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/features/on_boarding/on_boarding.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  static const route = '/on_boarding';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => OnBoardingBloc(),
        child: const OnBoardingView(),
      ),
    );
  }
}

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.select((OnBoardingBloc bloc) => bloc.state);

    return switch (state) {
      OnBoardingIntro() => const OnBoardingIntroPage(),
      OnBoardingWelcome() => const OnBoardingWelcomePage(),
    };
  }
}

class OnBoardingIntroPage extends StatelessWidget {
  const OnBoardingIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PageController();
    final introPagers = [
      OnBoardingItemData(
        title: 'Find Hundreds of Hotels',
        description:
            'Discover hundreds of hotels that spread across the world for you',
        imagePath: '$rootPath/ob1.png',
      ),
      OnBoardingItemData(
        title: 'Make a Destination Plan',
        description:
            'Choose the location and we have many hotel recommendations '
            'wherever you are',
        imagePath: '$rootPath/ob2.png',
      ),
      OnBoardingItemData(
        title: 'Let’s Discover the World',
        description: 'Book your hotel right now for the next level travel.'
            '\nEnjoy your trip!',
        imagePath: '$rootPath/ob3.png',
      ),
    ];

    final state =
        context.select((OnBoardingBloc bloc) => bloc.state) as OnBoardingIntro;

    return Column(
      children: [
        Expanded(
          flex: 8,
          child: PageView.builder(
            controller: controller,
            onPageChanged: (position) {
              context.read<OnBoardingBloc>().add(
                    OnBoardingPageChanged(
                      position: position,
                      isLastItem: position == introPagers.length - 1,
                    ),
                  );
            },
            itemCount: introPagers.length,
            itemBuilder: (context, index) {
              final item = introPagers[index];
              return OnBoardingItem(data: item);
            },
          ),
        ),
        GroupDotIndicator(
          length: introPagers.length,
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
                OnBoardingPrimaryButton(controller: controller),
                const SizedBox(height: 16),
                const OnBoardingSecondaryButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class OnBoardingSecondaryButton extends StatelessWidget {
  const OnBoardingSecondaryButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HotelynButton.secondary(
      onPressed: () {
        context.read<OnBoardingBloc>().add(const OnBoardingGoToWelcome());
      },
      message: 'Skip',
    );
  }
}

class OnBoardingPrimaryButton extends StatelessWidget {
  const OnBoardingPrimaryButton({
    required this.controller,
    super.key,
  });

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    final state =
        context.select((OnBoardingBloc bloc) => bloc.state) as OnBoardingIntro;
    final message = state.isLastItem ? 'Get Started' : 'Continue';
    return HotelynButton(
      onPressed: () {
        if (state.isLastItem) {
          context.read<OnBoardingBloc>().add(const OnBoardingGoToWelcome());
        } else {
          controller.nextPage(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInCubic,
          );
        }
      },
      message: message,
    );
  }
}

class OnBoardingItem extends StatelessWidget {
  const OnBoardingItem({
    required this.data,
    super.key,
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

class OnBoardingItemData {
  OnBoardingItemData({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  final String title;
  final String description;
  final String imagePath;
}

const rootPath = 'assets/images/onboarding';
