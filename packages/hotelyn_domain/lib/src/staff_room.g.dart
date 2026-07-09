// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffRoom _$StaffRoomFromJson(Map<String, dynamic> json) => StaffRoom(
      id: json['id'] as String,
      hotelId: json['hotel_id'] as String,
      name: json['name'] as String,
      roomType: json['room_type'] as String,
      capacity: (json['capacity'] as num).toInt(),
      pricePerNight: (json['price_per_night'] as num).toDouble(),
      isAvailable: json['is_available'] as bool,
      status: $enumDecode(_$RoomStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$StaffRoomToJson(StaffRoom instance) => <String, dynamic>{
      'id': instance.id,
      'hotel_id': instance.hotelId,
      'name': instance.name,
      'room_type': instance.roomType,
      'capacity': instance.capacity,
      'price_per_night': instance.pricePerNight,
      'is_available': instance.isAvailable,
      'status': _$RoomStatusEnumMap[instance.status]!,
    };

const _$RoomStatusEnumMap = {
  RoomStatus.available: 'available',
  RoomStatus.unavailable: 'unavailable',
  RoomStatus.held: 'held',
  RoomStatus.occupied: 'occupied',
};
