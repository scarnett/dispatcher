import 'package:dispatcher/device/device_middleware.dart';
import 'package:dispatcher/middleware.dart';
import 'package:dispatcher/reducers.dart';
import 'package:dispatcher/rsa/rsa_middleware.dart';
import 'package:dispatcher/sms/sms_middleware.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/storage/storage_middleware.dart';
import 'package:dispatcher/views/connect/connect_middleware.dart';
import 'package:logging/logging.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'package:redux_remote_devtools/redux_remote_devtools.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String APP_STATE_KEY = 'APP_STATE';
const String REMOTE_HOST = '192.168.0.22:8000'; // TODO! config

/// App store configuration
Future<Store<AppState>> createStore({
  bool development = true,
}) async {
  if (development) {
    return await createDevStore();
  }

  return await createProdStore();
}

/// Production store configuration
Future<Store<AppState>> createProdStore() async {
  return _getDefaultStoreConfiguration();
}

/// Development store configuration
Future<Store<AppState>> createDevStore({
  bool enableLogger = true, // TODO! config
  bool enableRemoteDev = false, // TODO! config
}) async {
  // Build the middleware
  List<Middleware<AppState>> middleware = <Middleware<AppState>>[];

  // Configure the state persistor
  final persistor = Persistor<AppState>(
    storage: FlutterStorage(
      key: APP_STATE_KEY,
      location: FlutterSaveLocation.sharedPreferences,
    ),
    serializer: JsonSerializer<AppState>(AppState.fromJson),
  );

  // Load initial state
  final initialState = await persistor.load();

  // Load shared preferences
  final sharedPrefs = await SharedPreferences.getInstance();

  // Build the middleware
  middleware
    ..addAll([
      ...appMiddleware(),
      EpicMiddleware(
        combineEpics<AppState>([
          ...deviceMiddleware,
          ...connectMiddleware,
          ...smsMiddleware,
        ]),
      ),
      RsaMiddleware(sharedPrefs),
      StorageMiddleware(),
    ]);

  if (enableLogger) {
    // Load the logger
    final Logger logger = Logger('Logger');
    logger.onRecord
        .where((record) => record.loggerName == logger.name)
        .listen((loggingMiddlewareRecord) => print(loggingMiddlewareRecord));

    // Add it to the middleware
    middleware
      ..add(
        LoggingMiddleware(logger: logger),
      );

    return _getDefaultStoreConfiguration(middleware: middleware);
  } else if (enableRemoteDev) {
    RemoteDevToolsMiddleware remoteDevtools =
        RemoteDevToolsMiddleware(REMOTE_HOST);

    await remoteDevtools.connect();

    DevToolsStore<AppState> store = DevToolsStore<AppState>(
      appStateReducer,
      initialState: initialState ?? AppState.initial(),
      middleware: middleware
        ..add(
          remoteDevtools,
        ),
    );

    remoteDevtools.store = store;
    remoteDevtools.connect();
    return store;
  }

  return _getDefaultStoreConfiguration();
}

Future<Store<AppState>> _getDefaultStoreConfiguration({
  List<Middleware<AppState>> middleware,
}) async {
  // Load shared preferences
  final sharedPrefs = await SharedPreferences.getInstance();

  // Configure the state persistor
  final persistor = Persistor<AppState>(
    storage: FlutterStorage(
      key: APP_STATE_KEY,
      location: FlutterSaveLocation.sharedPreferences,
    ),
    serializer: JsonSerializer<AppState>(AppState.fromJson),
  );

  // Load initial state
  final initialState = await persistor.load();

  return Store(
    appStateReducer,
    initialState: initialState ?? AppState.initial(),
    middleware: (middleware == null)
        ? [
            persistor.createMiddleware(),
            ...appMiddleware(),
            EpicMiddleware(
              combineEpics<AppState>([
                ...deviceMiddleware,
                ...connectMiddleware,
                ...smsMiddleware,
              ]),
            ),
            RsaMiddleware(sharedPrefs),
            StorageMiddleware(),
          ]
        : middleware,
  );
}
