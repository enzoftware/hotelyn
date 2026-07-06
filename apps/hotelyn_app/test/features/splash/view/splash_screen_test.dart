import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/splash/splash.dart';

/// Mock for SplashBloc to be used in future tests
// ignore: unreachable_from_main
class MockSplashBloc extends MockBloc<SplashEvent, SplashState>
    implements SplashBloc {}

void main() {
  group('SplashScreen', () {});
}
