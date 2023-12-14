import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/onboarding/data/on_boarding_data.dart';
import 'package:hotelyn/features/onboarding/on_boarding_cubit.dart';
import 'package:hotelyn/features/onboarding/on_boarding_state.dart';

void main() {
  group('OnBoardingCubit', () {
    test('intial constructor', () {
      final cubit = OnBoardingCubit();
      expect(
        cubit.state,
        OnBoardingState(
          currentPosition: 0,
          primaryButtonMessage: 'Continue',
          data: onBoardingData,
        ),
      );
    });

    test('updateCurrentPosition, increase position in one', () {
      final cubit = OnBoardingCubit();

      expect(cubit.state.currentPosition, 0);
      cubit.updateCurrentPosition(1);
      expect(cubit.state.currentPosition, 1);
      expect(cubit.state.primaryButtonMessage, 'Continue');
    });

    test('updateCurrentPosition, increase position to the last position', () {
      final cubit = OnBoardingCubit();
      final dataLength = cubit.state.data.length;

      expect(cubit.state.currentPosition, 0);
      cubit.updateCurrentPosition(dataLength - 1);
      expect(cubit.state.currentPosition, dataLength - 1);
      expect(cubit.state.primaryButtonMessage, 'Get Started');
    });
  });
}
