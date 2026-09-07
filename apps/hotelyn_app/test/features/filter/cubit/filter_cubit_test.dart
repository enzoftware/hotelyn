import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/filter/filter.dart';

void main() {
  group('FilterCubit', () {
    test('initial state has default criteria and isFiltered false', () {
      final cubit = FilterCubit();
      expect(cubit.state.criteria, equals(HotelFilterCriteria.defaultCriteria));
      expect(cubit.state.isFiltered, isFalse);
    });

    blocTest<FilterCubit, FilterState>(
      'applyCriteria updates state with new criteria',
      build: FilterCubit.new,
      act: (cubit) => cubit.applyCriteria(
        const HotelFilterCriteria(
          minPrice: 100,
          maxPrice: 400,
          availableNow: true,
          minRating: 4.5,
          sortBy: HotelSortOption.highestRating,
        ),
      ),
      expect: () => [
        const FilterState(
          criteria: HotelFilterCriteria(
            minPrice: 100,
            maxPrice: 400,
            availableNow: true,
            minRating: 4.5,
            sortBy: HotelSortOption.highestRating,
          ),
        ),
      ],
      verify: (cubit) {
        expect(cubit.state.isFiltered, isTrue);
      },
    );

    blocTest<FilterCubit, FilterState>(
      'toggleAvailableNow flips availableNow flag',
      build: FilterCubit.new,
      act: (cubit) => cubit.toggleAvailableNow(),
      expect: () => [
        const FilterState(
          criteria: HotelFilterCriteria(availableNow: true),
        ),
      ],
    );

    blocTest<FilterCubit, FilterState>(
      'setPriceRange updates min and max price',
      build: FilterCubit.new,
      act: (cubit) => cubit.setPriceRange(50, 300),
      expect: () => [
        const FilterState(
          criteria: HotelFilterCriteria(
            minPrice: 50,
            maxPrice: 300,
          ),
        ),
      ],
    );

    blocTest<FilterCubit, FilterState>(
      'setRating updates minimum rating threshold and clearRating removes it',
      build: FilterCubit.new,
      act: (cubit) {
        cubit
          ..setRating(4)
          ..setRating(null);
      },
      expect: () => [
        const FilterState(
          criteria: HotelFilterCriteria(minRating: 4),
        ),
        const FilterState(),
      ],
    );

    blocTest<FilterCubit, FilterState>(
      'reset restores default criteria',
      build: FilterCubit.new,
      seed: () => const FilterState(
        criteria: HotelFilterCriteria(
          minPrice: 80,
          maxPrice: 250,
          availableNow: true,
          sortBy: HotelSortOption.lowestPrice,
        ),
      ),
      act: (cubit) => cubit.reset(),
      expect: () => [
        const FilterState(),
      ],
      verify: (cubit) {
        expect(cubit.state.isFiltered, isFalse);
      },
    );
  });
}
