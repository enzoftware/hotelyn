import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'room_model.g.dart';

@JsonSerializable()
class Room extends Equatable {
  const Room({this.imageUrl, this.name});

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  final String? imageUrl;
  final String? name;

  Map<String, dynamic> toJson() => _$RoomToJson(this);

  @override
  List<Object?> get props => [imageUrl, name];
}
