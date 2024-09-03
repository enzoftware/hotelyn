import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.name,
    required this.lastName,
    required this.photoUrl,
    required this.phone,
    required this.email,
  });

  final String name;
  final String lastName;
  final String phone;
  final String photoUrl;
  final String email;

  @override
  List<Object?> get props => [name, lastName, phone, photoUrl, email];
}
