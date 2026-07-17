import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:test/test.dart';

// These tests are the executable proof of the BE-803 contract: each repository
// interface can be implemented with domain types alone — no Supabase, http, or
// Ferry types leak into a signature. If a method's type ever changed to
// something outside hotelyn_domain, these fakes would fail to compile.

class _FakeHotelRepository implements HotelRepository {
  @override
  Future<List<Hotel>> nearbyHotels({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async =>
      const [Hotel(id: 'h1', name: 'Bay', city: 'Lima', country: 'Peru')];

  @override
  Future<List<Hotel>> recommendedHotels({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async =>
      const [];

  @override
  Future<Hotel?> hotelById(String hotelId) async => null;
}

class _FakeRoomRepository implements RoomRepository {
  @override
  Future<List<Room>> roomsWithAvailability({String? hotelId}) async => const [];

  @override
  Future<List<StaffRoom>> staffRooms({
    required String actorId,
    String? hotelId,
  }) async =>
      const [];

  @override
  Future<StaffRoom> setRoomAvailability({
    required String actorId,
    required String roomId,
    required bool isAvailable,
  }) async =>
      StaffRoom(
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

class _FakeReservationRepository implements ReservationRepository {
  @override
  Future<ReservationHold> createHold({
    required String roomId,
    required String guestId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async =>
      ReservationHold(
        id: 'res-1',
        hotelId: 'h1',
        roomId: roomId,
        guestId: guestId,
        checkIn: checkIn,
        checkOut: checkOut,
        expiresAt: DateTime.utc(2026, 9, 1, 0, 15),
        confirmationCode: 'HZ-3F7K9Q2A',
      );

  @override
  Future<List<Reservation>> reservationsForGuest(String guestId) async =>
      const [];

  @override
  Future<Reservation> confirm({
    required String actorId,
    required String reservationId,
  }) async =>
      _reservation(reservationId, ReservationStatus.confirmed);

  @override
  Future<Reservation> reject({
    required String actorId,
    required String reservationId,
  }) async =>
      _reservation(reservationId, ReservationStatus.rejected);

  @override
  Future<Reservation> markPaid({
    required String actorId,
    required String reservationId,
  }) async =>
      Reservation(
        id: reservationId,
        hotelId: 'h1',
        roomId: 'r1',
        guestId: 'g1',
        status: ReservationStatus.confirmed,
        checkIn: DateTime.utc(2026, 9),
        checkOut: DateTime.utc(2026, 9, 3),
        paidBy: actorId,
        paidAt: DateTime.utc(2026, 9, 1, 10, 30),
      );

  Reservation _reservation(String id, ReservationStatus status) => Reservation(
        id: id,
        hotelId: 'h1',
        roomId: 'r1',
        guestId: 'g1',
        status: status,
        checkIn: DateTime.utc(2026, 9),
        checkOut: DateTime.utc(2026, 9, 3),
      );
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<void> requestEmailOtp({required String email}) async {}

  @override
  Future<AuthSession> verifyEmailOtp({
    required String email,
    required String token,
  }) async =>
      _session;

  @override
  Future<AuthSession> signInWithPassword({
    required String email,
    required String password,
  }) async =>
      _session;

  @override
  Future<User?> currentUser(String accessToken) async =>
      User(id: 'u1', role: UserRole.guest);

  static const _session = AuthSession(
    accessToken: 'a',
    refreshToken: 'r',
    userId: 'u1',
    expiresIn: 3600,
    tokenType: 'bearer',
  );
}

class _FakeMessageRepository implements MessageRepository {
  @override
  Future<List<Message>> messagesForReservation(String reservationId) async =>
      const [];

  @override
  Future<Message> sendMessage({
    required String reservationId,
    required String senderId,
    required String body,
  }) async =>
      Message(
        id: 'm1',
        reservationId: reservationId,
        senderId: senderId,
        body: body,
        sentAt: DateTime.utc(2026, 9, 1, 10, 30),
      );
}

void main() {
  group('HotelRepository contract', () {
    final HotelRepository repo = _FakeHotelRepository();

    test('nearbyHotels returns domain Hotels', () async {
      final hotels = await repo.nearbyHotels(
        latitude: -12.11,
        longitude: -77.03,
        radiusKm: 5,
      );
      expect(hotels.single, isA<Hotel>());
    });

    test('hotelById can return null', () async {
      expect(await repo.hotelById('missing'), isNull);
    });
  });

  group('RoomRepository contract', () {
    final RoomRepository repo = _FakeRoomRepository();

    test('setRoomAvailability returns the updated StaffRoom', () async {
      final room = await repo.setRoomAvailability(
        actorId: 'staff-1',
        roomId: 'r1',
        isAvailable: false,
      );
      expect(room.status, RoomStatus.unavailable);
      expect(room.isAvailable, isFalse);
    });
  });

  group('ReservationRepository contract', () {
    final ReservationRepository repo = _FakeReservationRepository();

    test('createHold returns a ReservationHold with a non-null expiry',
        () async {
      final hold = await repo.createHold(
        roomId: 'r1',
        guestId: 'g1',
        checkIn: DateTime.utc(2026, 9),
        checkOut: DateTime.utc(2026, 9, 3),
      );
      expect(hold, isA<ReservationHold>());
      expect(hold.expiresAt, isNotNull);
    });

    test('markPaid returns a confirmed, paid Reservation', () async {
      final reservation =
          await repo.markPaid(actorId: 'staff-1', reservationId: 'res-1');
      expect(reservation.status, ReservationStatus.confirmed);
      expect(reservation.paidBy, 'staff-1');
      expect(reservation.paidAt, isNotNull);
    });
  });

  group('AuthRepository contract', () {
    final AuthRepository repo = _FakeAuthRepository();

    test('verifyEmailOtp returns an AuthSession', () async {
      final session = await repo.verifyEmailOtp(email: 'a@x.com', token: '123');
      expect(session, isA<AuthSession>());
    });

    test('currentUser returns a domain User', () async {
      expect(await repo.currentUser('token'), isA<User>());
    });
  });

  group('MessageRepository contract', () {
    final MessageRepository repo = _FakeMessageRepository();

    test('sendMessage returns the created Message', () async {
      final message = await repo.sendMessage(
        reservationId: 'res-1',
        senderId: 'u1',
        body: 'Hi',
      );
      expect(message.body, 'Hi');
      expect(message.reservationId, 'res-1');
    });
  });
}
