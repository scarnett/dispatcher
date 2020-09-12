import 'package:dispatcher/keys.dart';
import 'package:dispatcher/rsa/rsa_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared preferences service
class SharedPreferenceService {
  SharedPreferences _prefs;

  Future<bool> getSharedPreferencesInstance() async {
    _prefs = await SharedPreferences.getInstance().catchError((e) {
      print('shared prefrences error : $e');
      return false;
    });

    return true;
  }

  Future setToken(
    String token,
  ) async {
    await _prefs.setString(AppKeys.APP_TOKEN, token);
  }

  Future setPrivateKey(
    String privateKey,
  ) async {
    await _prefs.setString(RSAKeys.APP_RSA_KEY, privateKey);
  }

  Future clearToken() async {
    await _prefs.clear();
  }

  Future<String> get token async => _prefs.getString(AppKeys.APP_TOKEN);
  Future<String> get privateKey async => _prefs.getString(RSAKeys.APP_RSA_KEY);
}

SharedPreferenceService sharedPreferenceService = SharedPreferenceService();
