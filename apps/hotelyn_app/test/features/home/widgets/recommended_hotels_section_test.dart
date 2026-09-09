import 'package:bloc_test/bloc_test.dart';
import 'package:california_ui/california_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/home/cubit/recommended_hotels_cubit.dart';
import 'package:hotelyn/features/home/widgets/recommended_hotels_section.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;
import 'package:mocktail/mocktail.dart';

class _MockRecommendedHotelsCubit extends MockCubit<RecommendedHotelsState>
    implements RecommendedHotelsCubit {}

class _MockLocationCubit extends MockCubit<LocationState>
    implements LocationCubit {}

void main() {
  late _MockRecommendedHotelsCubit mockCubit;
  late _MockLocationCubit mockLocationCubit;

  setUp(() {
    mockCubit = _MockRecommendedHotelsCubit();
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

  Widget buildSubject({
    VoidCallback? onSeeAllTap,
    VoidCallback? onRetry,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<LocationCubit>.value(value: mockLocationCubit),
            BlocProvider<RecommendedHotelsCubit>.value(value: mockCubit),
          ],
          child: CustomScrollView(
            slivers: [
              RecommendedHotelsSection(
                onSeeAllTap: onSeeAllTap,
                onRetry: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('RecommendedHotelsSection', () {
    testWidgets('renders section header', (tester) async {
      when(() => mockCubit.state).thenReturn(
        const RecommendedHotelsInitial(),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Recommended Hotel'), findsOneWidget);
      expect(find.text('See All'), findsOneWidget);
    });

    testWidgets('shows loading shimmer on initial/loading state', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        const RecommendedHotelsLoading(),
      );

      await tester.pumpWidget(buildSubject());

      // Shimmer renders 3 grey containers.
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

    testWidgets('shows hotel cards on loaded state', (tester) async {
      when(() => mockCubit.state).thenReturn(
        const RecommendedHotelsLoaded(
          hotels: [
            domain.Hotel(
              id: '1',
              name: 'Test Hotel',
              city: 'Bali',
              country: 'Indonesia',
            ),
          ],
        ),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Test Hotel'), findsOneWidget);
      expect(find.text('Bali, Indonesia'), findsOneWidget);
      expect(find.byType(CaliforniaProductCard), findsOneWidget);
    });

    testWidgets('shows empty placeholder when loaded with no hotels', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        const RecommendedHotelsLoaded(hotels: []),
      );

      await tester.pumpWidget(buildSubject());

      expect(
        find.text('No recommended hotels found nearby.'),
        findsOneWidget,
      );
    });

    testWidgets('shows error card on failure state', (tester) async {
      when(() => mockCubit.state).thenReturn(
        const RecommendedHotelsFailure(message: 'Network error'),
      );

      await tester.pumpWidget(buildSubject());

      expect(
        find.text('Could not load recommended hotels'),
        findsOneWidget,
      );
      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('invokes onSeeAllTap callback when tapped', (tester) async {
      var tapped = false;
      when(() => mockCubit.state).thenReturn(
        const RecommendedHotelsInitial(),
      );

      await tester.pumpWidget(buildSubject(onSeeAllTap: () => tapped = true));
      await tester.tap(find.text('See All'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('See All action is disabled when onSeeAllTap is null', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        const RecommendedHotelsInitial(),
      );

      await tester.pumpWidget(buildSubject());

      final textButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'See All'),
      );
      expect(textButton.onPressed, isNull);
    });

    testWidgets(
      'tapping Retry triggers loadRecommendedHotels using LocationCubit',
      (tester) async {
        when(() => mockCubit.state).thenReturn(
          const RecommendedHotelsFailure(message: 'Network error'),
        );
        when(
          () => mockCubit.loadRecommendedHotels(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(buildSubject());
        await tester.tap(find.text('Retry'));
        await tester.pump();

        verify(
          () => mockCubit.loadRecommendedHotels(
            latitude: -7.4243,
            longitude: 109.2391,
          ),
        ).called(1);
      },
    );

    testWidgets('tapping Retry invokes custom onRetry when provided', (
      tester,
    ) async {
      var retried = false;
      when(() => mockCubit.state).thenReturn(
        const RecommendedHotelsFailure(message: 'Network error'),
      );

      await tester.pumpWidget(buildSubject(onRetry: () => retried = true));
      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retried, isTrue);
      verifyNever(
        () => mockCubit.loadRecommendedHotels(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      );
    });
  });
}
