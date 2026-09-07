import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:california_ui/california_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/components/dot_indicator.dart';
import 'package:hotelyn/core/domain/repository/intro_repository.dart';
import 'package:hotelyn/features/intro/intro.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

class _TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final file = File(key);
    if (file.existsSync()) {
      final bytes = file.readAsBytesSync();
      return ByteData.view(bytes.buffer);
    }
    final appFile = File('apps/hotelyn_app/$key');
    if (appFile.existsSync()) {
      final bytes = appFile.readAsBytesSync();
      return ByteData.view(bytes.buffer);
    }
    return rootBundle.load(key);
  }
}

class MockIntroBloc extends MockBloc<IntroEvent, IntroState>
    implements IntroBloc {}

void main() {
  group('IntroPage', () {
    late IntroRepository introRepository;

    setUp(() {
      introRepository = MockPreferenceRepository();
      when(() => introRepository.setIntroPassed()).thenReturn(null);
    });

    Widget buildSubject() {
      return RepositoryProvider.value(
        value: introRepository,
        child: DefaultAssetBundle(
          bundle: _TestAssetBundle(),
          child: const IntroPage(),
        ),
      );
    }

    testWidgets('renders IntroView and first carousel page', (tester) async {
      await tester.pumpApp(buildSubject());

      expect(find.byType(IntroView), findsOneWidget);
      expect(find.byType(IntroCarouselPage), findsOneWidget);
      expect(find.text('Find Hundreds of Hotels'), findsOneWidget);
      expect(
        find.text(
          'Discover hundreds of hotels that spread across the world for you',
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(CaliforniaButton, 'Continue'), findsOneWidget);
      expect(find.widgetWithText(CaliforniaButton, 'Skip'), findsOneWidget);
      expect(find.byType(GroupDotIndicator), findsOneWidget);
    });

    testWidgets(
      'advances through carousel steps with Continue and shows Get Started on '
      'last step',
      (tester) async {
        await tester.pumpApp(buildSubject());

        // Step 1
        expect(find.text('Find Hundreds of Hotels'), findsOneWidget);
        expect(
          find.widgetWithText(CaliforniaButton, 'Continue'),
          findsOneWidget,
        );

        // Tap Continue -> Step 2
        await tester.tap(find.widgetWithText(CaliforniaButton, 'Continue'));
        await tester.pumpAndSettle();

        expect(find.text('Make a Destination Plan'), findsOneWidget);
        expect(
          find.text(
            'Choose the location and we have many hotel recommendations '
            'wherever you are',
          ),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(CaliforniaButton, 'Continue'),
          findsOneWidget,
        );

        // Tap Continue -> Step 3
        await tester.tap(find.widgetWithText(CaliforniaButton, 'Continue'));
        await tester.pumpAndSettle();

        expect(find.text('Let’s Discover the World'), findsOneWidget);
        expect(
          find.text(
            'Book your hotel right now for the next level travel.\n'
            'Enjoy your trip!',
          ),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(CaliforniaButton, 'Get Started'),
          findsOneWidget,
        );

        // Tap Get Started -> Navigates to Welcome
        await tester.tap(find.widgetWithText(CaliforniaButton, 'Get Started'));
        await tester.pumpAndSettle();

        expect(find.byType(IntroWelcomePage), findsOneWidget);
        expect(find.text('Welcome to Hotelyn'), findsOneWidget);
      },
    );

    testWidgets('tapping Skip navigates directly to IntroWelcomePage', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject());

      final skipButton = find.widgetWithText(CaliforniaButton, 'Skip');
      expect(skipButton, findsOneWidget);

      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      expect(find.byType(IntroWelcomePage), findsOneWidget);
      expect(find.text('Welcome to Hotelyn'), findsOneWidget);
    });
  });

  group('IntroView', () {
    late IntroBloc introBloc;
    late IntroRepository introRepository;

    setUp(() {
      introBloc = MockIntroBloc();
      introRepository = MockPreferenceRepository();
      when(() => introRepository.setIntroPassed()).thenReturn(null);
    });

    Widget buildSubject(IntroState state) {
      when(() => introBloc.state).thenReturn(state);
      whenListen(
        introBloc,
        Stream.fromIterable([state]),
        initialState: state,
      );

      return RepositoryProvider.value(
        value: introRepository,
        child: DefaultAssetBundle(
          bundle: _TestAssetBundle(),
          child: BlocProvider.value(
            value: introBloc,
            child: const IntroView(),
          ),
        ),
      );
    }

    testWidgets('renders IntroCarouselPage when state is IntroCarousel', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject(const IntroCarousel()));

      expect(find.byType(IntroCarouselPage), findsOneWidget);
      expect(find.byType(IntroWelcomePage), findsNothing);
    });

    testWidgets('renders IntroWelcomePage when state is IntroWelcome', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject(const IntroWelcome()));

      expect(find.byType(IntroWelcomePage), findsOneWidget);
      expect(find.byType(IntroCarouselPage), findsNothing);
    });
  });
}
