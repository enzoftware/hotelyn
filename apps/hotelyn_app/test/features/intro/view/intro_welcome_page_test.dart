import 'dart:io';

import 'package:california_ui/california_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelyn/components/icons/hotelyn_icon.dart';
import 'package:hotelyn/core/domain/repository/intro_repository.dart';
import 'package:hotelyn/features/home/home.dart';
import 'package:hotelyn/features/intro/view/intro_welcome_page.dart';
import 'package:hotelyn/features/login/view/login_page.dart';
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

void main() {
  group('IntroWelcomePage', () {
    late IntroRepository introRepository;

    setUp(() {
      introRepository = MockPreferenceRepository();
      when(() => introRepository.setIntroPassed()).thenReturn(null);
    });

    Widget buildSubject() {
      final testRouter = GoRouter(
        initialLocation: IntroWelcomePage.route,
        routes: [
          GoRoute(
            path: IntroWelcomePage.route,
            builder: (context, state) => const IntroWelcomePage(),
          ),
          GoRoute(
            path: LoginPage.route,
            builder: (context, state) =>
                const Scaffold(body: Text('Login Page')),
          ),
          GoRoute(
            path: HomePage.route,
            builder: (context, state) =>
                const Scaffold(body: Text('Home Page')),
          ),
        ],
      );

      return RepositoryProvider.value(
        value: introRepository,
        child: DefaultAssetBundle(
          bundle: _TestAssetBundle(),
          child: MaterialApp.router(
            routerConfig: testRouter,
          ),
        ),
      );
    }

    testWidgets('renders all UI components correctly', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(HotelynIcon), findsOneWidget);
      expect(find.text('Welcome to Hotelyn'), findsOneWidget);
      expect(
        find.text(
          'If you are new here please create your account first before '
          'book the hotel.',
        ),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(CaliforniaButton, 'Create Account / Login'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(CaliforniaButton, 'Go To Homepage'),
        findsOneWidget,
      );
    });

    testWidgets(
      'tapping "Create Account / Login" calls setIntroPassed '
      'and navigates to LoginPage',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        final button = find.widgetWithText(
          CaliforniaButton,
          'Create Account / Login',
        );
        expect(button, findsOneWidget);

        await tester.tap(button);
        await tester.pumpAndSettle();

        verify(() => introRepository.setIntroPassed()).called(1);
        expect(find.text('Login Page'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping "Go To Homepage" calls setIntroPassed '
      'and navigates to HomePage',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        final button = find.widgetWithText(CaliforniaButton, 'Go To Homepage');
        expect(button, findsOneWidget);

        await tester.tap(button);
        await tester.pumpAndSettle();

        verify(() => introRepository.setIntroPassed()).called(1);
        expect(find.text('Home Page'), findsOneWidget);
      },
    );
  });
}
