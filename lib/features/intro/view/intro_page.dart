import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/components.dart';
import 'package:hotelyn/components/hotelyn_button.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/features/intro/intro.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  static const route = '/intro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => IntroBloc(),
        child: const IntroView(),
      ),
    );
  }
}

class IntroView extends StatelessWidget {
  const IntroView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.select((IntroBloc bloc) => bloc.state);

    return switch (state) {
      IntroCarousel() => const IntroCarouselPage(),
      IntroWelcome() => const IntroWelcomePage(),
    };
  }
}

class IntroCarouselPage extends StatelessWidget {
  const IntroCarouselPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PageController();
    final introPagers = [
      IntroItemData(
        title: 'Find Hundreds of Hotels',
        description:
            'Discover hundreds of hotels that spread across the world for you',
        imagePath: '$rootPath/ob1.png',
      ),
      IntroItemData(
        title: 'Make a Destination Plan',
        description:
            'Choose the location and we have many hotel recommendations '
            'wherever you are',
        imagePath: '$rootPath/ob2.png',
      ),
      IntroItemData(
        title: 'Let’s Discover the World',
        description: 'Book your hotel right now for the next level travel.'
            '\nEnjoy your trip!',
        imagePath: '$rootPath/ob3.png',
      ),
    ];

    final state =
        context.select((IntroBloc bloc) => bloc.state) as IntroCarousel;

    return Column(
      children: [
        Expanded(
          flex: 8,
          child: PageView.builder(
            controller: controller,
            onPageChanged: (position) {
              context.read<IntroBloc>().add(
                    IntroPageChanged(
                      position: position,
                      isLastItem: position == introPagers.length - 1,
                    ),
                  );
            },
            itemCount: introPagers.length,
            itemBuilder: (context, index) {
              final item = introPagers[index];
              return IntroItem(data: item);
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
                IntroPrimaryButton(controller: controller),
                const SizedBox(height: 16),
                const IntroSecondaryButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class IntroSecondaryButton extends StatelessWidget {
  const IntroSecondaryButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HotelynButton.secondary(
      onPressed: () {
        context.read<IntroBloc>().add(const IntroGoToWelcome());
      },
      message: 'Skip',
    );
  }
}

class IntroPrimaryButton extends StatelessWidget {
  const IntroPrimaryButton({
    required this.controller,
    super.key,
  });

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    final state =
        context.select((IntroBloc bloc) => bloc.state) as IntroCarousel;
    final message = state.isLastItem ? 'Get Started' : 'Continue';
    return HotelynButton(
      onPressed: () {
        if (state.isLastItem) {
          context.read<IntroBloc>().add(const IntroGoToWelcome());
        } else {
          unawaited(
            controller.nextPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInCubic,
            ),
          );
        }
      },
      message: message,
    );
  }
}

class IntroItem extends StatelessWidget {
  const IntroItem({
    required this.data,
    super.key,
  });

  final IntroItemData data;

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

class IntroItemData {
  IntroItemData({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  final String title;
  final String description;
  final String imagePath;
}

const rootPath = 'assets/images/intro';
