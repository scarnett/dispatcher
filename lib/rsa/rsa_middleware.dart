import 'dart:async';
import 'package:dispatcher/actions.dart';
import 'package:dispatcher/device/device_actions.dart';
import 'package:dispatcher/routes.dart';
import 'package:dispatcher/rsa/rsa_keys.dart';
import 'package:dispatcher/rsa/rsa_utils.dart';
import 'package:dispatcher/state.dart';
import 'package:pointycastle/export.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RsaMiddleware extends MiddlewareClass<AppState> {
  final SharedPreferences sharedPrefs;

  RsaMiddleware(
    this.sharedPrefs,
  );

  @override
  Future<void> call(
    Store<AppState> store,
    dynamic action,
    NextDispatcher next,
  ) async {
    if (action is RegisterDeviceSuccessAction) {
      await _generateKeyPair(action, store);
    }

    next(action);
  }

  Future _generateKeyPair(
    RegisterDeviceSuccessAction action,
    Store<AppState> store,
  ) async {
    // Generate the rsa keypair
    AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = getKeyPair();

    // Save the public key to firebase
    store.dispatch(SaveDeviceAction(action.id, {
      'public_key': encodePublicPem(keyPair.publicKey),
    }));

    // Save the private key to the shared preferences
    await sharedPrefs.setString(
        RSAKeys.APP_RSA_KEY, encodePrivatePem(keyPair.privateKey));

    // Request the device, connections, and redirect
    store.dispatch(RequestDeviceAction(action.device.identifier));
    store.dispatch(RequestDeviceConnectionsAction(action.device.id));
    store.dispatch(NavigatePushAction(AppRoutes.home));
  }
}
