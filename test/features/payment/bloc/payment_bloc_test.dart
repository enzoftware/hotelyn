import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
import 'package:hotelyn/features/payment/bloc/payment_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockClarityService extends Mock implements ClarityService {}

void main() {
  group('PaymentBloc', () {
    late ClarityService clarityService;
    late PaymentBloc bloc;

    setUp(() {
      clarityService = MockClarityService();
      bloc = PaymentBloc(clarityService: clarityService);
    });

    test('initial state is PaymentInitial', () {
      expect(bloc.state, PaymentInitial());
    });

    test('calls setCurrentScreenName on initialization', () {
      verify(() => clarityService.setCurrentScreenName('Payment')).called(1);
    });

    blocTest<PaymentBloc, PaymentState>(
      'emits nothing when PaymentStarted is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const PaymentStarted()),
      expect: () => <PaymentState>[],
    );
  });
}
