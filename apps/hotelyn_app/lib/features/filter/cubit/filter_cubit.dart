import 'package:bloc/bloc.dart';
import 'package:hotelyn/features/filter/cubit/filter_state.dart';
import 'package:hotelyn/features/filter/models/hotel_filter_criteria.dart';

export 'filter_state.dart';

/// Cubit managing applied filter criteria across Nearby and Search flows.
class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(const FilterState());

  /// Updates active filter criteria.
  void applyCriteria(HotelFilterCriteria criteria) {
    emit(FilterState(criteria: criteria));
  }

  /// Toggles the first-class "available now" switch.
  void toggleAvailableNow() {
    emit(
      FilterState(
        criteria: state.criteria.copyWith(
          availableNow: !state.criteria.availableNow,
        ),
      ),
    );
  }

  /// Sets price range.
  void setPriceRange(double min, double max) {
    emit(
      FilterState(
        criteria: state.criteria.copyWith(
          minPrice: min,
          maxPrice: max,
        ),
      ),
    );
  }

  /// Sets minimum rating filter.
  void setRating(double? rating) {
    emit(
      FilterState(
        criteria: state.criteria.copyWith(
          minRating: rating,
          clearRating: rating == null,
        ),
      ),
    );
  }

  /// Resets all filters back to default unfiltered state.
  void reset() {
    emit(const FilterState());
  }
}
