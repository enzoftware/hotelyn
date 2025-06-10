part of 'app_bloc.dart';

sealed class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

final class LoadingAuthStatus extends AppState {}

final class AppStateAuthenticated extends AppState {
  const AppStateAuthenticated({required this.user});

  final User user;

  @override
  List<Object> get props => [user];
}

final class AppStateUnauthenticated extends AppState {}

class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
  });
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String zip;
}
