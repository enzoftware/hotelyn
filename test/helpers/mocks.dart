import 'package:hotelyn/core/domain/repository/intro_repository.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
import 'package:mocktail/mocktail.dart';

class MockPreferenceRepository extends Mock implements IntroRepository {}

class MockClarityService extends Mock implements ClarityService {}
