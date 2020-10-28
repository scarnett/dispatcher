import 'package:dispatcher/config.dart';
import 'package:dispatcher/models/models.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> initializeHive() async {
  await Hive.initFlutter();
  // Hive.deleteFromDisk();

  Hive
    ..registerAdapter(DispatcherAdapter())
    ..registerAdapter(ClientKeysAdapter())
    ..registerAdapter(ClientPreKeyAdapter());

  await Hive.openBox<Dispatcher>(HiveBoxes.APP_BOX.toString());
}
