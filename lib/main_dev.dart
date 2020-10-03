import 'package:bloc/bloc.dart';
import 'package:dispatcher/app.dart';
import 'package:dispatcher/bloc/bloc_observer.dart';
import 'package:dispatcher/config.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/repository/repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();
  HydratedBloc.storage = await HydratedStorage.build();

  await Hive.initFlutter();
  Hive.registerAdapter(DispatcherAdapter());
  await Hive.openBox<Dispatcher>(HiveBoxes.APP_BOX.toString());
  await Firebase.initializeApp();

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
