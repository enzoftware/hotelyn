import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/hotel_detail/hotel_detail.dart';
import 'package:hotelyn/features/hotel_detail/widgets/hotel_detail_bottom_bar.dart';
import 'package:hotelyn/features/hotel_detail/widgets/hotel_detail_facilities.dart';
import 'package:hotelyn/features/hotel_detail/widgets/hotel_detail_location_card.dart';
import 'package:hotelyn/features/hotel_detail/widgets/hotel_detail_reviews_section.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;
import 'package:mocktail/mocktail.dart';

class MockHotelDetailCubit extends MockCubit<HotelDetailState>
    implements HotelDetailCubit {}

void main() {
  group('HotelDetailPage', () {
    late MockHotelDetailCubit mockCubit;
    const testHotel = domain.Hotel(
      id: 'hotel-123',
      name: 'Grand Royal Palace',
      city: 'Purwokerto',
      country: 'Indonesia',
      address: 'Haight Street, Karang Lewas',
      description: 'A luxurious 5-star hotel with top class amenities.',
    );

    setUp(() {
      mockCubit = MockHotelDetailCubit();
      when(() => mockCubit.state).thenReturn(
        const HotelDetailState(
          hotel: testHotel,
          status: HotelDetailStatus.loaded,
        ),
      );
    });

    Widget buildSubject() {
      return MaterialApp(
        home: HotelDetailPage(
          hotel: testHotel,
          cubit: mockCubit,
        ),
      );
    }

    testWidgets('renders all key sections and hotel information', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Grand Royal Palace'), findsNWidgets(2));
      expect(find.text('Purwokerto, Indonesia'), findsOneWidget);
      expect(find.text('Facilities'), findsOneWidget);
      expect(find.byType(HotelDetailFacilities), findsOneWidget);
      expect(find.byType(HotelDetailLocationCard), findsOneWidget);
      expect(find.byType(HotelDetailReviewsSection), findsOneWidget);
      expect(find.byType(HotelDetailBottomBar), findsOneWidget);
      expect(find.text('Book Now'), findsOneWidget);
    });

    testWidgets('toggles Read More and Read Less description', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final readMoreFinder = find.text('Read More');
      expect(readMoreFinder, findsOneWidget);

      await tester.tap(readMoreFinder);
      await tester.pumpAndSettle();

      expect(find.text('Read Less'), findsOneWidget);

      await tester.tap(find.text('Read Less'));
      await tester.pumpAndSettle();

      expect(find.text('Read More'), findsOneWidget);
    });

    testWidgets('renders Unavailable button when hasAvailableRoom is false', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockCubit.state).thenReturn(
        const HotelDetailState(
          hotel: testHotel,
          status: HotelDetailStatus.loaded,
          hasAvailableRoom: false,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Unavailable'), findsOneWidget);
      expect(find.text('Book Now'), findsNothing);
    });

    testWidgets('toggles like favorite icon button', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final favoriteFinder = find.bySemanticsLabel('Favorite');
      expect(favoriteFinder, findsOneWidget);

      await tester.tap(favoriteFinder);
      await tester.pumpAndSettle();
    });

    testWidgets('renders distance when distanceKm is present on hotel', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      const hotelWithDistance = domain.Hotel(
        id: 'hotel-dist',
        name: 'Hilltop Resort',
        city: 'Bandung',
        country: 'Indonesia',
        distanceKm: 2.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HotelDetailPage(
            hotel: hotelWithDistance,
            cubit: mockCubit,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2.5 km · Bandung, Indonesia'), findsOneWidget);
    });

    testWidgets(
      'renders Unavailable button using default cubit without injected client',
      (
        tester,
      ) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(
            home: HotelDetailPage(hotel: testHotel),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Grand Royal Palace'), findsNWidgets(2));
        expect(find.text('Unavailable'), findsOneWidget);
      },
    );
  });
}
