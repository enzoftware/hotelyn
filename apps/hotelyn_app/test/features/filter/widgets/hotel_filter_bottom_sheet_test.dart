import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/filter/filter.dart';

void main() {
  group('HotelFilterBottomSheet', () {
    Future<void> pumpSubject(
      WidgetTester tester, {
      HotelFilterCriteria initialCriteria = HotelFilterCriteria.defaultCriteria,
      ValueChanged<HotelFilterCriteria>? onApply,
    }) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HotelFilterBottomSheet(
                initialCriteria: initialCriteria,
                onApply: onApply ?? (_) {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders all filter sections with initial criteria', (
      tester,
    ) async {
      await pumpSubject(tester);

      expect(find.text('Filter'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Available Now'), findsOneWidget);
      expect(find.text('Price Range'), findsOneWidget);
      expect(find.text('Rating'), findsOneWidget);
      expect(find.text('Sort By'), findsOneWidget);
      expect(find.text('Amenities'), findsOneWidget);
      expect(find.text('Apply Filter'), findsOneWidget);
    });

    testWidgets('toggling Available Now switch updates value', (tester) async {
      HotelFilterCriteria? applied;
      await pumpSubject(tester, onApply: (criteria) => applied = criteria);

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apply Filter'));
      await tester.pumpAndSettle();

      expect(applied, isNotNull);
      expect(applied!.availableNow, isTrue);
    });

    testWidgets('selecting rating chip updates minRating', (tester) async {
      HotelFilterCriteria? applied;
      await pumpSubject(tester, onApply: (criteria) => applied = criteria);

      await tester.tap(find.text('4.5+'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apply Filter'));
      await tester.pumpAndSettle();

      expect(applied, isNotNull);
      expect(applied!.minRating, equals(4.5));
    });

    testWidgets('selecting sort option updates sortBy', (tester) async {
      HotelFilterCriteria? applied;
      await pumpSubject(tester, onApply: (criteria) => applied = criteria);

      await tester.tap(find.text('Lowest Price'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apply Filter'));
      await tester.pumpAndSettle();

      expect(applied, isNotNull);
      expect(applied!.sortBy, equals(HotelSortOption.lowestPrice));
    });

    testWidgets('selecting amenity chip updates selected amenities', (
      tester,
    ) async {
      HotelFilterCriteria? applied;
      await pumpSubject(tester, onApply: (criteria) => applied = criteria);

      await tester.tap(find.text('Wifi'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Swimming Pool'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apply Filter'));
      await tester.pumpAndSettle();

      expect(applied, isNotNull);
      expect(
        applied!.amenities,
        containsAll([HotelAmenity.wifi, HotelAmenity.swimmingPool]),
      );
    });

    testWidgets('tapping Reset resets all criteria', (tester) async {
      HotelFilterCriteria? applied;
      await pumpSubject(
        tester,
        initialCriteria: const HotelFilterCriteria(
          minPrice: 150,
          maxPrice: 600,
          availableNow: true,
          minRating: 4,
          sortBy: HotelSortOption.highestRating,
        ),
        onApply: (criteria) => applied = criteria,
      );

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apply Filter'));
      await tester.pumpAndSettle();

      expect(applied, isNotNull);
      expect(applied!.availableNow, isFalse);
      expect(applied!.minRating, isNull);
      expect(applied!.sortBy, equals(HotelSortOption.highestPopularity));
    });

    testWidgets('show static helper opens modal bottom sheet', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    unawaited(
                      HotelFilterBottomSheet.show(
                        context,
                        initialCriteria: HotelFilterCriteria.defaultCriteria,
                      ),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(HotelFilterBottomSheet), findsOneWidget);
    });
  });
}
