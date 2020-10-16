import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dispatcher/repository/auth_repository.dart';
import 'package:dispatcher/views/auth/create/create.dart';
import 'package:dispatcher/views/auth/create/create_service.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'create_event.dart';
part 'create_state.dart';

Logger _logger = Logger();

class CreateAccountBloc extends Bloc<CreateAccountEvent, CreateAccountState> {
  final AuthRepository _authRepository;

  CreateAccountBloc({
    @required AuthRepository authRepository,
  })  : assert(authRepository != null),
        _authRepository = authRepository,
        super(const CreateAccountState());

  @override
  Stream<CreateAccountState> mapEventToState(
    CreateAccountEvent event,
  ) async* {
    if (event is CreateAccountNameChanged) {
      yield _mapNameChangedToState(event, state);
    } else if (event is CreateAccountEmailChanged) {
      yield _mapEmailChangedToState(event, state);
    } else if (event is CreateAccountPasswordChanged) {
      yield _mapPasswordChangedToState(event, state);
    } else if (event is CreateAccountPhoneChanged) {
      yield _mapPhoneChangedToState(event, state);
    } else if (event is CreateAccountSubmitted) {
      yield* _mapCreateSubmittedToState(event, state);
    }
  }

  CreateAccountState _mapNameChangedToState(
    CreateAccountNameChanged event,
    CreateAccountState state,
  ) {
    final Name name = Name.dirty(event.name);

    return state.copyWith(
      name: name,
      status: Formz.validate([state.password, state.email, name, state.phone]),
    );
  }

  CreateAccountState _mapEmailChangedToState(
    CreateAccountEmailChanged event,
    CreateAccountState state,
  ) {
    final Email email = Email.dirty(event.email);

    return state.copyWith(
      email: email,
      status: Formz.validate([state.password, email, state.name, state.phone]),
    );
  }

  CreateAccountState _mapPasswordChangedToState(
    CreateAccountPasswordChanged event,
    CreateAccountState state,
  ) {
    final Password password = Password.dirty(event.password);

    return state.copyWith(
      password: password,
      status: Formz.validate([password, state.email, state.name, state.phone]),
    );
  }

  CreateAccountState _mapPhoneChangedToState(
    CreateAccountPhoneChanged event,
    CreateAccountState state,
  ) {
    final Phone phone = Phone.dirty(event.phone);

    return state.copyWith(
      phone: phone,
      status: Formz.validate([state.password, state.email, state.name, phone]),
    );
  }

  Stream<CreateAccountState> _mapCreateSubmittedToState(
    CreateAccountSubmitted event,
    CreateAccountState state,
  ) async* {
    if (state.status.isValidated) {
      yield state.copyWith(status: FormzStatus.submissionInProgress);

      try {
        // Create the user
        await createUser(state);

        // Login
        await _authRepository.login(
          email: state.email.value,
          password: state.password.value,
        );

        // Create the user keypair
        await createUserKeyPair();

        yield state.copyWith(status: FormzStatus.submissionSuccess);
      } on Exception catch (_) {
        _logger.e(_);
        yield state.copyWith(status: FormzStatus.submissionFailure);
      }
    }
  }
}
