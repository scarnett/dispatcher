import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/env_config.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/views/auth/create/bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

Future<HttpsCallableResult> createUser(
  CreateAccountState state,
) async {
  // Gets the phone number data
  PhoneNumber phoneNumber = await PhoneNumber.getRegionInfoFromPhoneNumber(
      state.phone.value.phoneNumber, EnvConfig.DISPATCHER_ISO_CODE);

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String fcmToken = await _firebaseMessaging.getToken();

  // Builds the user data map
  Map<String, dynamic> userData = Map<String, dynamic>.from({
    'display_name': state.name.value,
    'password': state.password.value,
    'email': state.email.value,
    'phone': {
      'dial_code': phoneNumber.dialCode,
      'iso_code': phoneNumber.isoCode,
      'phone_number': phoneNumber.phoneNumber,
    },
    'fcm': {
      'token': fcmToken,
    },
  });

  // Runs the 'callableUsersCreate' Firebase callable function
  final HttpsCallable userCreateCallable = CloudFunctions.instance
      .getHttpsCallable(functionName: 'callableUsersCreate');

  // Post the user data to Firebase
  return userCreateCallable.call(userData);
}

Future<HttpsCallableResult> saveUserKeys(
  Dispatcher appConfig,
) async {
  // Builds the key data map
  Map<String, dynamic> keyData = Map<String, dynamic>.from({
    'identifier': appConfig.identifier,
    'public_key': appConfig.clientKeys.publicKey,
    'sig_registration_id': appConfig.clientKeys.sigRegistrationId,
    'sig_public_key': appConfig.clientKeys.sigPublicKey,
    'sig_signed_public_key': appConfig.clientKeys.sigSignedPublicKey,
    'sig_signed_prekey_signature':
        appConfig.clientKeys.sigSignedPreKeySignature,
    'sig_identity_public_key': appConfig.clientKeys.sigIdentityPublicKey,
    'sig_prekeys': ClientPreKey.toJsonList(appConfig.clientKeys.sigPreKeys),
  });

  // Runs the 'callableUserKeyUpdate' Firebase callable function
  final HttpsCallable userKeyUpdateCallable = CloudFunctions.instance
      .getHttpsCallable(functionName: 'callableUserKeyUpdate');

  // Post the key data to Firebase
  return userKeyUpdateCallable.call(keyData);
}
