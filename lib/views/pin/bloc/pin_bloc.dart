import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dispatcher/extensions/extensions.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:dispatcher/utils/config_utils.dart';
import 'package:dispatcher/utils/crypt_utils.dart';
import 'package:dispatcher/views/pin/pin_config.dart';
import 'package:dispatcher/views/pin/pin_enums.dart';
import 'package:dispatcher/views/pin/pin_extensions.dart';
import 'package:dispatcher/views/pin/pin_service.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

part 'pin_event.dart';
part 'pin_state.dart';

class PINBloc extends Bloc<PINEvent, PINState> {
  PINBloc() : super(PINState.initial());

  @override
  Stream<PINState> mapEventToState(
    PINEvent event,
  ) async* {
    if (event is LoadUserPIN) {
      yield* _mapLoadPINToState(event);
    } else if (event is SendVerificationCode) {
      yield* _mapSendVerificationCodeToState(event, state);
    } else if (event is ResendVerificationCode) {
      yield* _mapResendVerificationCodeToState(event, state);
    } else if (event is VerificationCodeChanged) {
      if (event.verificationCode.length == PINConfig.VERIFICATION_CODE_LENGTH) {
        yield _mapVerificationCodeChangedToState(event, state);
      } else {
        yield _mapClearVerificationCodeToState(event, state);
      }
    } else if (event is VerifyVerificationCodeSubmitted) {
      yield* _mapVerifyVerificationCodeSubmittedToState(event, state);
    } else if (event is PINCodeChanged) {
      if (event.pinCode.length == PINConfig.PIN_CODE_LENGTH) {
        yield _mapPINCodeChangedToState(event, state);
      }
    } else if (event is PINSubmitted) {
      yield* _mapPINSubmittedToState(event, state);
    } else if (event is ResetVerificationCodeVerified) {
      yield* _mapResetVerificationCodeVerifiedToState(event);
    } else if (event is ResetPINCodeSaved) {
      yield* _mapResetPINCodeSavedToState(event);
    } else if (event is ClearPIN) {
      yield* _mapClearPINToState(event, state);
    }
  }

  Stream<PINState> _mapLoadPINToState(
    LoadUserPIN event,
  ) async* {
    // Check to see if the expiration date has ellapsed
    UserPIN pin = await tryGetPIN(event.firebaseUser);
    if (pin.isExpired()) {
      await resetVerificationCode(event.firebaseUser.uid);
    } else {
      yield state.copyWith(
        pin: pin,
        loaded: Nullable<bool>(true),
      );
    }
  }

  Stream<PINState> _mapSendVerificationCodeToState(
    SendVerificationCode event,
    PINState state,
  ) async* {
    yield state.copyWith(
        eventType:
            Nullable<PINEventType>(PINEventType.SENDING_VERIFICATION_CODE));

    Tuple2<String, DateTime> data =
        await sendVerification(event.user, event.i18n);

    // Update the state
    yield state.copyWith(
      pin: UserPIN(
        verificationCode: data.item1,
        verificationExpireDate: data.item2,
      ),
      eventType: null,
    );
  }

  Stream<PINState> _mapResendVerificationCodeToState(
    ResendVerificationCode event,
    PINState state,
  ) async* {
    yield state.copyWith(
        eventType:
            Nullable<PINEventType>(PINEventType.RESENDING_VERIFICATION_CODE));

    String verificationCode;
    if (state.verificationCode.isNullEmptyOrWhitespace) {
      if (!state.pin.verificationCode.isNullEmptyOrWhitespace) {
        Dispatcher appData = getAppConfig(event.user.identifier);
        verificationCode = await decrypt(
          state.pin.verificationCode,
          decode(appData.privateKey),
          event.user.identifier,
        );
      }
    } else {
      verificationCode = state.verificationCode;
    }

    if (verificationCode.isNullEmptyOrWhitespace) {
      yield PINState.clear();
    } else {
      await resendVerification(event.user, event.i18n, verificationCode);
      yield state.copyWith(eventType: null);
    }
  }

  PINState _mapVerificationCodeChangedToState(
    VerificationCodeChanged event,
    PINState state,
  ) =>
      state.copyWith(
          verificationCode: Nullable<String>(event.verificationCode));

  PINState _mapClearVerificationCodeToState(
    VerificationCodeChanged event,
    PINState state,
  ) =>
      state.copyWith(verificationCode: Nullable<String>(null));

  Stream<PINState> _mapVerifyVerificationCodeSubmittedToState(
    VerifyVerificationCodeSubmitted event,
    PINState state,
  ) async* {
    yield state.copyWith(
        eventType:
            Nullable<PINEventType>(PINEventType.VERIFYING_VERIFICATION_CODE));

    Dispatcher appData = getAppConfig(event.user.identifier);
    String decryptedVerificationCode = await decrypt(
      state.pin.verificationCode,
      decode(appData.privateKey),
      event.user.identifier,
    );

    if (decryptedVerificationCode == state.verificationCode) {
      yield state.copyWith(
        verificationCodeVerified: Nullable<bool>(true),
        eventType: null,
      );
    } else {
      yield state.copyWith(
        verificationCodeVerified: Nullable<bool>(false),
        eventType: null,
      );
    }
  }

  PINState _mapPINCodeChangedToState(
    PINCodeChanged event,
    PINState state,
  ) =>
      state.copyWith(pinCode: event.pinCode);

  Stream<PINState> _mapPINSubmittedToState(
    PINSubmitted event,
    PINState state,
  ) async* {
    yield state.copyWith(
        eventType: Nullable<PINEventType>(PINEventType.SAVING_PINCODE));

    await updatePIN(event.user, state.pinCode);
    yield state.copyWith(
      verificationCodeVerified: Nullable<bool>(false),
      pinCodeSaved: Nullable<bool>(true),
      eventType: null,
    );
  }

  Stream<PINState> _mapResetVerificationCodeVerifiedToState(
    ResetVerificationCodeVerified event,
  ) async* {
    yield state.copyWith(
      verificationCodeVerified: Nullable<bool>(null),
    );
  }

  Stream<PINState> _mapResetPINCodeSavedToState(
    ResetPINCodeSaved event,
  ) async* {
    yield state.copyWith(
      pinCodeSaved: Nullable<bool>(null),
    );
  }

  Stream<PINState> _mapClearPINToState(
    ClearPIN event,
    PINState state,
  ) async* {
    if (state.pin.isExpired()) {
      await resetVerificationCode(event.user.identifier);
    }

    yield PINState.clear();
  }
}
