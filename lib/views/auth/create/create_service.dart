import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/env_config.dart';
import 'package:dispatcher/storage/storage.dart';
import 'package:dispatcher/views/auth/create/bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart' as signal;

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

Future<HttpsCallableResult> saveKeys(
  firebase.User firebaseUser,
) async {
  // Generate the user pgp keypair
  DispatcherKeyStore keyStore = DispatcherKeyStore();
  await keyStore.generateUserKeys(firebaseUser);

  // Generate the signal keys and prekeys
  DispatcherIdentityKeyStore identityKeyStore = DispatcherIdentityKeyStore();
  DispatcherSignedPreKeyStore signedPreKeyStore = DispatcherSignedPreKeyStore();
  signal.SignedPreKeyRecord signedPreKey =
      signedPreKeyStore.loadSignedPreKey(0);

  List<dynamic> preKeys = [];
  DispatcherPreKeyStore preKeyStore = DispatcherPreKeyStore();
  preKeyStore.store.getKeys().forEach((String key) {
    signal.PreKeyRecord preKey = preKeyStore.loadPreKey(int.parse(key));
    preKeys.add({
      'key_id': preKey.id,
      'public_key': String.fromCharCodes(preKey.serialize()),
    });
  });

  // Builds the key data map
  Map<String, dynamic> keyData = Map<String, dynamic>.from({
    'identifier': firebaseUser.uid,
    'public_key': keyStore.getPublicKey(),
    'sig_registration_id': identityKeyStore.getLocalRegistrationId(),
    'sig_signed_public_key':
        String.fromCharCodes(signedPreKey.getKeyPair().publicKey.serialize()),
    'sig_signed_prekey_signature': String.fromCharCodes(signedPreKey.signature),
    'sig_identity_public_key': String.fromCharCodes(
        identityKeyStore.getIdentityKeyPair().getPublicKey().serialize()),
    'sig_prekeys': preKeys,
  });

  final HttpsCallable userKeyUpdateCallable = CloudFunctions.instance
      .getHttpsCallable(functionName: 'callableUserKeyUpdate');

  // Post the keys to Firebase
  return userKeyUpdateCallable.call(keyData);
}
