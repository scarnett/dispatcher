import 'package:dispatcher/utils/crypt_utils.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:get_storage/get_storage.dart';
import 'package:openpgp/key_pair.dart';

class DispatcherKeyStore {
  final GetStorage store = GetStorage('ClientUserKeys');

  DispatcherKeyStore();

  Future<void> generateUserKeys(
    firebase.User firebaseUser,
  ) async {
    if (!store.hasData('publicKey') || !store.hasData('privateKey')) {
      KeyPair keyPair = await generateUserKeyPair(firebaseUser);
      store.write('publicKey', keyPair.publicKey);
      store.write('privateKey', keyPair.privateKey);
    }
  }

  String getPublicKey() => store.read('publicKey');

  String getPrivateKey() => store.read('privateKey');

  bool hasData() => ((getPublicKey() != null) && (getPrivateKey() != null));
}
