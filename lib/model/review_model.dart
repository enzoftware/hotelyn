import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_model.g.dart';

@JsonSerializable()
class Review extends Equatable {
  const Review({
    this.message,
    this.user,
    this.userImage,
    this.rate,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  final String? message;
  final String? user;
  final String? userImage;
  final int? rate;

  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  @override
  List<Object?> get props => [message, user, userImage, rate];
}
