import 'package:bloc_test/bloc_test.dart';
import 'package:california_ui/california_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/home/cubit/nearby_hotels_cubit.dart';
import 'package:hotelyn/features/home/widgets/nearby_hotels_section.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;
import 'package:mocktail/mocktail.dart';

class _MockNearbyHotelsCubit extends MockCubit<NearbyHotelsState>
    implements NearbyHotelsCubit {}

class _MockLocationCubit extends MockCubit<LocationState>
    implements LocationCubit {}

void main() {
  late _MockNearbyHotelsCubit mockNearbyCubit;
  late _MockLocationCubit mockLocationCubit;

  setUp(() {
    mockNearbyCubit = _MockNearbyHotelsCubit();
    mockLocationCubit = _MockLocationCubit();

    when(() => mockLocationCubit.state).thenReturn(
      const LocationState(
        permissionStatus: LocationPermissionStatus.granted,
        userLocation: UserLocation(
          latitude: -7.4243,
          longitude: 109.2391,
          cityName: 'Purwokerto, Indonesia',
        ),
      ),
    );
  });

  Widget buildSubject({VoidCallback? onSeeAllTap}) {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<LocationCubit>.value(value: mockLocationCubit),
            BlocProvider<NearbyHotelsCubit>.value(value: mockNearbyCubit),
          ],
          child: CustomScrollView(
            slivers: [
              NearbyHotelsSection(onSeeAllTap: onSeeAllTap),
            ],
          ),
        ),
      ),
    );
  }

  group('NearbyHotelsSection', () {
    testWidgets('renders section title and See All action', (tester) async {
      when(() => mockNearbyCubit.state).thenReturn(
        const NearbyHotelsInitial(),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Nearby Hotels'), findsOneWidget);
      expect(find.text('See All'), findsOneWidget);
    });

    testWidgets('invokes onSeeAllTap callback when tapped', (tester) async {
      var tapped = false;
      when(() => mockNearbyCubit.state).thenReturn(
        const NearbyHotelsInitial(),
      );

      await tester.pumpWidget(buildSubject(onSeeAllTap: () => tapped = true));
      await tester.tap(find.text('See All'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('See All action is disabled when onSeeAllTap is null', (
      tester,
    ) async {
      when(() => mockNearbyCubit.state).thenReturn(
        const NearbyHotelsInitial(),
      );

      await tester.pumpWidget(buildSubject());

      final textButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'See All'),
      );
      expect(textButton.onPressed, isNull);
    });

    testWidgets('renders shimmer placeholders when loading', (tester) async {
      when(() => mockNearbyCubit.state).thenReturn(
        const NearbyHotelsLoading(),
      );

      await tester.pumpWidget(buildSubject());

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).borderRadius ==
                  BorderRadius.circular(15),
        ),
        findsNWidgets(3),
      );
    });

    testWidgets('renders small product cards with distance when loaded', (
      tester,
    ) async {
      when(() => mockNearbyCubit.state).thenReturn(
        const NearbyHotelsLoaded(
          hotels: [
            domain.Hotel(
              id: 'n1',
              name: 'Serene Sanctuary',
              city: 'Purwokerto',
              country: 'Indonesia',
              distanceKm: 3.2,
            ),
          ],
        ),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Serene Sanctuary'), findsOneWidget);
      expect(find.text('3.2 km · Purwokerto, Indonesia'), findsOneWidget);
      expect(find.byType(CaliforniaProductCard), findsOneWidget);
    });

    testWidgets('renders empty placeholder with location change option', (
      tester,
    ) async {
      when(() => mockNearbyCubit.state).thenReturn(
        const NearbyHotelsLoaded(hotels: []),
      );

      await tester.pumpWidget(buildSubject());

      expect(
        find.text('No nearby hotels found in this area.'),
        findsOneWidget,
      );
      expect(find.text('Change Location'), findsOneWidget);
    });

    testWidgets('renders error card with retry and location change buttons', (
      tester,
    ) async {
      when(() => mockNearbyCubit.state).thenReturn(
        const NearbyHotelsFailure(message: 'Connection timed out'),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Could not load nearby hotels'), findsOneWidget);
      expect(find.text('Connection timed out'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Choose Location'), findsOneWidget);
    });
  });
}
