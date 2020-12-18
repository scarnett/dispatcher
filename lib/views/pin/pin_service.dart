import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/graphql/service.dart';
import 'package:dispatcher/graphql/user.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:dispatcher/utils/crypt_utils.dart';
import 'package:dispatcher/utils/date_utils.dart';
import 'package:dispatcher/views/pin/bloc/pin_bloc.dart';
import 'package:dispatcher/views/pin/pin_config.dart';
import 'package:graphql/client.dart';
import 'package:logger/logger.dart';
import 'package:tuple/tuple.dart';

Logger _logger = Logger();

Future<UserPIN> tryGetPIN(
  LoadUserPIN event,
) async {
  try {
    GraphQLService service = GraphQLService(event.client);
    final QueryResult result = await service.performQuery(
      fetchPINQueryStr,
      variables: {
        'identifier': event.firebaseUser.uid,
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

Future<Tuple2<String, DateTime>> sendVerification(
  User user,
  AppLocalizations i18n,
) async {
  String verificationCode =
      getRandomNumber(length: PINConfig.VERIFICATION_CODE_LENGTH);

  DateTime now = getNow();
  DateTime verificationExpireDate = now.add(Duration(minutes: 10));
  SMS sms = SMS(
    user: user.identifier,
    inboundPhone: user.phone.phoneNumber,
    body: i18n.pinVerificationCodeSMSText(
      AppLocalizations.appTitle,
      verificationCode,
    ),
    sentDate: now,
  );

  String encryptedVerificationCode =
      await encrypt(verificationCode, user.key.publicKey);

  // Builds the PIN data map
  Map<String, dynamic> pinData = Map<String, dynamic>.from({
    'identifier': user.identifier,
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

  return Tuple2<String, DateTime>(
    encryptedVerificationCode,
    verificationExpireDate,
  );
}

Future<void> resendVerification(
  User user,
  AppLocalizations i18n,
  String verificationCode,
) async {
  SMS sms = SMS(
    user: user.identifier,
    inboundPhone: user.phone.phoneNumber,
    body: i18n.pinVerificationCodeSMSText(
      AppLocalizations.appTitle,
      verificationCode,
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
}

Future<HttpsCallableResult> updatePIN(
  User user,
  String pinCode,
) async {
  String encryptedPINCode = await encrypt(pinCode, user.key.publicKey);

  // Builds the PIN data map
  Map<dynamic, dynamic> pinData = Map<dynamic, dynamic>.from({
    'identifier': user.identifier,
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
  return callable.call(pinData);
}

Future<HttpsCallableResult> resetVerificationCode(
  String identifier,
) {
  // Builds the PIN data map
  Map<dynamic, dynamic> pinData = Map<dynamic, dynamic>.from({
    'identifier': identifier,
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
  return callable.call(pinData);
}
