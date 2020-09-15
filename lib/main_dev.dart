import 'package:bloc/bloc.dart';
import 'package:dispatcher/app.dart';
import 'package:dispatcher/blocs/bloc_observer.dart';
import 'package:dispatcher/config.dart';
import 'package:dispatcher/services/shared_preference_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();

  await Firebase.initializeApp();
  await sharedPreferenceService.getSharedPreferencesInstance();

  // DEV Environment Specific Configuration
  AppConfig config = AppConfig(
    flavor: Flavor.DEVELOPMENT,
    child: DispatcherApp(
      token: await sharedPreferenceService.token,
    ),
  );

  runApp(config);
}
