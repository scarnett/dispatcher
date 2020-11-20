import 'package:dispatcher/storage/storage.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart' as signal;

class DispatcherSignalProtocolStore implements signal.SignalProtocolStore {
  final DispatcherPreKeyStore _preKeyStore = DispatcherPreKeyStore();

  final signal.InMemorySessionStore sessionStore =
      signal.InMemorySessionStore();

  final DispatcherSignedPreKeyStore _signedPreKeyStore =
      DispatcherSignedPreKeyStore();

  DispatcherIdentityKeyStore _identityKeyStore;

  DispatcherSignalProtocolStore(
    signal.IdentityKeyPair identityKeyPair,
    int registrationId,
  ) {
    _identityKeyStore =
        DispatcherIdentityKeyStore.write(identityKeyPair, registrationId);
  }

  @override
  signal.IdentityKeyPair getIdentityKeyPair() =>
      _identityKeyStore.getIdentityKeyPair();

  @override
  int getLocalRegistrationId() => _identityKeyStore.getLocalRegistrationId();

  @override
  bool saveIdentity(
    signal.SignalProtocolAddress address,
    signal.IdentityKey identityKey,
  ) =>
      _identityKeyStore.saveIdentity(address, identityKey);

  @override
  bool isTrustedIdentity(
    signal.SignalProtocolAddress address,
    signal.IdentityKey identityKey,
    signal.Direction direction,
  ) =>
      _identityKeyStore.isTrustedIdentity(address, identityKey, direction);

  @override
  signal.IdentityKey getIdentity(
    signal.SignalProtocolAddress address,
  ) =>
      _identityKeyStore.getIdentity(address);

  @override
  signal.PreKeyRecord loadPreKey(
    int preKeyId,
  ) =>
      _preKeyStore.loadPreKey(preKeyId);

  @override
  void storePreKey(
    int preKeyId,
    signal.PreKeyRecord record,
  ) =>
      _preKeyStore.storePreKey(preKeyId, record);

  @override
  bool containsPreKey(
    int preKeyId,
  ) =>
      _preKeyStore.containsPreKey(preKeyId);

  @override
  void removePreKey(
    int preKeyId,
  ) =>
      _preKeyStore.removePreKey(preKeyId);

  @override
  signal.SessionRecord loadSession(
    signal.SignalProtocolAddress address,
  ) =>
      sessionStore.loadSession(address);

  @override
  List<int> getSubDeviceSessions(
    String name,
  ) =>
      sessionStore.getSubDeviceSessions(name);

  @override
  void storeSession(
    signal.SignalProtocolAddress address,
    signal.SessionRecord record,
  ) =>
      sessionStore.storeSession(address, record);

  @override
  bool containsSession(
    signal.SignalProtocolAddress address,
  ) =>
      sessionStore.containsSession(address);

  @override
  void deleteSession(
    signal.SignalProtocolAddress address,
  ) =>
      sessionStore.deleteSession(address);

  @override
  void deleteAllSessions(
    String name,
  ) =>
      sessionStore.deleteAllSessions(name);

  @override
  signal.SignedPreKeyRecord loadSignedPreKey(
    int signedPreKeyId,
  ) =>
      _signedPreKeyStore.loadSignedPreKey(signedPreKeyId);

  @override
  List<signal.SignedPreKeyRecord> loadSignedPreKeys() =>
      _signedPreKeyStore.loadSignedPreKeys();

  @override
  void storeSignedPreKey(
    int signedPreKeyId,
    signal.SignedPreKeyRecord record,
  ) =>
      _signedPreKeyStore.storeSignedPreKey(signedPreKeyId, record);

  @override
  bool containsSignedPreKey(
    int signedPreKeyId,
  ) =>
      _signedPreKeyStore.containsSignedPreKey(signedPreKeyId);

  @override
  void removeSignedPreKey(
    int signedPreKeyId,
  ) =>
      _signedPreKeyStore.removeSignedPreKey(signedPreKeyId);
}
