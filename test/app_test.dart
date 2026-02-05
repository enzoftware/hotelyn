import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/app/view/app.dart';
import 'package:hotelyn/core/domain/repository/auth_repository.dart';
import 'package:hotelyn/core/domain/repository/intro_repository.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/helpers.dart';

void main() {
  group('HotelynApp', () {
    late IntroRepository preferenceRepository;
    late AuthRepository authRepository;
    late ClarityService clarityService;

    setUp(() {
      preferenceRepository = MockPreferenceRepository();
      authRepository = MockAuthRepository();
      clarityService = MockClarityService();

      when(() => preferenceRepository.isIntroPassed())
          .thenAnswer((_) async => false);
      when(() => authRepository.isAuthenticated).thenReturn(false);
    });

    testWidgets(
      'App launches successfully',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          HotelynApp(
            preferenceRepository: preferenceRepository,
            authRepository: authRepository,
            clarityService: clarityService,
          ),
        );
        // Just verify the widget tree is built without navigating
        expect(find.byType(HotelynApp), findsOneWidget);
      },
    );
  });
}
