import 'package:equatable/equatable.dart';

/// A hotel in the Hotelyn catalogue.
///
/// [distanceKm] and [popularity] are search projections: they are only
/// populated by the geolocation search functions (`nearby_hotels` /
/// `recommended_hotels`) and are `null` for a plain catalogue lookup.
class Hotel extends Equatable {
  const Hotel({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.popularity,
  });

  final String id;
  final String name;
  final String city;
  final String country;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;

  /// Great-circle distance in kilometres from the query point, when returned by
  /// a proximity search. `null` otherwise.
  final double? distanceKm;

  /// Count of qualifying confirmed reservations in the recommendation window,
  /// when returned by `recommended_hotels`. `null` otherwise.
  final int? popularity;

  @override
  List<Object?> get props => [
        id,
        name,
        city,
        country,
        description,
        address,
        latitude,
        longitude,
        distanceKm,
        popularity,
      ];
}
