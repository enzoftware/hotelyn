import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/core/domain/repository/onboarding_repository.dart';
import 'package:hotelyn/features/splash/bloc/splash_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('SplashBloc', () {
    late OnBoardingRepository onBoardingRepository;
    late SplashBloc bloc;

    setUp(() {
      onBoardingRepository = MockPreferenceRepository();

      bloc = SplashBloc(onBoardingRepository: onBoardingRepository);
    });

    blocTest<SplashBloc, SplashState>(
      'emits [SplashToOnBoarding] when StartSplash is added and is first time',
      build: () => bloc,
      setUp: () {
        when(() => onBoardingRepository.isOnBoardingPassed())
            .thenAnswer((_) async => false);
      },
      act: (bloc) => bloc.add(const SplashStarted()),
      expect: () => <SplashState>[
        SplashToOnBoarding(),
      ],
    );
    blocTest<SplashBloc, SplashState>(
      'emits [SplashToHome] when StartSplash is added and is not first time',
      build: () => bloc,
      setUp: () {
        when(() => onBoardingRepository.isOnBoardingPassed())
            .thenAnswer((_) async => true);
      },
      act: (bloc) => bloc.add(const SplashStarted()),
      expect: () => <SplashState>[
        SplashToHome(),
      ],
    );
  });
}
