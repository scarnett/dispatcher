import 'package:dispatcher/app.dart';
import 'package:dispatcher/config.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/store.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  Store<AppState> store = await createStore(development: false);

  // PROD Environment Specific Configuration
  AppConfig config = AppConfig(
    flavor: Flavor.RELEASE,
    child: DispatcherApp(store: store),
  );

  runApp(config);
}
