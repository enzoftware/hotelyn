import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_image.dart';

void main() {
  group('CaliforniaProductCard.large', () {
    testWidgets('renders title, location, price, and rating', (
      tester,
    ) async {
      await tester.pumpApp(
        CaliforniaProductCard.large(
          image: testImage,
          title: 'Diamond Heart Hotel',
          location: 'Purwokerto, Karang Lewas',
          pricePerNight: r'$46',
          pricePeriodLabel: 'Per Night',
          rating: 4.6,
        ),
      );

      expect(find.text('Diamond Heart Hotel'), findsOneWidget);
      expect(find.text('Purwokerto, Karang Lewas'), findsOneWidget);
      expect(find.text(r'$46'), findsOneWidget);
      expect(find.text('Per Night'), findsOneWidget);
      expect(find.text('4.6'), findsOneWidget);
    });

    testWidgets('renders a facility for each entry', (tester) async {
      await tester.pumpApp(
        CaliforniaProductCard.large(
          image: testImage,
          title: 'Diamond Heart Hotel',
          location: 'Purwokerto, Karang Lewas',
          pricePerNight: r'$46',
          pricePeriodLabel: 'Per Night',
          facilities: const [
            CaliforniaProductFacility(
              icon: CupertinoIcons.bed_double,
              label: '2 Beds',
            ),
            CaliforniaProductFacility(
              icon: CupertinoIcons.wifi,
              label: 'Wifi',
            ),
          ],
        ),
      );

      expect(find.text('2 Beds'), findsOneWidget);
      expect(find.text('Wifi'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        CaliforniaProductCard.large(
          image: testImage,
          title: 'Diamond Heart Hotel',
          location: 'Purwokerto, Karang Lewas',
          pricePerNight: r'$46',
          pricePeriodLabel: 'Per Night',
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.text('Diamond Heart Hotel'));

      expect(tapped, isTrue);
    });
  });

  group('CaliforniaProductCard.medium', () {
    testWidgets('renders title, location, price, and price suffix', (
      tester,
    ) async {
      await tester.pumpApp(
        CaliforniaProductCard.medium(
          image: testImage,
          title: 'Diamond Heart Hotel',
          location: 'Purwokerto, Street No 31, Central Java',
          pricePerNight: r'$46',
          priceSuffix: '/Night',
        ),
      );

      expect(find.text('Diamond Heart Hotel'), findsOneWidget);
      expect(
        find.text('Purwokerto, Street No 31, Central Java'),
        findsOneWidget,
      );
      expect(find.textContaining(r'$46'), findsOneWidget);
      expect(find.textContaining('/Night'), findsOneWidget);
    });
  });

  group('CaliforniaProductCard.small', () {
    testWidgets('renders title, location, price, and review count', (
      tester,
    ) async {
      await tester.pumpApp(
        CaliforniaProductCard.small(
          image: testImage,
          title: 'Hyatt Washington Hotel',
          location: 'Purwokerto, Glempang',
          pricePerNight: r'$38',
          pricePeriodLabel: ' / Night',
          rating: 4.2,
          reviewCount: 84,
          reviewCountLabel: (count) => '($count Reviews)',
        ),
      );

      expect(find.text('Hyatt Washington Hotel'), findsOneWidget);
      expect(find.text('Purwokerto, Glempang'), findsOneWidget);
      expect(find.textContaining(r'$38'), findsOneWidget);
      expect(find.textContaining('4.2'), findsOneWidget);
      expect(find.textContaining('(84 Reviews)'), findsOneWidget);
    });

    testWidgets('omits rating icon when rating is not provided', (
      tester,
    ) async {
      await tester.pumpApp(
        CaliforniaProductCard.small(
          image: testImage,
          title: 'Hyatt Washington Hotel',
          location: 'Purwokerto, Glempang',
          pricePerNight: r'$38',
          pricePeriodLabel: ' / Night',
        ),
      );

      expect(find.byIcon(CupertinoIcons.star_fill), findsNothing);
    });
  });
}
