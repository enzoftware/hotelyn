import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/core/domain/repository/intro_repository.dart';
import 'package:hotelyn/features/splash/bloc/splash_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('SplashBloc', () {
    late IntroRepository introRepository;
    late SplashBloc bloc;

    setUp(() {
      introRepository = MockPreferenceRepository();

      bloc = SplashBloc(introRepository: introRepository);
    });

    blocTest<SplashBloc, SplashState>(
      'emits [SplashToIntro] when StartSplash is added and is first time',
      build: () => bloc,
      setUp: () {
        when(() => introRepository.isIntroPassed())
            .thenAnswer((_) async => false);
      },
      act: (bloc) => bloc.add(const SplashStarted()),
      expect: () => <SplashState>[
        SplashToIntro(),
      ],
    );
    blocTest<SplashBloc, SplashState>(
      'emits [SplashToHome] when StartSplash is added and is not first time',
      build: () => bloc,
      setUp: () {
        when(() => introRepository.isIntroPassed())
            .thenAnswer((_) async => true);
      },
      act: (bloc) => bloc.add(const SplashStarted()),
      expect: () => <SplashState>[
        SplashToHome(),
      ],
    );
  });
}
