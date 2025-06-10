import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';
import 'package:hotelyn/core/domain/repository/user_repository.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(LoadingAuthStatus()) {
    on<FetchAuthenticationStatus>(_onFetchAuthenticationStatus);
  }
  final UserRepository _userRepository;

  FutureOr<void> _onFetchAuthenticationStatus(
    FetchAuthenticationStatus event,
    Emitter<AppState> emit,
  ) async {}
}
