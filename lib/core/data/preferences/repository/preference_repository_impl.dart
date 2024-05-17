import 'package:hotelyn/core/data/preferences/repository/preference_repository.dart';
import 'package:hotelyn/core/data/preferences/sources/preference_local_data_source.dart';

class PreferenceRepositoryImpl extends PreferenceRepository {
  final PreferenceLocalDataSource localDataSource;

  PreferenceRepositoryImpl({required this.localDataSource});

  @override
  Future<bool> isOnBoardingPassed() async {
    return await localDataSource.isOnBoardingPassed();
  }

  @override
  void setOnBoardingPassed() => localDataSource.setOnBoaardingPassed();
}
