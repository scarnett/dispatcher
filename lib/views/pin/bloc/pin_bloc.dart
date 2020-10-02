import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/graphql/service.dart';
import 'package:dispatcher/graphql/user.dart';
import 'package:dispatcher/hive.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/sms/sms_model.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:dispatcher/utils/date_utils.dart';
import 'package:dispatcher/views/pin/pin_config.dart';
import 'package:dispatcher/views/pin/pin_enums.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:graphql/client.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:openpgp/openpgp.dart';

part 'pin_event.dart';
part 'pin_state.dart';

class PINBloc extends Bloc<PINEvent, PINState> {
  GraphQLService _service;
  Logger _logger = Logger();

  PINBloc() : super(const PINState());

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
      yield* _mapClearPINToState(event);
    }
  }

  Stream<PINState> _mapLoadPINToState(
    LoadUserPIN event,
  ) async* {
    UserPIN pin = await _tryGetPIN(event.firebaseUser);

    // Check to see if the expiration date has ellapsed
    if ((pin != null) && (pin.verificationExpireDate != null)) {
      final DateTime now = getNow();
      if (now.isAfter(pin.verificationExpireDate)) {
        // Builds the PIN data map
        Map<dynamic, dynamic> pinData = Map<dynamic, dynamic>.from({
          'identifier': event.firebaseUser.uid,
          'pin': {
            'verification_code': null,
            'verification_expire_date': null,
          },
        });

        // Runs the 'callableUserPinUpdate' Firebase callable function
        final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
          functionName: 'callableUserPinUpdate',
        );

        // Post the user pin data to Firebase
        await callable.call(pinData);
        yield PINState.saved();
      }
    }

    yield state.copyWith(pin: pin);
  }

  Stream<PINState> _mapSendVerificationCodeToState(
    SendVerificationCode event,
    PINState state,
  ) async* {
    yield PINState.eventType(PINEventType.SENDING_VERIFICATION_CODE);

    String verificationCode =
        getRandomNumber(length: PINConfig.VERIFICATION_CODE_LENGTH);

    String encryptedVerificationCode =
        await OpenPGP.encrypt(verificationCode, event.user.key.publicKey);

    DateTime now = getNow();
    DateTime verificationExpireDate = now.add(Duration(minutes: 10));
    SMS sms = SMS(
      user: event.user.identifier,
      inboundPhone: event.user.phone.phoneNumber,
      body: event.i18n.pinVerificationCodeSMSText(
        AppLocalizations.appTitle,
        verificationCode,
      ),
      sentDate: now,
    );

    // Builds the PIN data map
    Map<String, dynamic> pinData = Map<String, dynamic>.from({
      'identifier': event.user.identifier,
      'verificationCode': encryptedVerificationCode,
      'verificationExpireDate': toIso8601String(verificationExpireDate),
      'sms': sms.toJson(),
    });

    // Runs the 'callableUserPinUpsert' Firebase callable function
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'callableUserPinUpsert',
    );

    // Post the user data to Firebase
    await callable.call(pinData);

    // Update the state
    yield PINState.clearEventType();
    yield state.copyWith(
      pin: UserPIN(
        verificationCode: encryptedVerificationCode,
        verificationExpireDate: verificationExpireDate,
      ),
    );
  }

  Stream<PINState> _mapResendVerificationCodeToState(
    ResendVerificationCode event,
    PINState state,
  ) async* {
    yield PINState.eventType(PINEventType.RESENDING_VERIFICATION_CODE);

    SMS sms = SMS(
      user: event.user.identifier,
      inboundPhone: event.user.phone.phoneNumber,
      body: event.i18n.pinVerificationCodeSMSText(
        AppLocalizations.appTitle,
        state.verificationCode,
      ),
      sentDate: getNow(),
    );

    // Builds the SMS data map
    Map<String, dynamic> smsData = Map<String, dynamic>.from({
      'sms': sms.toJson(),
    });

    // Runs the 'callableSmsSend' Firebase callable function
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'callableSmsSend',
    );

    // Post the sms data to Firebase
    await callable.call(smsData);
    yield PINState.clearEventType();
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
    yield PINState.eventType(PINEventType.VERIFYING_VERIFICATION_CODE);

    Box<Dispatcher> appBox = Hive.box<Dispatcher>(HiveBoxes.APP_BOX);
    String decryptedVerificationCode = await OpenPGP.decrypt(
      state.pin.verificationCode,
      appBox.getAt(0).privateKey,
      event.user.identifier,
    );

    if (decryptedVerificationCode == state.verificationCode) {
      yield state.copyWith(
        verificationCodeVerified: Nullable<bool>(true),
      );
    } else {
      yield state.copyWith(
        verificationCodeVerified: Nullable<bool>(false),
      );
    }

    yield PINState.clearEventType();
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
    yield PINState.eventType(PINEventType.SAVING_PINCODE);

    String encryptedPINCode =
        await OpenPGP.encrypt(state.pinCode, event.user.key.publicKey);

    // Builds the PIN data map
    Map<dynamic, dynamic> pinData = Map<dynamic, dynamic>.from({
      'identifier': event.user.identifier,
      'pin': {
        'pin_code': encryptedPINCode,
        'verification_code': null,
        'verification_expire_date': null,
      },
    });

    // Runs the 'callableUserPinUpdate' Firebase callable function
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'callableUserPinUpdate',
    );

    // Post the user pin data to Firebase
    await callable.call(pinData);

    yield PINState.clearEventType();
    yield state.copyWith(
      verificationCodeVerified: Nullable<bool>(false),
      pinCodeSaved: Nullable<bool>(true),
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
  ) async* {
    yield PINState.clear();
  }

  Future<UserPIN> _tryGetPIN(
    firebase.User firebaseUser,
  ) async {
    try {
      _service = GraphQLService(await firebaseUser.getIdToken());
      final QueryResult result = await _service.performMutation(
        fetchPINQueryStr,
        variables: {
          'identifier': firebaseUser.uid,
        },
      );

      if (result.hasException) {
        _logger.e({
          'graphql': result.exception.graphqlErrors.toString(),
          'client': result.exception.clientException.toString(),
        });
      } else {
        dynamic pins = result.data['user_pins'];
        if ((pins != null) && (pins.length > 0)) {
          return UserPIN.fromJson(pins[0]);
        }

        return null;
      }
    } catch (e) {
      _logger.e(e.toString());
    }

    return null;
  }
}
