import 'package:dispatcher/reducers.dart';
import 'package:dispatcher/sms/sms_middleware.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/views/connect/connect_middleware.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';

const String APP_STATE_KEY = 'APP_STATE';

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
Future<Store<AppState>> createDevStore() async {
  // Build the middleware
  List<Middleware<AppState>> middleware = <Middleware<AppState>>[];

  // Build the middleware
  middleware
    ..addAll([
      EpicMiddleware(
        combineEpics<AppState>([
          ...connectMiddleware,
          ...smsMiddleware,
        ]),
      ),
    ]);

  return _getDefaultStoreConfiguration();
}

Future<Store<AppState>> _getDefaultStoreConfiguration({
  List<Middleware<AppState>> middleware,
}) async {
  return Store(
    appStateReducer,
    initialState: AppState.initial(),
    middleware: (middleware == null)
        ? [
            EpicMiddleware(
              combineEpics<AppState>([
                ...connectMiddleware,
                ...smsMiddleware,
              ]),
            ),
          ]
        : middleware,
  );
}
