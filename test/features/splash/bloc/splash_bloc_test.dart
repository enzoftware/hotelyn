import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/core/domain/repository/auth_repository.dart';
import 'package:hotelyn/core/domain/repository/intro_repository.dart';
import 'package:hotelyn/features/splash/bloc/splash_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('SplashBloc', () {
    late IntroRepository introRepository;
    late AuthRepository authRepository;
    late SplashBloc bloc;

    setUp(() {
      introRepository = MockPreferenceRepository();
      authRepository = MockAuthRepository();

      bloc = SplashBloc(
        introRepository: introRepository,
        authRepository: authRepository,
      );
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
      'emits [SplashToLogin] when intro passed but not authenticated',
      build: () => bloc,
      setUp: () {
        when(() => introRepository.isIntroPassed())
            .thenAnswer((_) async => true);
        when(() => authRepository.isAuthenticated).thenReturn(false);
      },
      act: (bloc) => bloc.add(const SplashStarted()),
      expect: () => <SplashState>[
        SplashToLogin(),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'emits [SplashToHome] when intro passed and authenticated',
      build: () => bloc,
      setUp: () {
        when(() => introRepository.isIntroPassed())
            .thenAnswer((_) async => true);
        when(() => authRepository.isAuthenticated).thenReturn(true);
        when(() => authRepository.initializeClarityUser()).thenReturn(null);
      },
      act: (bloc) => bloc.add(const SplashStarted()),
      expect: () => <SplashState>[
        SplashToHome(),
      ],
    );
  });
}
