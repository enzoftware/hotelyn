// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
      id: json['id'] as String,
      hotelId: json['hotel_id'] as String,
      name: json['name'] as String,
      roomType: json['room_type'] as String,
      capacity: (json['capacity'] as num).toInt(),
      pricePerNight: (json['price_per_night'] as num).toDouble(),
      isAvailable: json['is_available'] as bool,
      availableNow: json['available_now'] as bool,
    );

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'id': instance.id,
      'hotel_id': instance.hotelId,
      'name': instance.name,
      'room_type': instance.roomType,
      'capacity': instance.capacity,
      'price_per_night': instance.pricePerNight,
      'is_available': instance.isAvailable,
      'available_now': instance.availableNow,
    };
