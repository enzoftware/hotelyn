import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'room.g.dart';

/// A bookable room belonging to a hotel.
///
/// [isAvailable] is the room's static flag; [availableNow] also accounts for
/// active (unexpired) holds and confirmed bookings — see the `available_now`
/// computation (BE-302).
///
/// JSON keys are snake_case to match the REST API / Postgres row shape
/// (`hotel_id`, `price_per_night`, `available_now`, …).
@JsonSerializable(fieldRename: FieldRename.snake)
class Room extends Equatable {
  const Room({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.roomType,
    required this.capacity,
    required this.pricePerNight,
    required this.isAvailable,
    required this.availableNow,
  });

  /// Decodes a `Room` from a REST/RPC JSON row.
  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  final String id;
  final String hotelId;
  final String name;
  final String roomType;
  final int capacity;
  final double pricePerNight;
  final bool isAvailable;
  final bool availableNow;

  /// Encodes this `Room` to a snake_case JSON map.
  Map<String, dynamic> toJson() => _$RoomToJson(this);

  @override
  List<Object?> get props => [
        id,
        hotelId,
        name,
        roomType,
        capacity,
        pricePerNight,
        isAvailable,
        availableNow,
      ];
}
