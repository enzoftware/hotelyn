import 'package:buscatelo/features/home/provider/hotel_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../dependecies.dart';
import 'mock_hotel_repository.dart';

void main() {
  setupTestDependencies();
  group('Hotel list page loads', () {
    var hotelProvider = getIt<HotelProvider>();

    test('Loads hotels from repository', () async {
      await hotelProvider.retrieveHotels();
      expect(hotelProvider.hotels?.isNotEmpty, isTrue);
    });

    test('Expecting values from hotel list', () async {
      await hotelProvider.retrieveHotels();
      assert(hotelProvider.hotels != null);
      expect(hotelProvider.hotels?.length, MockHotelRepository.hotels.length);
      expect(hotelProvider.hotels?[0].price, 10);
      expect(hotelProvider.hotels?[0].name, 'ArtHouse');
    });
  });
}
