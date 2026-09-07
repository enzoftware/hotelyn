import 'package:equatable/equatable.dart';

/// Available sorting criteria for hotel listings matching Figma `152:4281`.
enum HotelSortOption {
  highestPopularity,
  lowestPrice,
  highestRating,
  nearestDistance,
}

/// Hotel amenity filters matching Figma `203:5504`.
enum HotelAmenity {
  wifi,
  swimmingPool,
  parking,
  restaurant,
  gym,
  freeBreakfast,
}

/// Filter criteria for hotel discovery across Nearby and Search screens.
class HotelFilterCriteria extends Equatable {
  const HotelFilterCriteria({
    this.minPrice = 0.0,
    this.maxPrice = 1000.0,
    this.minRating,
    this.availableNow = false,
    this.amenities = const {},
    this.sortBy = HotelSortOption.highestPopularity,
  });

  /// The minimum price per night in USD.
  final double minPrice;

  /// The maximum price per night in USD.
  final double maxPrice;

  /// The minimum star rating threshold (e.g. 4.0, 4.5).
  final double? minRating;

  /// Whether to only show hotels with currently available rooms
  /// (first-class toggle).
  final bool availableNow;

  /// Set of selected amenities.
  final Set<HotelAmenity> amenities;

  /// Applied sorting option.
  final HotelSortOption sortBy;

  /// Default initial criteria.
  static const defaultCriteria = HotelFilterCriteria();

  /// Whether any filter differs from the default criteria.
  bool get isFiltered =>
      minPrice != 0 ||
      maxPrice != 1000 ||
      minRating != null ||
      availableNow ||
      amenities.isNotEmpty ||
      sortBy != HotelSortOption.highestPopularity;

  HotelFilterCriteria copyWith({
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool clearRating = false,
    bool? availableNow,
    Set<HotelAmenity>? amenities,
    HotelSortOption? sortBy,
  }) {
    return HotelFilterCriteria(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: clearRating ? null : (minRating ?? this.minRating),
      availableNow: availableNow ?? this.availableNow,
      amenities: amenities ?? this.amenities,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [
    minPrice,
    maxPrice,
    minRating,
    availableNow,
    amenities,
    sortBy,
  ];
}
