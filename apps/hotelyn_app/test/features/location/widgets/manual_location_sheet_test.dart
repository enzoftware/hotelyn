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
          isManualLocationDialogOpen: true,
        ),
      );
    });

    Widget buildSubject({
      UserLocation? initialLocation,
      ValueChanged<UserLocation>? onLocationSelected,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<LocationCubit>.value(
            value: locationCubit,
            child: ManualLocationSheet(
              initialLocation: initialLocation,
              onLocationSelected: onLocationSelected,
            ),
          ),
        ),
      );
    }

    testWidgets('renders title, input field, chips, and set location button',
        (tester) async {
      await tester.pumpWidget(buildSubject());

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
      await tester.pumpWidget(
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

    testWidgets('typing a custom city name sets custom manual location',
        (tester) async {
      UserLocation? selected;
      await tester.pumpWidget(
        buildSubject(onLocationSelected: (loc) => selected = loc),
      );

      final inputFinder = find.byType(TextField);
      await tester.enterText(inputFinder, 'Cusco, PER');
      await tester.pump();

      await tester.tap(find.text('Set Location'));
      await tester.pump();

      expect(selected, isNotNull);
      expect(selected?.cityName, 'Cusco, PER');
      expect(selected?.isManualFallback, isTrue);
    });

    testWidgets('calls cubit.setManualLocation when onLocationSelected is null',
        (tester) async {
      when(() => locationCubit.setManualLocation(any())).thenAnswer(
        (_) async {},
      );

      await tester.pumpWidget(buildSubject());

      await tester.tap(find.text('Set Location'));
      await tester.pump();

      verify(() => locationCubit.setManualLocation(any())).called(1);
    });

    testWidgets('ManualLocationSheet.show opens and returns selected location',
        (tester) async {
      UserLocation? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await ManualLocationSheet.show(context);
                },
                child: const Text('Open'),
              ),
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
