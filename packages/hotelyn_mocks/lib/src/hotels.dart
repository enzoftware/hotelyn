import 'package:hotelyn_models/hotelyn_models.dart';

final mockHotels = <Hotel>[
  const Hotel(
    name: 'Hotel 1',
    price: '230.1',
    location: 'Av. Peru 123, Lima.',
    perks: [
      Perk(name: 'Pool', iconData: 'pool.png'),
      Perk(name: 'Breakfast', iconData: 'breakfast.png'),
      Perk(name: 'Spa', iconData: 'spa.png'),
    ],
  ),
];
