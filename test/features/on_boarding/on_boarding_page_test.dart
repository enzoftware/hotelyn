import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/components/buttons/hotelyn_button.dart';
import 'package:hotelyn/features/onboarding/on_boarding_cubit.dart';
import 'package:hotelyn/features/onboarding/on_boarding_page.dart';

void main() {
  group('OnBoardingPage', () {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('pump widget', (widgetTester) async {
      // Set surface size to avoid overflow rendering issue on the test
      await binding.setSurfaceSize(const Size(600, 800));
      await widgetTester.pumpWidget(
        MaterialApp(
          home: OnBoardingPage(
            onBoardingCubit: OnBoardingCubit(),
          ),
        ),
      );
      final primaryButton = find.byType(HotelynButton);
      expect(primaryButton, findsExactly(2));
    });
  });
}
