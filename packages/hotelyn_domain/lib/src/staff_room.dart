import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'staff_room.g.dart';

/// Derived inventory status of a room, as staff see it (BE-501).
///
/// Computed with the query-time expiry rule: a lapsed hold counts as
/// [available], not [held]. Precedence when several could apply: a
/// staff-disabled room is always [unavailable]; otherwise an active confirmed
/// booking is [occupied], an active hold is [held], else [available].
enum RoomStatus {
  available,
  unavailable,
  held,
  occupied,
}

/// A room in a hotel's own inventory view, with its [status].
///
/// Returned by the staff room-list endpoint. Unlike `Room` (the guest-facing
/// shape with a boolean `available_now`), this carries the richer four-state
/// [status] used on the dashboard.
///
/// JSON keys are snake_case to match the REST API / Postgres row shape.
@JsonSerializable(fieldRename: FieldRename.snake)
class StaffRoom extends Equatable {
  const StaffRoom({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.roomType,
    required this.capacity,
    required this.pricePerNight,
    required this.isAvailable,
    required this.status,
  });

  /// Decodes a `StaffRoom` from a REST/RPC JSON row.
  factory StaffRoom.fromJson(Map<String, dynamic> json) =>
      _$StaffRoomFromJson(json);

  final String id;
  final String hotelId;
  final String name;
  final String roomType;
  final int capacity;
  final double pricePerNight;

  /// The staff-controlled availability flag (BE-502). Distinct from [status],
  /// which also folds in active reservations.
  final bool isAvailable;

  /// The derived four-state status shown on the dashboard.
  final RoomStatus status;

  /// Encodes this `StaffRoom` to a snake_case JSON map.
  Map<String, dynamic> toJson() => _$StaffRoomToJson(this);

  @override
  List<Object?> get props => [
        id,
        hotelId,
        name,
        roomType,
        capacity,
        pricePerNight,
        isAvailable,
        status,
      ];
}
