import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/app.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HotelynApp());
  });
}
