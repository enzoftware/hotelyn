class Hotel {
  Hotel({
    required this.name,
    required this.price,
    required this.location,
    required this.perks,
  });

  final String name;
  final String price;
  final String location;
  final List<HotelPerk> perks;
}

class HotelPerk {
  HotelPerk({
    required this.name,
    required this.iconData,
  });

  final String name;
  final String iconData;
}
