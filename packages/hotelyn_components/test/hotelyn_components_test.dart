import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn_components/colors/colors.dart';

void main() {
  test('boilerplate test', () {
    final color = HColorsPrimary.white;
    expect(color.value, 0XFFFFFFFF);
  });
}
