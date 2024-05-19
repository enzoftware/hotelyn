import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User(
    this.phone,
    this.photoUrl, {
    required this.name,
    required this.lastName,
  });

  final String name;
  final String lastName;
  final String phone;
  final String photoUrl;

  @override
  List<Object?> get props => [name, lastName, phone, photoUrl];
}
