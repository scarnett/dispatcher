import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/env_config.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/views/home/settings/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:meta/meta.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState());

  @override
  Stream<SettingsState> mapEventToState(
    SettingsEvent event,
  ) async* {
    if (event is SettingsChanged) {
      yield _mapSettingsChangedToState(event, state);
    } else if (event is SettingsNameChanged) {
      yield _mapNameChangedToState(event, state);
    } else if (event is SettingsEmailChanged) {
      yield _mapEmailChangedToState(event, state);
    } else if (event is SettingsPhoneChanged) {
      yield _mapPhoneChangedToState(event, state);
    } else if (event is SettingsSubmitted) {
      yield* _mapCreateSubmittedToState(event, state);
    }
  }

  SettingsState _mapSettingsChangedToState(
    SettingsChanged event,
    SettingsState state,
  ) {
    final Name name = Name.dirty(event.user.name);
    final Email email = Email.dirty(event.user.email);
    final Phone phone = Phone.dirty(event.user.phone.toPhoneNumber());

    return state.copyWith(
      name: name,
      email: email,
      phone: phone,
      status: Formz.validate([state.email, name, state.phone]),
    );
  }

  SettingsState _mapNameChangedToState(
    SettingsNameChanged event,
    SettingsState state,
  ) {
    final Name name = Name.dirty(event.name);

    return state.copyWith(
      name: name,
      status: Formz.validate([state.email, name, state.phone]),
    );
  }

  SettingsState _mapEmailChangedToState(
    SettingsEmailChanged event,
    SettingsState state,
  ) {
    final Email email = Email.dirty(event.email);

    return state.copyWith(
      email: email,
      status: Formz.validate([email, state.name, state.phone]),
    );
  }

  SettingsState _mapPhoneChangedToState(
    SettingsPhoneChanged event,
    SettingsState state,
  ) {
    final Phone phone = Phone.dirty(event.phone);

    return state.copyWith(
      phone: phone,
      status: Formz.validate([state.email, state.name, phone]),
    );
  }

  Stream<SettingsState> _mapCreateSubmittedToState(
    SettingsSubmitted event,
    SettingsState state,
  ) async* {
    if (state.status.isValidated) {
      yield state.copyWith(status: FormzStatus.submissionInProgress);

      try {
        // Gets the phone number data
        PhoneNumber phoneNumber =
            await PhoneNumber.getRegionInfoFromPhoneNumber(
                state.phone.value.phoneNumber, EnvConfig.DISPATCHER_ISO_CODE);

        // Builds the user data map
        Map<dynamic, dynamic> userData = Map<dynamic, dynamic>.from({
          'identifier': event.identifier,
          'name': state.name.value,
          'email': state.email.value,
          'phone': {
            'dial_code': phoneNumber.dialCode,
            'iso_code': phoneNumber.isoCode,
            'phone_number': phoneNumber.phoneNumber,
          },
        });

        // Runs the 'callableUsersUpdate' Firebase callable function
        final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
          functionName: 'callableUsersUpdate',
        );

        // Post the user data to Firebase
        await callable.call(userData);

        yield state.copyWith(status: FormzStatus.submissionSuccess);
      } on Exception catch (_) {
        yield state.copyWith(status: FormzStatus.submissionFailure);
      }
    }
  }
}
