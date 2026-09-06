import 'package:california_ui/california_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/components.dart';
import 'package:hotelyn/features/intro/intro.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  static const route = '/intro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CaliforniaColors.surfacePrimary,
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
    final state = context.select<IntroBloc, IntroState>((bloc) => bloc.state);

    return switch (state) {
      IntroCarousel() => const IntroCarouselPage(),
      IntroWelcome() => const IntroWelcomePage(),
    };
  }
}

class IntroCarouselPage extends StatefulWidget {
  const IntroCarouselPage({super.key});

  @override
  State<IntroCarouselPage> createState() => _IntroCarouselPageState();
}

class _IntroCarouselPageState extends State<IntroCarouselPage> {
  late final PageController _controller;

  static const _introPagers = [
    IntroItemData(
      title: 'Find Hundreds of Hotels',
      description:
          'Discover hundreds of hotels that spread across the world for you',
      imagePath: '$rootPath/ob1.png',
    ),
    IntroItemData(
      title: 'Make a Destination Plan',
      description: 'Choose the location and we have many hotel recommendations '
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

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.select<IntroBloc, IntroState>((bloc) => bloc.state)
        as IntroCarousel;

    return Column(
      children: [
        Expanded(
          flex: 8,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (position) {
              context.read<IntroBloc>().add(
                    IntroPageChanged(
                      position: position,
                      isLastItem: position == _introPagers.length - 1,
                    ),
                  );
            },
            itemCount: _introPagers.length,
            itemBuilder: (context, index) {
              final item = _introPagers[index];
              return IntroItem(data: item);
            },
          ),
        ),
        GroupDotIndicator(
          length: _introPagers.length,
          selectedIndex: state.currentPosition,
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IntroPrimaryButton(controller: _controller),
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
    return CaliforniaButton.ghost(
      onPressed: () {
        context.read<IntroBloc>().add(const IntroGoToWelcome());
      },
      label: 'Skip',
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
    final state = context.select<IntroBloc, IntroState>((bloc) => bloc.state)
        as IntroCarousel;
    final message = state.isLastItem ? 'Get Started' : 'Continue';
    return CaliforniaButton.primary(
      onPressed: () {
        if (state.isLastItem) {
          context.read<IntroBloc>().add(const IntroGoToWelcome());
        } else {
          if (controller.hasClients) {
            controller.nextPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInCubic,
            );
          }
        }
      },
      label: message,
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
        Expanded(
          child: Image.asset(
            data.imagePath,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
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
                style: CaliforniaTypography.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                data.description,
                style: CaliforniaTypography.p14Regular.copyWith(
                  color: CaliforniaColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class IntroItemData {
  const IntroItemData({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  final String title;
  final String description;
  final String imagePath;
}

const rootPath = 'assets/images/intro';
