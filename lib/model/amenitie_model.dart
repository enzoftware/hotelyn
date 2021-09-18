// ignore_for_file: sort_constructors_first

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'amenitie_model.g.dart';

@JsonSerializable()
class Amenitie extends Equatable {
  const Amenitie({this.name, this.imageUrl});

  final String? name;
  final String? imageUrl;

  factory Amenitie.fromJson(Map<String, dynamic> json) =>
      _$AmenitieFromJson(json);
  Map<String, dynamic> toJson() => _$AmenitieToJson(this);

  @override
  List<Object?> get props => [name, imageUrl];
}
