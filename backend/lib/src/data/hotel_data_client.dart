import 'dart:async';

import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:supabase/supabase.dart';

/// A business-rule failure raised by a SQL RPC (e.g. `not_authorized`,
/// `room_not_found`, `hold_expired`).
///
/// [code] is the Postgres exception message the function raised — a stable,
/// machine-readable token the route handlers map to an HTTP status. Distinct
/// from an infrastructure failure (timeout, connection), which surfaces as the
/// underlying error.
class RpcException implements Exception {
  const RpcException(this.code);

  /// The RPC's raised message token, e.g. `'not_authorized'`.
  final String code;

  @override
  String toString() => 'RpcException($code)';
}

/// Read-only access to Hotelyn's geolocation-search data.
///
/// This is the single seam through which the REST route handlers reach
/// Supabase; no `supabase` call originates outside an implementation of this
/// interface.
abstract class HotelDataClient {
  /// Hotels within [radiusKm] of ([lat], [lng]), nearest-first
  /// (via `nearby_hotels`).
  Future<List<Hotel>> nearbyHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  });

  /// Popular-yet-nearby hotels within [radiusKm] (`recommended_hotels`).
  Future<List<Hotel>> recommendedHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  });

  /// Rooms (optionally for a single [hotelId]) with computed `available_now`
  /// (`rooms_with_availability`).
  Future<List<Room>> roomsAvailability({String? hotelId});

  /// The acting staff member's own hotel rooms with a derived status
  /// (`staff_room_list`). [actorId] is the calling user's id; [hotelId] is an
  /// optional admin-only target. Throws [RpcException] on `not_authorized`.
  Future<List<StaffRoom>> staffRoomList({
    required String actorId,
    String? hotelId,
  });

  /// Sets a room's availability flag (`set_room_availability`), returning the
  /// updated room with its freshly derived status. Throws [RpcException] with
  /// `not_authorized`, `room_not_found`, or `room_has_active_reservation`.
  Future<StaffRoom> setRoomAvailability({
    required String actorId,
    required String roomId,
    required bool isAvailable,
  });

  /// Confirms a held reservation (`confirm_reservation`). Throws [RpcException]
  /// with `not_authorized`, `reservation_not_found`, `reservation_not_held`, or
  /// `hold_expired`.
  Future<Reservation> confirmReservation({
    required String actorId,
    required String reservationId,
  });

  /// Rejects a reservation and frees the room (`reject_reservation`). Throws
  /// [RpcException] with `not_authorized`, `reservation_not_found`, or
  /// `reservation_not_active`.
  Future<Reservation> rejectReservation({
    required String actorId,
    required String reservationId,
  });

  /// Marks a held reservation paid in person (`mark_reservation_paid`),
  /// transitioning it to `confirmed` and stamping who/when. Throws
  /// [RpcException] with `not_authorized`, `reservation_not_found`, or
  /// `reservation_not_payable`.
  Future<Reservation> markReservationPaid({
    required String actorId,
    required String reservationId,
  });
}

/// [HotelDataClient] backed by Supabase RPC calls to the SQL functions.
class SupabaseHotelDataClient implements HotelDataClient {
  const SupabaseHotelDataClient(
    this._client, {
    this.requestTimeout = const Duration(seconds: 10),
  });

  final SupabaseClient _client;

  /// Upper bound on a single RPC round-trip. A slow or unreachable Supabase
  /// makes the call fail fast with a [TimeoutException] — which route handlers
  /// turn into a `500` — instead of hanging the request indefinitely.
  final Duration requestTimeout;

  @override
  Future<List<Hotel>> nearbyHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  }) =>
      _hotelsFromRpc('nearby_hotels', lat: lat, lng: lng, radiusKm: radiusKm);

  @override
  Future<List<Hotel>> recommendedHotels({
    required double lat,
    required double lng,
    required double radiusKm,
  }) =>
      _hotelsFromRpc(
        'recommended_hotels',
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
      );

  /// Shared radius-search plumbing: `nearby_hotels` and `recommended_hotels`
  /// take the same params and row shape, differing only in ranking.
  Future<List<Hotel>> _hotelsFromRpc(
    String function, {
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    final rows = await _client.rpc<List<dynamic>>(
      function,
      params: {'lat': lat, 'lng': lng, 'radius_km': radiusKm},
    ).timeout(requestTimeout);
    return rows
        .map((row) => Hotel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Room>> roomsAvailability({String? hotelId}) async {
    final rows = await _client.rpc<List<dynamic>>(
      'rooms_with_availability',
      params: {'p_hotel_id': hotelId},
    ).timeout(requestTimeout);
    return rows
        .map((row) => Room.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<StaffRoom>> staffRoomList({
    required String actorId,
    String? hotelId,
  }) async {
    final rows = await _rpcList(
      'staff_room_list',
      params: {'p_actor': actorId, 'p_hotel_id': hotelId},
    );
    return rows
        .map((row) => StaffRoom.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StaffRoom> setRoomAvailability({
    required String actorId,
    required String roomId,
    required bool isAvailable,
  }) async {
    final rows = await _rpcList(
      'set_room_availability',
      params: {
        'p_actor': actorId,
        'p_room_id': roomId,
        'p_is_available': isAvailable,
      },
    );
    return StaffRoom.fromJson(_singleRow(rows, 'set_room_availability'));
  }

  @override
  Future<Reservation> confirmReservation({
    required String actorId,
    required String reservationId,
  }) async {
    final rows = await _rpcList(
      'confirm_reservation',
      params: {'p_actor': actorId, 'p_id': reservationId},
    );
    return Reservation.fromJson(_singleRow(rows, 'confirm_reservation'));
  }

  @override
  Future<Reservation> rejectReservation({
    required String actorId,
    required String reservationId,
  }) async {
    final rows = await _rpcList(
      'reject_reservation',
      params: {'p_actor': actorId, 'p_id': reservationId},
    );
    return Reservation.fromJson(_singleRow(rows, 'reject_reservation'));
  }

  @override
  Future<Reservation> markReservationPaid({
    required String actorId,
    required String reservationId,
  }) async {
    final rows = await _rpcList(
      'mark_reservation_paid',
      params: {'p_actor': actorId, 'p_id': reservationId},
    );
    return Reservation.fromJson(_singleRow(rows, 'mark_reservation_paid'));
  }

  /// Unwraps the single row a mutating RPC is expected to return. These
  /// functions raise (→ [RpcException]) on every failure path, so a non-1 row
  /// count means an unexpected SQL contract change — surfaced as an
  /// [RpcException] rather than an opaque `StateError` from `.single`.
  Map<String, dynamic> _singleRow(List<dynamic> rows, String function) {
    if (rows.length != 1) {
      throw RpcException('${function}_unexpected_row_count');
    }
    return rows.first as Map<String, dynamic>;
  }

  /// Calls a set-returning RPC, translating a raised SQL exception into a typed
  /// [RpcException] (its message is a stable token like `not_authorized`).
  Future<List<dynamic>> _rpcList(
    String function, {
    required Map<String, dynamic> params,
  }) async {
    try {
      return await _client
          .rpc<List<dynamic>>(function, params: params)
          .timeout(requestTimeout);
    } on PostgrestException catch (error) {
      throw RpcException(error.message);
    }
  }
}
