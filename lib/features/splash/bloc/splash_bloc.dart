import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotelyn/core/domain/repository/intro_repository.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc({
    required IntroRepository introRepository,
  })  : _introRepository = introRepository,
        super(SplashInitial()) {
    on<SplashStarted>(_onStartSplash);
  }

  final IntroRepository _introRepository;

  FutureOr<void> _onStartSplash(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    final result = await _introRepository.isIntroPassed();
    final navigateTo = result ? SplashToHome() : SplashToIntro();
    emit(navigateTo);
  }
}
