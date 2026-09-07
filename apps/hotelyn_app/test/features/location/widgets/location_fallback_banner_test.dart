import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('LocationFallbackBanner', () {
    late LocationCubit locationCubit;

    setUp(() {
      locationCubit = MockLocationCubit();
    });

    Widget buildSubject(LocationState state) {
      when(() => locationCubit.state).thenReturn(state);
      return Scaffold(
        body: BlocProvider<LocationCubit>.value(
          value: locationCubit,
          child: const LocationFallbackBanner(),
        ),
      );
    }

    testWidgets(
      'renders nothing when permission is granted and not manual fallback',
      (tester) async {
        await tester.pumpApp(
          buildSubject(
            const LocationState(
              permissionStatus: LocationPermissionStatus.granted,
              userLocation: UserLocation(
                latitude: -12.0464,
                longitude: -77.0428,
                cityName: 'Lima, PER',
              ),
            ),
          ),
        );

        expect(find.textContaining('Permission denied'), findsNothing);
      },
    );

    testWidgets('renders banner when permission is denied', (tester) async {
      await tester.pumpApp(
        buildSubject(
          const LocationState(
            permissionStatus: LocationPermissionStatus.denied,
          ),
        ),
      );

      expect(find.text('Location: Purwokerto, IND'), findsOneWidget);
      expect(
        find.text('Permission denied. Select your destination manually.'),
        findsOneWidget,
      );
      expect(find.text('Change'), findsOneWidget);
    });

    testWidgets('renders non-denial copy when manual fallback is voluntary', (
      tester,
    ) async {
      await tester.pumpApp(
        buildSubject(
          const LocationState(
            permissionStatus: LocationPermissionStatus.granted,
            userLocation: UserLocation(
              latitude: -8.4095,
              longitude: 115.1889,
              cityName: 'Bali, IND',
              isManualFallback: true,
            ),
          ),
        ),
      );

      expect(find.text('Location: Bali, IND'), findsOneWidget);
      expect(find.text('Manually selected destination.'), findsOneWidget);
      expect(find.textContaining('Permission denied'), findsNothing);
      expect(find.text('Change'), findsOneWidget);
    });

    testWidgets('tapping Change opens ManualLocationSheet', (tester) async {
      await tester.pumpApp(
        buildSubject(
          const LocationState(
            permissionStatus: LocationPermissionStatus.denied,
          ),
        ),
      );

      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();

      expect(find.byType(ManualLocationSheet), findsOneWidget);
    });
  });
}
