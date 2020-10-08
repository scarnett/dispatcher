import 'package:dispatcher/config.dart';
import 'package:dispatcher/models/models.dart';
import 'package:hive/hive.dart';

Dispatcher getAppConfig(
  String identifier,
) {
  Box<Dispatcher> appBox = Hive.box<Dispatcher>(HiveBoxes.APP_BOX.toString());
  return appBox
      .toMap()
      .entries
      .firstWhere((element) => (element.value.identifier == identifier),
          orElse: () => null)
      .value;
}
