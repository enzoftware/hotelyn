import 'package:equatable/equatable.dart';
import 'package:hotelyn/features/filter/models/hotel_filter_criteria.dart';

class FilterState extends Equatable {
  const FilterState({
    this.criteria = HotelFilterCriteria.defaultCriteria,
  });

  final HotelFilterCriteria criteria;

  bool get isFiltered => criteria.isFiltered;

  FilterState copyWith({
    HotelFilterCriteria? criteria,
  }) {
    return FilterState(
      criteria: criteria ?? this.criteria,
    );
  }

  @override
  List<Object?> get props => [criteria];
}
