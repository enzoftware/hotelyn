import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// A configurable in-memory [HotelDataClient] for route tests.
///
/// Each staff method records its last arguments and returns a canned value; set
/// `throwRpc`/`throwGeneric` to make it raise instead. The search-read methods
/// (`nearbyHotels`/`recommendedHotels`/`roomsAvailability`) always return an
/// empty list and are unaffected by either flag.
class FakeHotelDataClient implements HotelDataClient {
  // Recorded arguments.
  String? lastActorId;
  String? lastHotelId;
  String? lastRoomId;
  bool? lastIsAvailable;
  String? lastReservationId;

  // Failure injection.
  Exception? throwGeneric;
  RpcException? throwRpc;

  @override
  Future<List<Hotel>> nearbyHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async =>
      const [];

  @override
  Future<List<Hotel>> recommendedHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async =>
      const [];

  @override
  Future<List<Room>> roomsAvailability({String? hotelId}) async => const [];

  @override
  Future<List<StaffRoom>> staffRoomList({
    required String actorId,
    String? hotelId,
  }) async {
    if (throwRpc != null) throw throwRpc!;
    if (throwGeneric != null) throw throwGeneric!;
    lastActorId = actorId;
    lastHotelId = hotelId;
    return const [
      StaffRoom(
        id: 'r1',
        hotelId: 'h1',
        name: '101',
        roomType: 'double',
        capacity: 2,
        pricePerNight: 180,
        isAvailable: true,
        status: RoomStatus.available,
      ),
    ];
  }

  @override
  Future<StaffRoom> setRoomAvailability({
    required String actorId,
    required String roomId,
    required bool isAvailable,
  }) async {
    if (throwRpc != null) throw throwRpc!;
    if (throwGeneric != null) throw throwGeneric!;
    lastActorId = actorId;
    lastRoomId = roomId;
    lastIsAvailable = isAvailable;
    return StaffRoom(
      id: roomId,
      hotelId: 'h1',
      name: '101',
      roomType: 'double',
      capacity: 2,
      pricePerNight: 180,
      isAvailable: isAvailable,
      status: isAvailable ? RoomStatus.available : RoomStatus.unavailable,
    );
  }

  @override
  Future<Reservation> confirmReservation({
    required String actorId,
    required String reservationId,
  }) async {
    if (throwRpc != null) throw throwRpc!;
    if (throwGeneric != null) throw throwGeneric!;
    lastActorId = actorId;
    lastReservationId = reservationId;
    return _reservation(reservationId, ReservationStatus.confirmed);
  }

  @override
  Future<Reservation> rejectReservation({
    required String actorId,
    required String reservationId,
  }) async {
    if (throwRpc != null) throw throwRpc!;
    if (throwGeneric != null) throw throwGeneric!;
    lastActorId = actorId;
    lastReservationId = reservationId;
    return _reservation(reservationId, ReservationStatus.rejected);
  }

  @override
  Future<Reservation> markReservationPaid({
    required String actorId,
    required String reservationId,
  }) async {
    if (throwRpc != null) throw throwRpc!;
    if (throwGeneric != null) throw throwGeneric!;
    lastActorId = actorId;
    lastReservationId = reservationId;
    // A paid reservation is confirmed and carries audit metadata, so route
    // tests can assert the serialized paid_by/paid_at survive the round-trip.
    return _reservation(
      reservationId,
      ReservationStatus.confirmed,
      paidBy: actorId,
      paidAt: DateTime.utc(2026, 9, 1, 10, 30),
    );
  }

  Reservation _reservation(
    String id,
    ReservationStatus status, {
    String? paidBy,
    DateTime? paidAt,
  }) =>
      Reservation(
        id: id,
        hotelId: 'h1',
        roomId: 'r1',
        guestId: 'g1',
        status: status,
        checkIn: DateTime.utc(2026, 9),
        checkOut: DateTime.utc(2026, 9, 3),
        paidBy: paidBy,
        paidAt: paidAt,
      );
}
