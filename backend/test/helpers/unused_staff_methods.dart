import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// Base fake for route tests that only exercise the guest-facing search reads.
///
/// Implements the staff [HotelDataClient] methods as throwing stubs so a test
/// that accidentally reaches one fails loudly instead of passing quietly. The
/// search-read methods are left abstract for the subclass to supply.
abstract class UnusedStaffMethodsBase implements HotelDataClient {
  @override
  Future<List<StaffRoom>> staffRoomList({
    required String actorId,
    String? hotelId,
  }) =>
      throw UnimplementedError();

  @override
  Future<StaffRoom> setRoomAvailability({
    required String actorId,
    required String roomId,
    required bool isAvailable,
  }) =>
      throw UnimplementedError();

  @override
  Future<Reservation> confirmReservation({
    required String actorId,
    required String reservationId,
  }) =>
      throw UnimplementedError();

  @override
  Future<Reservation> rejectReservation({
    required String actorId,
    required String reservationId,
  }) =>
      throw UnimplementedError();
}
