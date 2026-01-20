import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(LoadingAuthStatus()) {
    on<FetchAuthenticationStatus>(_onFetchAuthenticationStatus);
  }

  FutureOr<void> _onFetchAuthenticationStatus(
    FetchAuthenticationStatus event,
    Emitter<AppState> emit,
  ) async {}
}
