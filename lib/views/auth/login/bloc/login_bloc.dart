import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dispatcher/repository/auth_repository.dart';
import 'package:dispatcher/views/auth/login/login.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

Logger _logger = Logger();

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc({
    @required AuthRepository authRepository,
  })  : assert(authRepository != null),
        _authRepository = authRepository,
        super(const LoginState());

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is LoginEmailChanged) {
      yield _mapEmailChangedToState(event, state);
    } else if (event is LoginPasswordChanged) {
      yield _mapPasswordChangedToState(event, state);
    } else if (event is LoginSubmitted) {
      yield* _mapLoginSubmittedToState(event, state);
    }
  }

  LoginState _mapEmailChangedToState(
    LoginEmailChanged event,
    LoginState state,
  ) {
    final Email email = Email.dirty(event.email);

    return state.copyWith(
      email: email,
      status: Formz.validate([state.password, email]),
    );
  }

  LoginState _mapPasswordChangedToState(
    LoginPasswordChanged event,
    LoginState state,
  ) {
    final Password password = Password.dirty(event.password);

    return state.copyWith(
      password: password,
      status: Formz.validate([password, state.email]),
    );
  }

  Stream<LoginState> _mapLoginSubmittedToState(
    LoginSubmitted event,
    LoginState state,
  ) async* {
    if (state.status.isValidated) {
      yield state.copyWith(status: FormzStatus.submissionInProgress);

      try {
        // Login
        await _authRepository.login(
          email: state.email.value,
          password: state.password.value,
        );

        yield state.copyWith(status: FormzStatus.submissionSuccess);
      } on Exception catch (_) {
        _logger.e(_);
        yield state.copyWith(status: FormzStatus.submissionFailure);
      }
    }
  }
}
