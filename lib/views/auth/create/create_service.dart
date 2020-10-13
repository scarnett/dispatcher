import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/config.dart';
import 'package:dispatcher/env_config.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/utils/crypt_utils.dart';
import 'package:dispatcher/views/auth/create/bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:openpgp/key_pair.dart';

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

Future<HttpsCallableResult> createUserKeyPair() async {
  final firebase.FirebaseAuth _firebaseAuth = firebase.FirebaseAuth.instance;
  final firebase.User _firebaseUser = _firebaseAuth.currentUser;

  // Generate the keys
  KeyPair keyPair = await generateKeyPair(_firebaseUser);

  // Store the private key
  Box<Dispatcher> appBox = Hive.box<Dispatcher>(HiveBoxes.APP_BOX.toString());
  appBox.add(
    Dispatcher(
      identifier: _firebaseUser.uid,
      privateKey: encode(keyPair.privateKey),
    ),
  );

  // Builds the user data map
  Map<String, dynamic> userKeyData = Map<String, dynamic>.from({
    'identifier': _firebaseUser.uid,
    'pubkey': encode(keyPair.publicKey),
  });

  // Runs the 'callableUserKeyUpdate' Firebase callable function
  final HttpsCallable userKeyUpdateCallable = CloudFunctions.instance
      .getHttpsCallable(functionName: 'callableUserKeyUpdate');

  // Post the user data to Firebase
  return userKeyUpdateCallable.call(userKeyData);
}
