import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotelyn/core/services/clarity_service.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc({
    required ClarityService clarityService,
  }) : super(PaymentInitial()) {
    clarityService.setCurrentScreenName('Payment');
    on<PaymentStarted>((event, emit) {});
  }
}
