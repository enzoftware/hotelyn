import 'package:equatable/equatable.dart';
import 'package:hotel_booking_app/model/amenitie_model.dart';
import 'package:hotel_booking_app/model/review_model.dart';
import 'package:hotel_booking_app/model/room_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hotel_model.g.dart';

@JsonSerializable()
class Hotel extends Equatable {
  const Hotel({
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.rooms,
    required this.reviews,
    required this.price,
    required this.description,
    required this.amenities,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) => _$HotelFromJson(json);

  factory Hotel.empty() => const Hotel(
        name: 'empty',
        address: '',
        imageUrl: '',
        rooms: [],
        reviews: [],
        price: 0,
        description: '',
        amenities: [],
      );

  final String name;
  final String address;
  final String description;
  final String imageUrl;
  final int price;
  final List<Room> rooms;
  final List<Review> reviews;
  final List<Amenitie> amenities;

  Map<String, dynamic> toJson() => _$HotelToJson(this);

  @override
  List<Object?> get props => [
        name,
        address,
        description,
        imageUrl,
        price,
        rooms,
        reviews,
        amenities,
      ];
}
