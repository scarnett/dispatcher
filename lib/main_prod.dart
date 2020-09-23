import 'package:bloc/bloc.dart';
import 'package:dispatcher/app.dart';
import 'package:dispatcher/bloc/bloc_observer.dart';
import 'package:dispatcher/config.dart';
import 'package:dispatcher/repository/repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();
  HydratedBloc.storage = await HydratedStorage.build();

  await Firebase.initializeApp();

  // PROD Environment Specific Configuration
  AppConfig config = AppConfig(
    flavor: Flavor.RELEASE,
    child: DispatcherApp(
      authRepository: AuthRepository(),
      userRepository: UserRepository(),
    ),
  );

  runApp(config);
}
