import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar_cubit.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar_state.dart';
import 'package:hotelyn/components/text_input/hotelyn_search_input.dart';
import 'package:hotelyn/features/home/widgets/home_header.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

class MockNavCubit extends Mock implements NavigationBarCubit {}

void main() {
  group('HomeHeader', () {
    late LocationCubit locationCubit;
    late NavigationBarCubit navigationBarCubit;

    setUp(() {
      locationCubit = MockLocationCubit();
      navigationBarCubit = MockNavCubit();
      when(() => locationCubit.state).thenReturn(
        const LocationState(
          userLocation: UserLocation(
            latitude: -7.4244,
            longitude: 109.2304,
            cityName: 'Purwokerto, Indonesia',
          ),
        ),
      );
      when(() => navigationBarCubit.state).thenReturn(
        const NavigationBarState(selectedTabIndex: 0),
      );
      when(() => navigationBarCubit.stream).thenAnswer(
        (_) => Stream.value(const NavigationBarState(selectedTabIndex: 0)),
      );
    });

    Widget buildSubject({
      String userName = 'Katherine',
      VoidCallback? onNotificationTap,
      VoidCallback? onSearchTap,
      VoidCallback? onLocationTap,
      VoidCallback? onFilterTap,
      bool overlapsContent = false,
    }) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<LocationCubit>.value(value: locationCubit),
          BlocProvider<NavigationBarCubit>.value(value: navigationBarCubit),
        ],
        child: Scaffold(
          body: SingleChildScrollView(
            child: HomeHeader(
              userName: userName,
              onNotificationTap: onNotificationTap,
              onSearchTap: onSearchTap,
              onLocationTap: onLocationTap,
              onFilterTap: onFilterTap,
              overlapsContent: overlapsContent,
            ),
          ),
        ),
      );
    }

    testWidgets('renders default user greeting and subtitle', (tester) async {
      await tester.pumpApp(buildSubject());

      expect(find.text('Hello, Katherine! 👋'), findsOneWidget);
      expect(find.text("Let's find best hotel"), findsOneWidget);
    });

    testWidgets('renders custom user greeting when provided', (tester) async {
      await tester.pumpApp(buildSubject(userName: 'Alex'));

      expect(find.text('Hello, Alex! 👋'), findsOneWidget);
    });

    testWidgets('renders LocationCard with city name from LocationCubit', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject());

      expect(find.byType(LocationCard), findsOneWidget);
      expect(find.text('Purwokerto, Indonesia'), findsOneWidget);
      expect(find.byIcon(Icons.place_outlined), findsOneWidget);
    });

    testWidgets('tapping LocationCard triggers custom onLocationTap', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpApp(
        buildSubject(onLocationTap: () => tapped = true),
      );

      await tester.tap(find.byType(LocationCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders NotificationCard with badge and bell icon', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject());

      expect(find.byType(NotificationCard), findsOneWidget);
      expect(find.byType(Badge), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('tapping NotificationCard triggers custom onNotificationTap', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpApp(
        buildSubject(onNotificationTap: () => tapped = true),
      );

      await tester.tap(find.byType(NotificationCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders HotelynSearchInput when overlapsContent is false', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject());

      expect(find.byType(HotelynSearchInput), findsOneWidget);
      expect(find.text('Search hotel'), findsOneWidget);
    });

    testWidgets('hides HotelynSearchInput when overlapsContent is true', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject(overlapsContent: true));

      expect(find.byType(HotelynSearchInput), findsNothing);
    });

    testWidgets('tapping search input invokes custom onSearchTap', (
      tester,
    ) async {
      var searchTapped = false;
      await tester.pumpApp(
        buildSubject(onSearchTap: () => searchTapped = true),
      );

      await tester.tap(find.byType(HotelynSearchInput));
      await tester.pumpAndSettle();

      expect(searchTapped, isTrue);
    });

    testWidgets(
      'tapping search input switches NavigationBarCubit to search tab '
      '(index 1) by default',
      (
        tester,
      ) async {
        when(() => navigationBarCubit.updateSelectedIndex(1)).thenReturn(null);

        await tester.pumpApp(buildSubject());

        await tester.tap(find.byType(HotelynSearchInput));
        await tester.pumpAndSettle();

        verify(() => navigationBarCubit.updateSelectedIndex(1)).called(1);
      },
    );

    testWidgets('tapping filter button in search input invokes onFilterTap', (
      tester,
    ) async {
      var filterTapped = false;
      await tester.pumpApp(
        buildSubject(onFilterTap: () => filterTapped = true),
      );

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(filterTapped, isTrue);
    });

    test('HotelynHeader delegate properties and rebuild', () {
      final delegate = HotelynHeader(userName: 'Maria');
      expect(delegate.maxExtent, 250.0);
      expect(delegate.minExtent, 240.0);
      expect(delegate.shouldRebuild(HotelynHeader(userName: 'Maria')), isFalse);
      expect(delegate.shouldRebuild(HotelynHeader(userName: 'Alex')), isTrue);
    });
  });
}
