import 'package:hotelyn/core/domain/hotel/hotel.dart';

final mockHotels = <Hotel>[
  Hotel(
    name: 'Hotel 1',
    price: '230.1',
    location: 'Av. Peru 123, Lima.',
    perks: [
      HotelPerk(name: 'Pool', iconData: 'pool.png'),
      HotelPerk(name: 'Breakfast', iconData: 'breakfast.png'),
      HotelPerk(name: 'Spa', iconData: 'spa.png')
    ],
  ),
];
