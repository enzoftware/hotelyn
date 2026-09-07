import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ManualLocationSheet', () {
    late LocationCubit locationCubit;

    setUpAll(() {
      registerFallbackValue(UserLocation.defaultFallback);
    });

    setUp(() {
      locationCubit = MockLocationCubit();
      when(() => locationCubit.state).thenReturn(
        const LocationState(
          permissionStatus: LocationPermissionStatus.denied,
        ),
      );
    });

    Widget buildSubject({
      UserLocation? initialLocation,
      ValueChanged<UserLocation>? onLocationSelected,
    }) {
      return Scaffold(
        body: BlocProvider<LocationCubit>.value(
          value: locationCubit,
          child: ManualLocationSheet(
            initialLocation: initialLocation,
            onLocationSelected: onLocationSelected,
          ),
        ),
      );
    }

    testWidgets('renders title, input field, chips, and set location button',
        (tester) async {
      await tester.pumpApp(buildSubject());

      expect(find.text('Enter Location Manually'), findsOneWidget);
      expect(find.text('City or Region'), findsOneWidget);
      expect(find.text('Purwokerto, IND'), findsWidgets);
      expect(find.text('Jakarta, IND'), findsOneWidget);
      expect(find.text('Bali, IND'), findsOneWidget);
      expect(find.text('Yogyakarta, IND'), findsOneWidget);
      expect(find.text('Set Location'), findsOneWidget);
    });

    testWidgets(
        'selecting a destination chip updates selection and calls callback',
        (tester) async {
      UserLocation? selected;
      await tester.pumpApp(
        buildSubject(onLocationSelected: (loc) => selected = loc),
      );

      await tester.tap(find.text('Bali, IND'));
      await tester.pump();

      await tester.tap(find.text('Set Location'));
      await tester.pump();

      expect(selected, isNotNull);
      expect(selected?.cityName, 'Bali, IND');
      expect(selected?.isManualFallback, isTrue);
    });

    testWidgets(
      'typing a destination matching fallbackOptions sets destination '
      'with coordinates',
      (tester) async {
        UserLocation? selected;
        await tester.pumpApp(
          buildSubject(onLocationSelected: (loc) => selected = loc),
        );

        final inputFinder = find.byType(TextField);
        await tester.enterText(inputFinder, 'Jakarta');
        await tester.pump();

        await tester.tap(find.text('Set Location'));
        await tester.pump();

        expect(selected, isNotNull);
        expect(selected?.cityName, 'Jakarta, IND');
        expect(selected?.latitude, -6.2088);
        expect(selected?.longitude, 106.8456);
        expect(selected?.isManualFallback, isTrue);
      },
    );

    testWidgets(
        'typing an unknown destination retains selected location to avoid '
        'mismatched coordinates', (tester) async {
      UserLocation? selected;
      await tester.pumpApp(
        buildSubject(
          initialLocation: UserLocation.defaultFallback,
          onLocationSelected: (loc) => selected = loc,
        ),
      );

      final inputFinder = find.byType(TextField);
      await tester.enterText(inputFinder, 'Unknown City');
      await tester.pump();

      await tester.tap(find.text('Set Location'));
      await tester.pump();

      expect(selected, isNotNull);
      expect(selected?.cityName, UserLocation.defaultFallback.cityName);
      expect(selected?.latitude, UserLocation.defaultFallback.latitude);
      expect(selected?.longitude, UserLocation.defaultFallback.longitude);
    });

    testWidgets('calls cubit.setManualLocation when onLocationSelected is null',
        (tester) async {
      when(() => locationCubit.setManualLocation(any())).thenAnswer(
        (_) async {},
      );

      await tester.pumpApp(buildSubject());

      await tester.tap(find.text('Set Location'));
      await tester.pump();

      verify(() => locationCubit.setManualLocation(any())).called(1);
    });

    testWidgets('ManualLocationSheet.show opens and returns selected location',
        (tester) async {
      UserLocation? result;

      await tester.pumpApp(
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ManualLocationSheet.show(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(ManualLocationSheet), findsOneWidget);

      await tester.tap(find.text('Jakarta, IND'));
      await tester.pump();

      await tester.tap(find.text('Set Location'));
      await tester.pumpAndSettle();

      expect(result?.cityName, 'Jakarta, IND');
      expect(find.byType(ManualLocationSheet), findsNothing);
    });
  });
}
