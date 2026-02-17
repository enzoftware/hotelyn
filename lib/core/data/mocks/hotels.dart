import 'package:hotelyn/core/domain/models/models.dart';

final mockHotels = <Hotel>[
  const Hotel(
    name: 'Grand Plaza Hotel',
    price: '230',
    location: 'Av. Peru 123, Lima',
    perks: [
      Perk(name: 'Pool', iconData: 'pool.png'),
      Perk(name: 'Breakfast', iconData: 'breakfast.png'),
      Perk(name: 'Spa', iconData: 'spa.png'),
    ],
  ),
  const Hotel(
    name: 'Ocean View Resort',
    price: '185',
    location: 'Costa Verde 456, Lima',
    perks: [
      Perk(name: 'Pool', iconData: 'pool.png'),
      Perk(name: 'Breakfast', iconData: 'breakfast.png'),
    ],
  ),
  const Hotel(
    name: 'Mountain Lodge',
    price: '310',
    location: 'Cusco Road 789, Cusco',
    perks: [
      Perk(name: 'Spa', iconData: 'spa.png'),
      Perk(name: 'Breakfast', iconData: 'breakfast.png'),
    ],
  ),
];
