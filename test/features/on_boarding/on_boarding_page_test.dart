import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/components/buttons/hotelyn_button.dart';
import 'package:hotelyn/features/onboarding/on_boarding_page.dart';

void main() {
  group('OnBoardingPage', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    testWidgets('pump widget', (widgetTester) async {
      await widgetTester.pumpWidget(const OnBoardingPage());
      final primaryButton = find.byType(HotelynButton);
      expect(primaryButton, findsExactly(2));
    });
  });
}
