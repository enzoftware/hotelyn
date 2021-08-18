import 'dart:convert';

import 'package:buscatelo/data/network/hotel_api.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

void main() {
  test('Testing the network call', () async {
    final apiProvider = HotelApi();
    apiProvider.client = MockClient((request) async {
      var mockJsonResponse = [
        {'name': 'hotel A', 'price': 100},
        {'name': 'hotel B', 'price': 200},
        {'name': 'hotel C', 'price': 300},
      ];
      return Response(json.encode(mockJsonResponse), 200);
    });
    var hotels = await apiProvider.getHotels();
    expect(hotels.length, 3);

    for (var i = 0; i < hotels.length; i++) {
      assert(hotels[i].name.isNotEmpty);
    }
  });
}
