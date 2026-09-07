import 'package:bloc_test/bloc_test.dart';
import 'package:california_ui/california_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/home/cubit/recommended_hotels_cubit.dart';
import 'package:hotelyn/features/home/widgets/recommended_hotels_section.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;
import 'package:mocktail/mocktail.dart';

class _MockRecommendedHotelsCubit extends MockCubit<RecommendedHotelsState>
    implements RecommendedHotelsCubit {}

void main() {
  late _MockRecommendedHotelsCubit mockCubit;

  setUp(() {
    mockCubit = _MockRecommendedHotelsCubit();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            BlocProvider<RecommendedHotelsCubit>.value(
              value: mockCubit,
              child: const RecommendedHotelsSection(),
            ),
          ],
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
  });
}
