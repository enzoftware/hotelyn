// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      fullName: json['full_name'] as String?,
      hotelId: json['hotel_id'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'role': _$UserRoleEnumMap[instance.role]!,
      'full_name': instance.fullName,
      'hotel_id': instance.hotelId,
    };

const _$UserRoleEnumMap = {
  UserRole.guest: 'guest',
  UserRole.hotelStaff: 'hotel_staff',
  UserRole.admin: 'admin',
};
