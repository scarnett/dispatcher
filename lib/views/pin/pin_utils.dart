import 'dart:typed_data';
import 'package:dispatcher/device/device_model.dart';
import 'package:dispatcher/keys.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/rsa/rsa_key_helper.dart';
import 'package:dispatcher/rsa/rsa_utils.dart';
import 'package:hive/hive.dart';
import 'package:pointycastle/export.dart' as rsa;

isValidPIN(
  DevicePIN pin,
  String pinCode,
) {
  Box<Dispatcher> appBox = Hive.box<Dispatcher>(HiveBoxes.APP_BOX);

  rsa.RSAPrivateKey privateKey =
      RsaKeyHelper().parsePrivateKeyFromPem(appBox.getAt(0).privateKey);

  String decipheredPINCode = decryptString(
    privateKey,
    Uint8List.fromList(pin.pinCode.codeUnits),
  );

  return (decipheredPINCode == pinCode);
}
