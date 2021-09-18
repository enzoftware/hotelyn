// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      message: json['message'] as String?,
      user: json['user'] as String?,
      userImage: json['userImage'] as String?,
      rate: json['rate'] as int?,
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'message': instance.message,
      'user': instance.user,
      'userImage': instance.userImage,
      'rate': instance.rate,
    };
