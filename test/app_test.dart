import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/app.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await binding.setSurfaceSize(const Size(600, 800));
    await tester.pumpWidget(const HotelynApp());
  });
}
