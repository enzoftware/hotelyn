import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';
import 'package:hotelyn/features/login/models/email.dart';
import 'package:hotelyn/features/login/models/password.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const LoginState());

  final AuthRepository _authRepository;

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([email, state.password]),
      ),
    );
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(
      state.copyWith(
        password: password,
        isValid: Formz.validate([state.email, password]),
      ),
    );
  }

  Future<void> logInWithCredentials() async {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    emit(
      state.copyWith(
        email: email,
        password: password,
        isValid: Formz.validate([email, password]),
      ),
    );
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      // Perform login and persist user ID with Clarity tracking
      await _authRepository.login();
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on Exception catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}
