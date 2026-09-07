import 'package:equatable/equatable.dart';

/// Represents a geographic location for hotel search and recommendations.
class UserLocation extends Equatable {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    this.isManualFallback = false,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      cityName: json['cityName'] as String,
      isManualFallback: json['isManualFallback'] as bool? ?? false,
    );
  }

  /// Default manual fallback location matching the Hotelyn Figma design
  /// ("Purwokerto, IND" / frame 123:2678).
  static const defaultFallback = UserLocation(
    latitude: -7.4243,
    longitude: 109.2391,
    cityName: 'Purwokerto, IND',
    isManualFallback: true,
  );

  /// Predefined common destinations for quick manual selection.
  static const List<UserLocation> fallbackOptions = [
    defaultFallback,
    UserLocation(
      latitude: -6.2088,
      longitude: 106.8456,
      cityName: 'Jakarta, IND',
      isManualFallback: true,
    ),
    UserLocation(
      latitude: -8.4095,
      longitude: 115.1889,
      cityName: 'Bali, IND',
      isManualFallback: true,
    ),
    UserLocation(
      latitude: -7.7956,
      longitude: 110.3695,
      cityName: 'Yogyakarta, IND',
      isManualFallback: true,
    ),
  ];

  final double latitude;
  final double longitude;
  final String cityName;
  final bool isManualFallback;

  UserLocation copyWith({
    double? latitude,
    double? longitude,
    String? cityName,
    bool? isManualFallback,
  }) {
    return UserLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      isManualFallback: isManualFallback ?? this.isManualFallback,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'cityName': cityName,
      'isManualFallback': isManualFallback,
    };
  }

  @override
  List<Object?> get props => [latitude, longitude, cityName, isManualFallback];
}
