import 'package:buscatelo/data/repository/hotel_repository.dart';
import 'package:buscatelo/model/hotel_model.dart';

class MockHotelRepository extends HotelRepository {
  @override
  Future<List<HotelModel>> fetchHotels() async {
    await Future.delayed(Duration(seconds: 1));
    return [
      HotelModel(
        name: 'ArtHouse New York City',
        address: '90% Upper West Side',
        price: 1440,
        imageUrl:
            'https://q-cf.bstatic.com/images/hotel/max1024x768/209/209735787.jpg',
      ),
      HotelModel(
        name: 'ArtHouse New York City',
        address: '90% Upper West Side',
        price: 1440,
        imageUrl:
            'https://q-cf.bstatic.com/images/hotel/max1024x768/163/163564419.jpg',
      ),
      HotelModel(
        name: 'ArtHouse New York City',
        address: '90% Upper West Side',
        price: 1440,
        imageUrl: 'https://minthotel.pe/wp-content/uploads/2019/04/Mint-7b.jpg',
      ),
      HotelModel(
        name: 'ArtHouse New York City',
        address: '90% Upper West Side',
        price: 1440,
        imageUrl:
            'https://thumbs.dreamstime.com/b/pasillo-del-hotel-39479289.jpg',
      ),
    ];
  }
}
