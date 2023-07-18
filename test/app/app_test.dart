import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/app/view/app.dart';

import '../helpers/helpers.dart';

void main() {
  testWidgets(
    'HotelynApp pumps up',
    (WidgetTester tester) => tester.pumpApp(const HotelynApp()),
  );
}
