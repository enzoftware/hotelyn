import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar_cubit.dart';
import 'package:hotelyn/components/text_input/hotelyn_search_input.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
import 'package:hotelyn/features/filter/filter.dart';
import 'package:hotelyn/features/home/home.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:hotelyn/features/messages/messages_cubit.dart';
import 'package:hotelyn/features/messages/messages_tab.dart';
import 'package:hotelyn/features/profile/profile_cubit.dart';
import 'package:hotelyn/features/profile/profile_tab.dart';
import 'package:hotelyn/features/search/recent_search/cubit/search_cubit.dart';
import 'package:hotelyn/features/search/recent_search/recent_search_tab.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('HomePage', () {
    late ClarityService clarityService;
    late LocationCubit locationCubit;
    late NavigationBarCubit navigationBarCubit;

    setUp(() {
      clarityService = MockClarityService();
      locationCubit = MockLocationCubit();
      navigationBarCubit = NavigationBarCubit(clarityService: clarityService);

      when(() => locationCubit.state).thenReturn(
        const LocationState(
          userLocation: UserLocation(
            latitude: -7.4244,
            longitude: 109.2304,
            cityName: 'Purwokerto, Indonesia',
          ),
        ),
      );
      when(() => locationCubit.stream).thenAnswer(
        (_) => Stream.value(
          const LocationState(
            userLocation: UserLocation(
              latitude: -7.4244,
              longitude: 109.2304,
              cityName: 'Purwokerto, Indonesia',
            ),
          ),
        ),
      );
    });

    Widget buildSubject({
      NavigationBarCubit? navCubit,
      ProfileCubit? profileCubit,
      MessagesCubit? messagesCubit,
      SearchCubit? searchCubit,
    }) {
      return RepositoryProvider<ClarityService>.value(
        value: clarityService,
        child: BlocProvider<LocationCubit>.value(
          value: locationCubit,
          child: HomePage(
            navigationBarCubit: navCubit ?? navigationBarCubit,
            profileCubit: profileCubit,
            messagesCubit: messagesCubit,
            searchCubit: searchCubit,
          ),
        ),
      );
    }

    testWidgets('renders HomeView, Scaffold, and HotelynNavigationBar', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject());

      expect(find.byType(HomeView), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(HotelynNavigationBar), findsOneWidget);
      expect(find.byType(HomeTab), findsOneWidget);
    });

    testWidgets('navigation bar displays all 4 top-level destinations', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject());

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('tapping Search tab switches to RecentSearchTab', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject());

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(navigationBarCubit.state.selectedTabIndex, 1);
      expect(find.byType(RecentSearchTab), findsOneWidget);
    });

    testWidgets('tapping Messages tab switches to MessagesTab', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject());

      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();

      expect(navigationBarCubit.state.selectedTabIndex, 2);
      expect(find.byType(MessagesTab), findsOneWidget);
    });

    testWidgets('tapping Profile tab switches to ProfileTab', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject());

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(navigationBarCubit.state.selectedTabIndex, 3);
      expect(find.byType(ProfileTab), findsOneWidget);
    });

    testWidgets('tapping search quick-entry bar switches to Search tab', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject());

      expect(find.byType(HotelynSearchInput), findsOneWidget);
      await tester.tap(find.byType(HotelynSearchInput));
      await tester.pumpAndSettle();

      expect(navigationBarCubit.state.selectedTabIndex, 1);
    });

    group('back navigation behavior', () {
      testWidgets(
        'back button on Search tab switches safely back to Home tab '
        '(index 0)',
        (tester) async {
          await tester.pumpApp(buildSubject());

          // Switch to Search tab
          await tester.tap(find.text('Search'));
          await tester.pumpAndSettle();
          expect(navigationBarCubit.state.selectedTabIndex, 1);

          // Trigger back navigation
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          // Safely back to Home tab
          expect(navigationBarCubit.state.selectedTabIndex, 0);
        },
      );

      testWidgets(
        'back button on Messages tab switches safely back to Home tab '
        '(index 0)',
        (tester) async {
          await tester.pumpApp(buildSubject());

          // Switch to Messages tab
          await tester.tap(find.text('Messages'));
          await tester.pumpAndSettle();
          expect(navigationBarCubit.state.selectedTabIndex, 2);

          // Trigger back navigation
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          // Safely back to Home tab
          expect(navigationBarCubit.state.selectedTabIndex, 0);
        },
      );

      testWidgets(
        'back button on Profile tab switches safely back to Home tab '
        '(index 0)',
        (tester) async {
          await tester.pumpApp(buildSubject());

          // Switch to Profile tab
          await tester.tap(find.text('Profile'));
          await tester.pumpAndSettle();
          expect(navigationBarCubit.state.selectedTabIndex, 3);

          // Trigger back navigation
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          // Safely back to Home tab
          expect(navigationBarCubit.state.selectedTabIndex, 0);
        },
      );

      testWidgets(
        'PopScope allows pop when already on Home tab (index 0)',
        (tester) async {
          await tester.pumpApp(buildSubject());

          expect(navigationBarCubit.state.selectedTabIndex, 0);

          final popScope = tester.widget(
            find.byWidgetPredicate((w) => w is PopScope),
          ) as PopScope;
          expect(popScope.canPop, isTrue);
        },
      );

      testWidgets(
        'PopScope denies pop when on non-home tab',
        (tester) async {
          await tester.pumpApp(buildSubject());

          await tester.tap(find.text('Search'));
          await tester.pumpAndSettle();

          final popScope = tester.widget(
            find.byWidgetPredicate((w) => w is PopScope),
          ) as PopScope;
          expect(popScope.canPop, isFalse);
        },
      );
    });
    testWidgets(
      'tapping filter button in HomeTab opens HotelFilterBottomSheet',
      (tester) async {
        await tester.pumpApp(buildSubject());

        await tester.tap(find.byIcon(Icons.tune));
        await tester.pumpAndSettle();

        expect(find.byType(HotelFilterBottomSheet), findsOneWidget);
        expect(find.text('Filter'), findsWidgets);
        expect(find.text('Available Now'), findsOneWidget);
      },
    );
  });
}
