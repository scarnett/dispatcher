import 'dart:io';
import 'package:device_info/device_info.dart';

Future<String> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor;
  }

  AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
  return androidDeviceInfo.androidId;
}
