import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar_cubit.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar_state.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
import 'package:mocktail/mocktail.dart';

class MockClarityService extends Mock implements ClarityService {}

void main() {
  group('NavigationBarCubit', () {
    late ClarityService clarityService;
    late NavigationBarCubit cubit;

    setUp(() {
      clarityService = MockClarityService();
      cubit = NavigationBarCubit(clarityService: clarityService);
    });

    test('initial state is NavigationBarState with index 0', () {
      expect(cubit.state, const NavigationBarState(selectedTabIndex: 0));
    });

    test('calls setCurrentScreenName with "home" on initialization', () {
      verify(() => clarityService.setCurrentScreenName('home')).called(1);
    });

    blocTest<NavigationBarCubit, NavigationBarState>(
      'emits correct state and calls Clarity when updateSelectedIndex '
      'is called',
      build: () => cubit,
      act: (cubit) => cubit.updateSelectedIndex(1),
      verify: (_) {
        verify(() => clarityService.setCurrentScreenName('search')).called(1);
      },
      expect: () => [
        const NavigationBarState(selectedTabIndex: 1),
      ],
    );
  });
}
