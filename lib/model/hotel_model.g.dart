// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotel_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hotel _$HotelFromJson(Map<String, dynamic> json) => Hotel(
      name: json['name'] as String,
      address: json['address'] as String,
      imageUrl: json['imageUrl'] as String,
      rooms: (json['rooms'] as List<dynamic>)
          .map((e) => Room.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>)
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      price: json['price'] as int,
      description: json['description'] as String,
      amenities: (json['amenities'] as List<dynamic>)
          .map((e) => Amenitie.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HotelToJson(Hotel instance) => <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'price': instance.price,
      'rooms': instance.rooms,
      'reviews': instance.reviews,
      'amenities': instance.amenities,
    };
