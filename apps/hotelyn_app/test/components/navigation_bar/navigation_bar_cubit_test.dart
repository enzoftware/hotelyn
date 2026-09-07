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

    blocTest<NavigationBarCubit, NavigationBarState>(
      'emits correct state for all valid tabs',
      build: () => cubit,
      act: (cubit) {
        cubit
          ..updateSelectedIndex(2)
          ..updateSelectedIndex(3)
          ..updateSelectedIndex(0);
      },
      verify: (_) {
        verify(() => clarityService.setCurrentScreenName('messages')).called(1);
        verify(() => clarityService.setCurrentScreenName('profile')).called(1);
        verify(() => clarityService.setCurrentScreenName('home')).called(2);
      },
      expect: () => [
        const NavigationBarState(selectedTabIndex: 2),
        const NavigationBarState(selectedTabIndex: 3),
        const NavigationBarState(selectedTabIndex: 0),
      ],
    );

    blocTest<NavigationBarCubit, NavigationBarState>(
      'ignores out of bounds negative index',
      build: () => cubit,
      act: (cubit) => cubit.updateSelectedIndex(-1),
      expect: () => <NavigationBarState>[],
    );

    blocTest<NavigationBarCubit, NavigationBarState>(
      'ignores out of bounds index >= 4',
      build: () => cubit,
      act: (cubit) => cubit.updateSelectedIndex(4),
      expect: () => <NavigationBarState>[],
    );

    blocTest<NavigationBarCubit, NavigationBarState>(
      'switchToHome emits index 0 and updates screen name',
      build: () => cubit,
      seed: () => const NavigationBarState(selectedTabIndex: 2),
      act: (cubit) => cubit.switchToHome(),
      verify: (_) {
        verify(() => clarityService.setCurrentScreenName('home')).called(2);
      },
      expect: () => [
        const NavigationBarState(selectedTabIndex: 0),
      ],
    );

    blocTest<NavigationBarCubit, NavigationBarState>(
      'switchToSearch emits index 1 and updates screen name',
      build: () => cubit,
      act: (cubit) => cubit.switchToSearch(),
      verify: (_) {
        verify(() => clarityService.setCurrentScreenName('search')).called(1);
      },
      expect: () => [
        const NavigationBarState(selectedTabIndex: 1),
      ],
    );

    blocTest<NavigationBarCubit, NavigationBarState>(
      'switchToMessages emits index 2 and updates screen name',
      build: () => cubit,
      act: (cubit) => cubit.switchToMessages(),
      verify: (_) {
        verify(() => clarityService.setCurrentScreenName('messages')).called(1);
      },
      expect: () => [
        const NavigationBarState(selectedTabIndex: 2),
      ],
    );

    blocTest<NavigationBarCubit, NavigationBarState>(
      'switchToProfile emits index 3 and updates screen name',
      build: () => cubit,
      act: (cubit) => cubit.switchToProfile(),
      verify: (_) {
        verify(() => clarityService.setCurrentScreenName('profile')).called(1);
      },
      expect: () => [
        const NavigationBarState(selectedTabIndex: 3),
      ],
    );
  });
}
