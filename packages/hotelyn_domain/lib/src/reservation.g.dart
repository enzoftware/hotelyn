// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reservation _$ReservationFromJson(Map<String, dynamic> json) => Reservation(
      id: json['id'] as String,
      hotelId: json['hotel_id'] as String,
      roomId: json['room_id'] as String,
      guestId: json['guest_id'] as String,
      status: $enumDecode(_$ReservationStatusEnumMap, json['status']),
      checkIn: _dateFromJson(json['check_in'] as String),
      checkOut: _dateFromJson(json['check_out'] as String),
      holdExpiresAt: json['hold_expires_at'] == null
          ? null
          : DateTime.parse(json['hold_expires_at'] as String),
      confirmationCode: json['confirmation_code'] as String?,
      paidBy: json['paid_by'] as String?,
      paidAt: json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
    );

Map<String, dynamic> _$ReservationToJson(Reservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hotel_id': instance.hotelId,
      'room_id': instance.roomId,
      'guest_id': instance.guestId,
      'status': _$ReservationStatusEnumMap[instance.status]!,
      'check_in': _dateToJson(instance.checkIn),
      'check_out': _dateToJson(instance.checkOut),
      'hold_expires_at': instance.holdExpiresAt?.toIso8601String(),
      'confirmation_code': instance.confirmationCode,
      'paid_by': instance.paidBy,
      'paid_at': instance.paidAt?.toIso8601String(),
    };

const _$ReservationStatusEnumMap = {
  ReservationStatus.held: 'held',
  ReservationStatus.confirmed: 'confirmed',
  ReservationStatus.cancelled: 'cancelled',
  ReservationStatus.rejected: 'rejected',
  ReservationStatus.expired: 'expired',
};
