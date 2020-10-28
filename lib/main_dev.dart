import 'package:bloc/bloc.dart';
import 'package:dispatcher/app.dart';
import 'package:dispatcher/bloc/bloc_observer.dart';
import 'package:dispatcher/config.dart';
import 'package:dispatcher/repository/repository.dart';
import 'package:dispatcher/utils/crypt_utils.dart';
import 'package:dispatcher/utils/hive_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bloc
  Bloc.observer = AppBlocObserver();
  HydratedBloc.storage = await HydratedStorage.build();

  // Hive
  await initializeHive();

  // Firebase
  await Firebase.initializeApp();

  // Crashlytics
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);

  // Store the client keys
  await storeKeys();

  // Timezone
  tz.initializeTimeZones();

  // DEV Environment Specific Configuration
  AppConfig config = AppConfig(
    flavor: Flavor.dev,
    child: DispatcherApp(
      authRepository: AuthRepository(),
      userRepository: UserRepository(),
    ),
  );

  runApp(config);
}
