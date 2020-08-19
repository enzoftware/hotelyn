import 'package:buscatelo/bloc/hotel_bloc.dart';
import 'file:///Users/enzoftware/Projects/hotel_booking_app/test/bloc/mock_hotel_repository.dart';
import 'package:buscatelo/dependencies.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setupDependencies();
  var hotelBloc = getIt<HotelBloc>();
  hotelBloc.repository = MockHotelRepository();

  group('Hotel list page loads', () {
    test('Loads hotels from repository', () async {
      await hotelBloc.retrieveHotels();
      expect(hotelBloc.hotels.length, 4);
    });

    test('Expecting values from hotel list', () async {
      await hotelBloc.retrieveHotels();
      assert(hotelBloc.hotels != null);
      expect(hotelBloc.hotels[0].price, 10);
      expect(hotelBloc.hotels[0].name, 'ArtHouse');

      expect(hotelBloc.hotels[1].price, 20);
      expect(hotelBloc.hotels[1].name, 'SportHouse');

      expect(hotelBloc.hotels[2].price, 30);
      expect(hotelBloc.hotels[2].name, 'PartyHouse');

      expect(hotelBloc.hotels[3].price, 40);
      expect(hotelBloc.hotels[3].name, 'MusicHouse');
    });
  });
}
