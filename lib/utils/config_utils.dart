import 'package:dispatcher/config.dart';
import 'package:dispatcher/models/models.dart';
import 'package:hive/hive.dart';

Dispatcher getAppConfig(
  String identifier,
) {
  Box<Dispatcher> appBox = Hive.box<Dispatcher>(HiveBoxes.APP_BOX.toString());
  MapEntry<dynamic, Dispatcher> appBoxEntries = appBox
      .toMap()
      .entries
      .firstWhere((element) => (element.value.identifier == identifier),
          orElse: () => null);

  if (appBoxEntries == null) {
    return null;
  }

  return appBoxEntries.value;
}

int getAppConfigIndex(
  String identifier,
) {
  Box<Dispatcher> appBox = Hive.box<Dispatcher>(HiveBoxes.APP_BOX.toString());
  Map<dynamic, Dispatcher> appBoxEntries = appBox.toMap();
  if ((appBoxEntries == null) || (appBoxEntries.length == 0)) {
    return -1;
  }

  int count = 0;
  int appConfigIndex = 0;

  appBoxEntries.forEach((dynamic key, Dispatcher appConfig) {
    if (appConfig.identifier == identifier) {
      appConfigIndex = count;
    }

    count++;
  });

  return appConfigIndex;
}
