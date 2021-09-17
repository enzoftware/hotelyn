import 'package:hotel_booking_app/data/repository/hotel_repository.dart';
import 'package:hotel_booking_app/model/hotel_model.dart';

class MockHotelRepository extends HotelRepository {
  static final hotels = [
    HotelModel(
        name: 'ArtHouse',
        address: '90% Upper West Side',
        price: 10,
        imageUrl:
            'https://q-cf.bstatic.com/images/hotel/max1024x768/209/209735787.jpg',
        rooms: [],
        amenities: [],
        description: '',
        reviews: []),
    HotelModel(
        name: 'SportHouse',
        address: '90% Upper North Side',
        price: 20,
        imageUrl:
            'https://q-cf.bstatic.com/images/hotel/max1024x768/163/163564419.jpg',
        rooms: [],
        amenities: [],
        description: '',
        reviews: []),
    HotelModel(
        name: 'PartyHouse',
        address: '90% Upper South Side',
        price: 30,
        imageUrl: 'https://minthotel.pe/wp-content/uploads/2019/04/Mint-7b.jpg',
        rooms: [],
        amenities: [],
        description: '',
        reviews: []),
    HotelModel(
        name: 'MusicHouse',
        address: 'Upper East Side',
        price: 40,
        imageUrl:
            'https://thumbs.dreamstime.com/b/pasillo-del-hotel-39479289.jpg',
        rooms: [],
        amenities: [],
        description: '',
        reviews: []),
  ];

  @override
  Future<List<HotelModel>> fetchHotels() async {
    return Future.value(hotels);
  }

  @override
  Future<HotelModel> fetchHotelDetail(String name) {
    return Future.value(hotels[0]);
  }
}
