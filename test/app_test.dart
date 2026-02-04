import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/app/view/app.dart';
import 'package:hotelyn/core/domain/repository/intro_repository.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/helpers.dart';

void main() {
  group('HotelynApp', () {
    late IntroRepository preferenceRepository;
    late ClarityService clarityService;

    setUp(() {
      preferenceRepository = MockPreferenceRepository();
      clarityService = MockClarityService();

      when(() => preferenceRepository.isIntroPassed())
          .thenAnswer((_) async => true);
    });

    testWidgets('App launches successfully', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: HotelynApp(
              preferenceRepository: preferenceRepository,
              clarityService: clarityService,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(HotelynApp), findsOneWidget);
      });
    });
  });
}
