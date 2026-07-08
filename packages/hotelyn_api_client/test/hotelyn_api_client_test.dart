import 'dart:convert';

import 'package:hotelyn_api_client/hotelyn_api_client.dart';
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
  });
}
