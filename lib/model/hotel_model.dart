import 'package:hotel_booking_app/model/amenitie_model.dart';
import 'package:hotel_booking_app/model/review_model.dart';
import 'package:hotel_booking_app/model/room_model.dart';

class HotelModel {
  late String name;
  late String address;
  late String description;
  late String imageUrl;
  late int price;
  late List<Room> rooms;
  late List<Review> reviews;
  late List<Amenitie> amenities;

  HotelModel({
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.rooms,
    required this.reviews,
    required this.price,
    required this.description,
    required this.amenities,
  });

  HotelModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    description = json['description'];
    imageUrl = json['imageUrl'];
    address = json['address'];
    if (json['rooms'] != null) {
      rooms = <Room>[];
      json['rooms'].forEach((v) {
        rooms.add(Room.fromJson(v));
      });
    }
    if (json['reviews'] != null) {
      reviews = <Review>[];
      json['reviews'].forEach((v) {
        reviews.add(Review.fromJson(v));
      });
    }
    if (json['amenities'] != null) {
      amenities = <Amenitie>[];
      json['amenities'].forEach((v) {
        amenities.add(Amenitie.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data['description'] = description;
    data['address'] = address;
    data['imageUrl'] = imageUrl;
    data['rooms'] = rooms.map((v) => v.toJson()).toList();
    data['reviews'] = reviews.map((v) => v.toJson()).toList();
    data['amenities'] = amenities.map((v) => v.toJson()).toList();
    return data;
  }
}
