import 'dart:convert';

import 'package:hotelyn_api_client/hotelyn_api_client.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('HotelynApiClient', () {
    HotelynApiClient clientReturning(
      Object body, {
      int statusCode = 200,
      void Function(http.Request request)? onRequest,
    }) {
      final mock = MockClient((request) async {
        onRequest?.call(request);
        return http.Response(
          jsonEncode(body),
          statusCode,
          headers: {'content-type': 'application/json'},
        );
      });
      return HotelynApiClient(
        baseUrl: 'http://127.0.0.1:8080',
        httpClient: mock,
      );
    }

    test('getNearbyHotels hits /hotels/nearby with the radius params',
        () async {
      late Uri captured;
      final client = clientReturning(
        [
          {'id': 'h1', 'name': 'Miraflores', 'city': 'Lima', 'country': 'Peru'},
        ],
        onRequest: (request) => captured = request.url,
      );

      final hotels = await client.getNearbyHotels(
        lat: -12.11,
        lng: -77.03,
        radiusKm: 200,
      );

      expect(captured.path, '/hotels/nearby');
      expect(captured.queryParameters['lat'], '-12.11');
      expect(captured.queryParameters['lng'], '-77.03');
      expect(captured.queryParameters['radiusKm'], '200.0');
      expect(hotels, hasLength(1));
      expect(hotels.first.name, 'Miraflores');
    });

    test('getRecommendedHotels hits /hotels/recommended', () async {
      late Uri captured;
      final client = clientReturning(
        const <dynamic>[],
        onRequest: (request) => captured = request.url,
      );

      await client.getRecommendedHotels(lat: 1, lng: 2, radiusKm: 3);

      expect(captured.path, '/hotels/recommended');
    });

    test('getRooms hits /hotels/{id}/rooms and decodes rooms', () async {
      late Uri captured;
      final client = clientReturning(
        [
          {
            'id': 'r1',
            'hotel_id': 'h1',
            'name': '101',
            'room_type': 'double',
            'capacity': 2,
            'price_per_night': 180.0,
            'is_available': true,
            'available_now': false,
          },
        ],
        onRequest: (request) => captured = request.url,
      );

      final rooms = await client.getRooms(hotelId: 'h1');

      expect(captured.path, '/hotels/h1/rooms');
      expect(rooms.single.availableNow, isFalse);
      expect(rooms.single.pricePerNight, 180.0);
    });

    test('attaches a Bearer token when the provider returns one', () async {
      String? authHeader;
      final mock = MockClient((request) async {
        authHeader = request.headers['Authorization'];
        return http.Response('[]', 200);
      });
      final client = HotelynApiClient(
        baseUrl: 'http://127.0.0.1:8080',
        httpClient: mock,
        tokenProvider: () async => 'jwt-123',
      );

      await client.getNearbyHotels(lat: 0, lng: 0, radiusKm: 1);

      expect(authHeader, 'Bearer jwt-123');
    });

    test('omits the Authorization header when signed out', () async {
      final headers = <String, String>{};
      final mock = MockClient((request) async {
        headers.addAll(request.headers);
        return http.Response('[]', 200);
      });
      final client = HotelynApiClient(
        baseUrl: 'http://127.0.0.1:8080',
        httpClient: mock,
        tokenProvider: () async => null,
      );

      await client.getNearbyHotels(lat: 0, lng: 0, radiusKm: 1);

      expect(headers.containsKey('Authorization'), isFalse);
    });

    test('throws ApiException with the status code on a non-2xx', () async {
      final client = clientReturning(
        {
          'errors': [
            {'message': 'boom'},
          ],
        },
        statusCode: 500,
      );

      await expectLater(
        client.getNearbyHotels(lat: 0, lng: 0, radiusKm: 1),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.message, 'message', 'boom'),
        ),
      );
    });

    test('throws ApiException when the body is not a JSON array', () async {
      final client = clientReturning({'not': 'an array'});

      await expectLater(
        client.getNearbyHotels(lat: 0, lng: 0, radiusKm: 1),
        throwsA(isA<ApiException>()),
      );
    });

    group('createReservationHold', () {
      const heldRow = {
        'id': 'res-1',
        'hotel_id': 'h1',
        'room_id': 'r1',
        'guest_id': 'g1',
        'status': 'held',
        'check_in': '2026-09-01',
        'check_out': '2026-09-03',
        'hold_expires_at': '2026-09-01T00:15:00Z',
        'confirmation_code': 'HZ-3F7K9Q2A',
      };

      test('POSTs to /hotels/{id}/holds and decodes the reservation', () async {
        late http.Request captured;
        final client = clientReturning(
          heldRow,
          statusCode: 201,
          onRequest: (request) => captured = request,
        );

        final reservation = await client.createReservationHold(
          hotelId: 'h1',
          roomId: 'r1',
          checkIn: DateTime.utc(2026, 9),
          checkOut: DateTime.utc(2026, 9, 3),
        );

        expect(captured.method, 'POST');
        expect(captured.url.path, '/hotels/h1/holds');
        final body = jsonDecode(captured.body) as Map<String, dynamic>;
        expect(body['room_id'], 'r1');
        // Dates are sent as bare YYYY-MM-DD, not full timestamps.
        expect(body['check_in'], '2026-09-01');
        expect(body['check_out'], '2026-09-03');
        expect(reservation.status, ReservationStatus.held);
        expect(reservation.confirmationCode, 'HZ-3F7K9Q2A');
        expect(reservation.holdExpiresAt, isNotNull);
      });

      test('maps a 409 to a typed RoomAlreadyHeldException', () async {
        final client = clientReturning(
          {
            'errors': [
              {'message': 'already held'},
            ],
          },
          statusCode: 409,
        );

        await expectLater(
          client.createReservationHold(
            hotelId: 'h1',
            roomId: 'r1',
            checkIn: DateTime.utc(2026, 9),
            checkOut: DateTime.utc(2026, 9, 3),
          ),
          throwsA(
            isA<RoomAlreadyHeldException>()
                // Still an ApiException, so a generic catch also handles it.
                .having((e) => e, 'is an ApiException', isA<ApiException>())
                .having((e) => e.statusCode, 'statusCode', 409)
                .having((e) => e.message, 'message', 'already held'),
          ),
        );
      });

      test('maps other non-2xx to a plain ApiException', () async {
        final client = clientReturning(
          {
            'errors': [
              {'message': 'nope'},
            ],
          },
          statusCode: 400,
        );

        await expectLater(
          client.createReservationHold(
            hotelId: 'h1',
            roomId: 'r1',
            checkIn: DateTime.utc(2026, 9),
            checkOut: DateTime.utc(2026, 9, 3),
          ),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 400)
                .having(
                  (e) => e,
                  'not the held subtype',
                  isNot(isA<RoomAlreadyHeldException>()),
                ),
          ),
        );
      });
    });

    group('staff inventory', () {
      const staffRoomRow = {
        'id': 'r1',
        'hotel_id': 'h1',
        'name': '101',
        'room_type': 'double',
        'capacity': 2,
        'price_per_night': 180.0,
        'is_available': true,
        'status': 'held',
      };

      const reservationRow = {
        'id': 'res-1',
        'hotel_id': 'h1',
        'room_id': 'r1',
        'guest_id': 'g1',
        'status': 'confirmed',
        'check_in': '2026-09-01',
        'check_out': '2026-09-03',
      };

      test('getStaffRooms GETs /staff/rooms and decodes the status', () async {
        late Uri captured;
        final client = clientReturning(
          [staffRoomRow],
          onRequest: (request) => captured = request.url,
        );

        final rooms = await client.getStaffRooms();

        expect(captured.path, '/staff/rooms');
        expect(rooms.single.status, RoomStatus.held);
        expect(rooms.single.isAvailable, isTrue);
      });

      test('setRoomAvailability PATCHes the room and sends the flag', () async {
        late http.Request captured;
        final client = clientReturning(
          {...staffRoomRow, 'is_available': false, 'status': 'unavailable'},
          onRequest: (request) => captured = request,
        );

        final room = await client.setRoomAvailability(
          roomId: 'r1',
          isAvailable: false,
        );

        expect(captured.method, 'PATCH');
        expect(captured.url.path, '/staff/rooms/r1/availability');
        expect(jsonDecode(captured.body), {'is_available': false});
        expect(room.status, RoomStatus.unavailable);
      });

      test('setRoomAvailability surfaces a 409 as an ApiException', () async {
        final client = clientReturning(
          {
            'errors': [
              {'message': 'room has an active reservation'},
            ],
          },
          statusCode: 409,
        );

        await expectLater(
          client.setRoomAvailability(roomId: 'r1', isAvailable: true),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 409)
                // The staff 409 is NOT the hold-specific subtype.
                .having(
                  (e) => e,
                  'not the held subtype',
                  isNot(isA<RoomAlreadyHeldException>()),
                ),
          ),
        );
      });

      test('confirmReservation POSTs to the confirm path', () async {
        late http.Request captured;
        final client = clientReturning(
          reservationRow,
          onRequest: (request) => captured = request,
        );

        final reservation =
            await client.confirmReservation(reservationId: 'res-1');

        expect(captured.method, 'POST');
        expect(captured.url.path, '/reservations/res-1/confirm');
        expect(reservation.status, ReservationStatus.confirmed);
      });

      test('rejectReservation POSTs to the reject path', () async {
        late http.Request captured;
        final client = clientReturning(
          {...reservationRow, 'status': 'rejected'},
          onRequest: (request) => captured = request,
        );

        final reservation =
            await client.rejectReservation(reservationId: 'res-1');

        expect(captured.method, 'POST');
        expect(captured.url.path, '/reservations/res-1/reject');
        expect(reservation.status, ReservationStatus.rejected);
      });
    });
  });
}
