import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/app/view/app.dart';
import 'package:hotelyn/core/domain/repository/auth_repository.dart';
import 'package:hotelyn/core/domain/repository/intro_repository.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/helpers.dart';

void main() {
  group('HotelynApp', () {
    late IntroRepository preferenceRepository;
    late AuthRepository authRepository;
    late ClarityService clarityService;
    late LocationRepository locationRepository;

    setUp(() {
      preferenceRepository = MockPreferenceRepository();
      authRepository = MockAuthRepository();
      clarityService = MockClarityService();
      locationRepository = MockLocationRepository();

      when(() => preferenceRepository.isIntroPassed())
          .thenAnswer((_) async => false);
      when(() => authRepository.isAuthenticated).thenReturn(false);
      when(() => locationRepository.getLocation())
          .thenAnswer((_) async => UserLocation.defaultFallback);
      when(() => locationRepository.getPermissionStatus())
          .thenAnswer((_) async => LocationPermissionStatus.unknown);
    });

    testWidgets(
      'App launches successfully',
      (tester) async {
        await tester.pumpWidget(
          HotelynApp(
            preferenceRepository: preferenceRepository,
            authRepository: authRepository,
            clarityService: clarityService,
            locationRepository: locationRepository,
          ),
        );
        // Just verify the widget tree is built without navigating
        expect(find.byType(HotelynApp), findsOneWidget);
      },
    );
  });
}
