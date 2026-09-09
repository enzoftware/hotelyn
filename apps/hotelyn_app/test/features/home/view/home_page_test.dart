import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar_cubit.dart';
import 'package:hotelyn/components/text_input/hotelyn_search_input.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
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

class _MockRecommendedHotelsCubit extends MockCubit<RecommendedHotelsState>
    implements RecommendedHotelsCubit {}

class _MockNearbyHotelsCubit extends MockCubit<NearbyHotelsState>
    implements NearbyHotelsCubit {}

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
      RecommendedHotelsCubit? recommendedHotelsCubit,
      NearbyHotelsCubit? nearbyHotelsCubit,
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
            recommendedHotelsCubit: recommendedHotelsCubit,
            nearbyHotelsCubit: nearbyHotelsCubit,
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

    testWidgets(
      'reloads recommended and nearby hotels when LocationCubit coordinates '
      'change',
      (tester) async {
        final locationController = StreamController<LocationState>.broadcast();
        final mockRecCubit = _MockRecommendedHotelsCubit();
        final mockNearbyCubit = _MockNearbyHotelsCubit();

        when(() => mockRecCubit.state).thenReturn(
          const RecommendedHotelsInitial(),
        );
        when(
          () => mockRecCubit.loadRecommendedHotels(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((_) async {});

        when(() => mockNearbyCubit.state).thenReturn(
          const NearbyHotelsInitial(),
        );
        when(
          () => mockNearbyCubit.loadNearbyHotels(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((_) async {});

        when(() => locationCubit.stream).thenAnswer(
          (_) => locationController.stream,
        );

        await tester.pumpApp(
          buildSubject(
            recommendedHotelsCubit: mockRecCubit,
            nearbyHotelsCubit: mockNearbyCubit,
          ),
        );

        locationController.add(
          const LocationState(
            userLocation: UserLocation(
              latitude: -8.4095,
              longitude: 115.1889,
              cityName: 'Bali, Indonesia',
            ),
          ),
        );
        await tester.pump();

        verify(
          () => mockRecCubit.loadRecommendedHotels(
            latitude: -8.4095,
            longitude: 115.1889,
          ),
        ).called(1);

        verify(
          () => mockNearbyCubit.loadNearbyHotels(
            latitude: -8.4095,
            longitude: 115.1889,
          ),
        ).called(1);

        await locationController.close();
      },
    );

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
  });
}
