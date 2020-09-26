import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/keys.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/repository/auth_repository.dart';
import 'package:dispatcher/rsa/rsa_key_helper.dart';
import 'package:dispatcher/rsa/rsa_utils.dart';
import 'package:dispatcher/views/auth/create/create.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:hive/hive.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:meta/meta.dart';
import 'package:pointycastle/export.dart' as rsa;

part 'create_event.dart';
part 'create_state.dart';

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
        // Generate the keys
        rsa.AsymmetricKeyPair<rsa.PublicKey, rsa.PrivateKey> keyPair =
            getKeyPair();

        // Store the private key
        Box<Dispatcher> appBox = Hive.box<Dispatcher>(HiveBoxes.APP_BOX);
        appBox.add(
          Dispatcher(
            privateKey: encodePrivatePem(keyPair.privateKey),
          ),
        );

        // Gets the phone number data
        PhoneNumber phoneNumber =
            await PhoneNumber.getRegionInfoFromPhoneNumber(
                state.phone.value.phoneNumber, 'US'); // TODO!

        // Builds the user data map
        Map<String, dynamic> userData = Map<String, dynamic>.from({
          'displayName': state.name.value,
          'password': state.password.value,
          'email': state.email.value,
          'phone': {
            'dial_code': phoneNumber.dialCode,
            'iso_code': phoneNumber.isoCode,
            'phone_number': phoneNumber.phoneNumber,
          },
          'pubkey': RsaKeyHelper().encodePublicKeyToPem(keyPair.publicKey)
        });

        // Runs the 'callableUsersCreate' Firebase callable function
        final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
          functionName: 'callableUsersCreate',
        );

        // Post the user data to Firebase
        await callable.call(userData);

        // Login
        await _authRepository.logIn(
          email: state.email.value,
          password: state.password.value,
        );

        yield state.copyWith(status: FormzStatus.submissionSuccess);
      } on Exception catch (_) {
        yield state.copyWith(status: FormzStatus.submissionFailure);
      }
    }
  }
}
