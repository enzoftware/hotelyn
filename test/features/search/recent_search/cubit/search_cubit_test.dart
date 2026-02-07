import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
import 'package:hotelyn/features/search/recent_search/cubit/search_cubit.dart';
import 'package:hotelyn/features/search/recent_search/cubit/search_state.dart';
import 'package:mocktail/mocktail.dart';

class MockClarityService extends Mock implements ClarityService {}

void main() {
  group('SearchCubit', () {
    late ClarityService clarityService;
    late SearchCubit cubit;

    setUp(() {
      clarityService = MockClarityService();
      cubit = SearchCubit(clarityService: clarityService);
    });

    test('initial state is SearchLoadSuccess', () {
      expect(cubit.state, SearchLoadSuccess());
    });

    test('calls setCurrentScreenName with "search" on initialization', () {
      verify(() => clarityService.setCurrentScreenName('search')).called(1);
    });
  });
}
