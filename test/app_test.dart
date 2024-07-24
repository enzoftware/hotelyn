import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/app/view/app.dart';
import 'package:hotelyn/core/domain/repository/on_boarding_repository.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/helpers.dart';

void main() {
  group('HotelynApp', () {
    late OnBoardingRepository preferenceRepository;

    setUp(() {
      preferenceRepository = MockPreferenceRepository();
      when(() => preferenceRepository.isOnBoardingPassed())
          .thenAnswer((_) async => true);
    });

    testWidgets('App launches successfully', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: HotelynApp(
              preferenceRepository: preferenceRepository,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(HotelynApp), findsOneWidget);
      });
    });
  });
}
