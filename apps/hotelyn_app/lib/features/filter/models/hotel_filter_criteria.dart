import 'package:equatable/equatable.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' show Hotel;

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

/// Presentation and filter matching properties for [Hotel].
///
/// Until pricing and availability endpoints (FE-1305 / BE) are attached,
/// this extension provides deterministic metadata derived from the hotel
/// id / name, allowing filters (price range, rating, availability, amenities)
/// and sorting (price, rating, distance, popularity) to function consistently.
extension HotelDisplayProperties on Hotel {
  /// Deterministic pseudo-hash from hotel ID and name.
  int get _seed => (id.hashCode ^ name.hashCode).abs();

  /// Nightly price in USD (range $50 - $450).
  double get pricePerNight => 50.0 + (_seed % 41) * 10.0;

  /// Star rating (range 3.5 - 5.0 in 0.1 increments).
  double get rating => 3.5 + ((_seed % 16) / 10.0);

  /// Number of customer reviews (range 12 - 400).
  int get reviewCount => 12 + (_seed % 389);

  /// Whether the hotel has rooms available now.
  /// Approximately 80% of hotels are available.
  bool get isAvailableNow => (_seed % 5) != 0;

  /// Set of amenities offered by this hotel.
  Set<HotelAmenity> get availableAmenities {
    final amenities = <HotelAmenity>{
      HotelAmenity.wifi,
    };
    if (_seed.isEven) amenities.add(HotelAmenity.swimmingPool);
    if (_seed % 3 == 0) amenities.add(HotelAmenity.parking);
    if (_seed % 4 == 0) amenities.add(HotelAmenity.restaurant);
    if (_seed % 5 == 0) amenities.add(HotelAmenity.gym);
    if (_seed.isOdd) amenities.add(HotelAmenity.freeBreakfast);
    return amenities;
  }

  /// Whether this hotel satisfies the given [criteria].
  bool matchesFilter(HotelFilterCriteria criteria) {
    if (criteria.availableNow && !isAvailableNow) {
      return false;
    }
    if (pricePerNight < criteria.minPrice ||
        pricePerNight > criteria.maxPrice) {
      return false;
    }
    if (criteria.minRating != null && rating < criteria.minRating!) {
      return false;
    }
    if (criteria.amenities.isNotEmpty &&
        !availableAmenities.containsAll(criteria.amenities)) {
      return false;
    }
    return true;
  }
}
