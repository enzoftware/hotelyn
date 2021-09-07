import 'package:buscatelo/features/home/provider/hotel_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../dependecies.dart';

void main() {
  setupTestDependencies();
  group('Hotel list page loads', () {
    var hotelBloc = getIt<HotelProvider>();

    test('Loads hotels from repository', () async {
      await hotelBloc.retrieveHotels();
      expect(hotelBloc.hotels!.length, 4);
    });

    test('Expecting values from hotel list', () async {
      await hotelBloc.retrieveHotels();
      assert(hotelBloc.hotels != null);
      expect(hotelBloc.hotels![0].price, 10);
      expect(hotelBloc.hotels![0].name, 'ArtHouse');

      expect(hotelBloc.hotels![1].price, 20);
      expect(hotelBloc.hotels![1].name, 'SportHouse');

      expect(hotelBloc.hotels![2].price, 30);
      expect(hotelBloc.hotels![2].name, 'PartyHouse');

      expect(hotelBloc.hotels![3].price, 40);
      expect(hotelBloc.hotels![3].name, 'MusicHouse');
    });
  });
}
