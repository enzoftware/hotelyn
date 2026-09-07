import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/home/widgets/home_header.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('LocationCard', () {
    late LocationCubit locationCubit;

    setUp(() {
      locationCubit = MockLocationCubit();
    });

    Widget buildSubject(LocationState state) {
      when(() => locationCubit.state).thenReturn(state);
      return Scaffold(
        body: BlocProvider<LocationCubit>.value(
          value: locationCubit,
          child: const LocationCard(),
        ),
      );
    }

    testWidgets('renders current location cityName from state', (tester) async {
      await tester.pumpApp(
        buildSubject(
          const LocationState(
            userLocation: UserLocation(
              latitude: 40.7128,
              longitude: -74.0060,
              cityName: 'New York, USA',
            ),
          ),
        ),
      );

      expect(find.text('New York, USA'), findsOneWidget);
      expect(find.byIcon(Icons.place_outlined), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets(
      'tapping opens LocationPrimingSheet when not denied or manual',
      (tester) async {
        await tester.pumpApp(
          buildSubject(
            const LocationState(
              userLocation: UserLocation(
                latitude: -7.4244,
                longitude: 109.2304,
                cityName: 'Purwokerto, IND',
              ),
            ),
          ),
        );

        await tester.tap(find.byType(LocationCard));
        await tester.pumpAndSettle();

        expect(find.byType(LocationPrimingSheet), findsOneWidget);
      },
    );

    testWidgets(
      'tapping opens ManualLocationSheet directly when permission is denied',
      (tester) async {
        await tester.pumpApp(
          buildSubject(
            const LocationState(
              permissionStatus: LocationPermissionStatus.denied,
              userLocation: UserLocation(
                latitude: -7.4244,
                longitude: 109.2304,
                cityName: 'Purwokerto, IND',
              ),
            ),
          ),
        );

        await tester.tap(find.byType(LocationCard));
        await tester.pumpAndSettle();

        expect(find.byType(ManualLocationSheet), findsOneWidget);
      },
    );

    testWidgets(
      'tapping opens ManualLocationSheet directly '
      'when isManualFallback is true',
      (tester) async {
        await tester.pumpApp(
          buildSubject(
            const LocationState(
              userLocation: UserLocation(
                latitude: -8.4095,
                longitude: 115.1889,
                cityName: 'Bali, IND',
                isManualFallback: true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(LocationCard));
        await tester.pumpAndSettle();

        expect(find.byType(ManualLocationSheet), findsOneWidget);
      },
    );
  });
}
