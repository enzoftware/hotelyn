import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/intro/bloc/intro_bloc.dart';

void main() {
  group('IntroBloc', () {
    blocTest<IntroBloc, IntroState>(
      'initial state is IntroCarousel with defaults',
      build: IntroBloc.new,
      verify: (bloc) {
        expect(
          bloc.state,
          equals(const IntroCarousel()),
        );
        expect((bloc.state as IntroCarousel).currentPosition, equals(0));
        expect((bloc.state as IntroCarousel).isLastItem, isFalse);
      },
    );

    blocTest<IntroBloc, IntroState>(
      'emits IntroCarousel with updated position and isLastItem '
      'when IntroPageChanged is added',
      build: IntroBloc.new,
      act: (bloc) => bloc.add(
        const IntroPageChanged(position: 1),
      ),
      expect: () => const <IntroState>[
        IntroCarousel(currentPosition: 1),
      ],
    );

    blocTest<IntroBloc, IntroState>(
      'emits IntroCarousel with isLastItem=true when at last position',
      build: IntroBloc.new,
      act: (bloc) => bloc.add(
        const IntroPageChanged(position: 2, isLastItem: true),
      ),
      expect: () => const <IntroState>[
        IntroCarousel(currentPosition: 2, isLastItem: true),
      ],
    );

    blocTest<IntroBloc, IntroState>(
      'emits IntroWelcome when IntroGoToWelcome is added',
      build: IntroBloc.new,
      act: (bloc) => bloc.add(const IntroGoToWelcome()),
      expect: () => const <IntroState>[
        IntroWelcome(),
      ],
    );
  });

  group('IntroEvent', () {
    test('IntroPageChanged supports value equality', () {
      expect(
        const IntroPageChanged(position: 1),
        equals(const IntroPageChanged(position: 1)),
      );
      expect(
        const IntroPageChanged(position: 1).props,
        equals([1, false]),
      );
    });

    test('IntroGoToWelcome supports value equality', () {
      expect(
        const IntroGoToWelcome(),
        equals(const IntroGoToWelcome()),
      );
      expect(
        const IntroGoToWelcome().props,
        isEmpty,
      );
    });
  });

  group('IntroState', () {
    test('IntroCarousel supports value equality', () {
      expect(
        const IntroCarousel(currentPosition: 1, isLastItem: true),
        equals(const IntroCarousel(currentPosition: 1, isLastItem: true)),
      );
      expect(
        const IntroCarousel(currentPosition: 1, isLastItem: true).props,
        equals([1, true]),
      );
    });

    test('IntroWelcome supports value equality', () {
      expect(
        const IntroWelcome(),
        equals(const IntroWelcome()),
      );
      expect(
        const IntroWelcome().props,
        isEmpty,
      );
    });
  });
}
