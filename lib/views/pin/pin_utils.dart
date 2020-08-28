import 'dart:typed_data';
import 'package:dispatcher/device/device_model.dart';
import 'package:dispatcher/rsa/rsa_key_helper.dart';
import 'package:dispatcher/rsa/rsa_keys.dart';
import 'package:dispatcher/rsa/rsa_utils.dart';
import 'package:pointycastle/export.dart' as rsa;
import 'package:shared_preferences/shared_preferences.dart';

isValidPIN(
  SharedPreferences prefs,
  DevicePIN pin,
  String pinCode,
) {
  rsa.RSAPrivateKey privateKey = RsaKeyHelper()
      .parsePrivateKeyFromPem(prefs.getString(RSAKeys.APP_RSA_KEY));

  String decipheredPINCode = decryptString(
    privateKey,
    Uint8List.fromList(pin.pinCode.codeUnits),
  );

  return (decipheredPINCode == pinCode);
}
