import 'package:bloc_test/bloc_test.dart';
import 'package:hotelyn/core/domain/repository/auth_repository.dart';
import 'package:hotelyn/core/domain/repository/intro_repository.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:mocktail/mocktail.dart';

class MockPreferenceRepository extends Mock implements IntroRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockClarityService extends Mock implements ClarityService {}

class MockLocationRepository extends Mock implements LocationRepository {}

class MockLocationService extends Mock implements LocationService {}

class MockLocationCubit extends MockCubit<LocationState>
    implements LocationCubit {}
