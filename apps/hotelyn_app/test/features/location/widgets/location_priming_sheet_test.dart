import 'dart:async';

import 'package:california_ui/california_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('LocationPrimingSheet', () {
    late LocationCubit locationCubit;

    setUp(() {
      locationCubit = MockLocationCubit();
      when(() => locationCubit.state).thenReturn(
        const LocationState(permissionStatus: LocationPermissionStatus.primed),
      );
    });

    Widget buildSubject({
      VoidCallback? onEnableLocation,
      VoidCallback? onEnterManually,
      VoidCallback? onMaybeLater,
    }) {
      return Scaffold(
        body: BlocProvider<LocationCubit>.value(
          value: locationCubit,
          child: LocationPrimingSheet(
            onEnableLocation: onEnableLocation,
            onEnterManually: onEnterManually,
            onMaybeLater: onMaybeLater,
          ),
        ),
      );
    }

    testWidgets('renders all copy and value proposition elements', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject());

      // Heading
      expect(find.text('Find Hotels Near You'), findsOneWidget);

      // Explanation copy
      expect(
        find.textContaining(
          'Hotelyn uses your location to discover hotels nearby',
        ),
        findsOneWidget,
      );

      // Value proposition bullets
      expect(find.text('Accurate Distance'), findsOneWidget);
      expect(find.text('Local Recommendations'), findsOneWidget);
      expect(find.text('Your Privacy Matters'), findsOneWidget);

      // Action buttons
      expect(find.text('Enable Location'), findsOneWidget);
      expect(find.text('Enter Location Manually'), findsOneWidget);
      expect(find.text('Maybe Later'), findsOneWidget);

      // Verify minimum 48px touch target for Maybe Later
      final maybeLaterBtn = find.widgetWithText(
        CaliforniaButton,
        'Maybe Later',
      );
      final size = tester.getSize(maybeLaterBtn);
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets(
      'calls onEnableLocation callback when Enable Location is tapped',
      (tester) async {
        var enabledTapped = false;
        await tester.pumpApp(
          buildSubject(onEnableLocation: () => enabledTapped = true),
        );

        await tester.tap(find.text('Enable Location'));
        await tester.pump();

        expect(enabledTapped, isTrue);
      },
    );

    testWidgets(
      'calls cubit.requestPermissionFromPriming '
      'when onEnableLocation is null',
      (tester) async {
        when(() => locationCubit.requestPermissionFromPriming()).thenAnswer(
          (_) async {},
        );

        await tester.pumpApp(buildSubject());

        await tester.tap(find.text('Enable Location'));
        await tester.pump();

        verify(() => locationCubit.requestPermissionFromPriming()).called(1);
      },
    );

    testWidgets(
      'calls onEnterManually callback when Enter Location Manually is tapped',
      (tester) async {
        var manualTapped = false;
        await tester.pumpApp(
          buildSubject(onEnterManually: () => manualTapped = true),
        );

        await tester.tap(find.text('Enter Location Manually'));
        await tester.pump();

        expect(manualTapped, isTrue);
      },
    );

    testWidgets(
      'calls cubit.enterLocationManuallyFromPriming '
      'when onEnterManually null',
      (tester) async {
        when(
          () => locationCubit.enterLocationManuallyFromPriming(),
        ).thenAnswer(
          (_) async {},
        );

        await tester.pumpApp(buildSubject());

        await tester.tap(find.text('Enter Location Manually'));
        await tester.pump();

        verify(
          () => locationCubit.enterLocationManuallyFromPriming(),
        ).called(1);
      },
    );

    testWidgets('calls onMaybeLater callback when Maybe Later is tapped', (
      tester,
    ) async {
      var laterTapped = false;
      await tester.pumpApp(
        buildSubject(onMaybeLater: () => laterTapped = true),
      );

      final maybeLater = find.text('Maybe Later');
      await tester.ensureVisible(maybeLater);
      await tester.tap(maybeLater);
      await tester.pump();

      expect(laterTapped, isTrue);
    });

    testWidgets('tapping Maybe Later without onMaybeLater does not throw', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject());

      final maybeLater = find.text('Maybe Later');
      await tester.ensureVisible(maybeLater);
      await tester.tap(maybeLater);
      await tester.pump();
    });

    testWidgets('LocationPrimingSheet.show opens sheet and triggers action', (
      tester,
    ) async {
      var enabledFromSheet = false;

      await tester.pumpApp(
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                unawaited(
                  LocationPrimingSheet.show<void>(
                    context,
                    onEnableLocation: () => enabledFromSheet = true,
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(LocationPrimingSheet), findsOneWidget);

      await tester.tap(find.text('Enable Location'));
      await tester.pumpAndSettle();

      expect(enabledFromSheet, isTrue);
      expect(find.byType(LocationPrimingSheet), findsNothing);
    });
  });
}
