import 'package:equatable/equatable.dart';

/// A bookable room belonging to a hotel.
///
/// [isAvailable] is the room's static flag; [availableNow] also accounts for
/// active (unexpired) holds and confirmed bookings — see the `available_now`
/// computation (BE-302).
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

  final String id;
  final String hotelId;
  final String name;
  final String roomType;
  final int capacity;
  final double pricePerNight;
  final bool isAvailable;
  final bool availableNow;

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
