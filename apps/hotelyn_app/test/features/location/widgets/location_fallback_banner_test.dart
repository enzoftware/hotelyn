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
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<LocationCubit>.value(
            value: locationCubit,
            child: const LocationFallbackBanner(),
          ),
        ),
      );
    }

    testWidgets(
      'renders nothing when permission is granted and not manual fallback',
      (tester) async {
        await tester.pumpWidget(
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
      await tester.pumpWidget(
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

    testWidgets('tapping Change opens ManualLocationSheet', (tester) async {
      await tester.pumpWidget(
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
