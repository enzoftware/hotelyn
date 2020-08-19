import 'package:buscatelo/bloc/hotel_bloc.dart';
import 'package:buscatelo/data/repository/remote_hotel_repository.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton(() => RemoteHotelRepository());
  getIt.registerFactory(() => HotelBloc());
}
