import 'package:hotelyn_domain/src/room.dart';
import 'package:hotelyn_domain/src/staff_room.dart';

/// Access to rooms — guest-facing availability and the staff inventory view.
///
/// A shared-vocabulary contract implemented by the service layer (BE-902).
/// Domain types only.
abstract class RoomRepository {
  /// Rooms for [hotelId], each with its computed guest-facing `availableNow`
  /// flag. Omit [hotelId] for the whole catalogue.
  Future<List<Room>> roomsWithAvailability({String? hotelId});

  /// The acting staff member's own hotel rooms, each with a derived
  /// [RoomStatus]. [actorId] is the calling user; [hotelId] is an optional
  /// admin-only target.
  Future<List<StaffRoom>> staffRooms({
    required String actorId,
    String? hotelId,
  });

  /// Sets [roomId]'s staff availability flag, returning the updated room with
  /// its freshly derived status. [actorId] is the acting staff member.
  Future<StaffRoom> setRoomAvailability({
    required String actorId,
    required String roomId,
    required bool isAvailable,
  });
}
