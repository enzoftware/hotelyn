import 'package:equatable/equatable.dart';

class Hotel extends Equatable {
  const Hotel({
    required this.name,
    required this.price,
    required this.location,
    required this.perks,
  });

  final String name;
  final String price;
  final String location;
  final List<Perk> perks;

  @override
  List<Object?> get props => [name, price, location, perks];
}

class Perk extends Equatable {
  const Perk({
    required this.name,
    required this.iconData,
  });

  final String name;
  final String iconData;

  @override
  List<Object?> get props => [name, iconData];
}
