import 'package:dispatcher/storage/storage.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

class DispatcherSignalProtocolStore implements SignalProtocolStore {
  final DispatcherSessionStore _sessionStore = DispatcherSessionStore();
  final DispatcherPreKeyStore _preKeyStore = DispatcherPreKeyStore();
  final DispatcherSignedPreKeyStore _signedPreKeyStore =
      DispatcherSignedPreKeyStore();

  DispatcherIdentityKeyStore _identityKeyStore;

  DispatcherSignalProtocolStore(
    IdentityKeyPair identityKeyPair,
    int registrationId,
  ) {
    _identityKeyStore =
        DispatcherIdentityKeyStore.write(identityKeyPair, registrationId);
  }

  @override
  IdentityKeyPair getIdentityKeyPair() =>
      _identityKeyStore.getIdentityKeyPair();

  @override
  int getLocalRegistrationId() => _identityKeyStore.getLocalRegistrationId();

  @override
  bool saveIdentity(
    SignalProtocolAddress address,
    IdentityKey identityKey,
  ) =>
      _identityKeyStore.saveIdentity(address, identityKey);

  @override
  bool isTrustedIdentity(
    SignalProtocolAddress address,
    IdentityKey identityKey,
    Direction direction,
  ) =>
      _identityKeyStore.isTrustedIdentity(address, identityKey, direction);

  @override
  IdentityKey getIdentity(
    SignalProtocolAddress address,
  ) =>
      _identityKeyStore.getIdentity(address);

  @override
  PreKeyRecord loadPreKey(
    int preKeyId,
  ) =>
      _preKeyStore.loadPreKey(preKeyId);

  @override
  void storePreKey(
    int preKeyId,
    PreKeyRecord record,
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
  SessionRecord loadSession(
    SignalProtocolAddress address,
  ) =>
      _sessionStore.loadSession(address);

  @override
  List<int> getSubDeviceSessions(
    String name,
  ) =>
      _sessionStore.getSubDeviceSessions(name);

  @override
  void storeSession(
    SignalProtocolAddress address,
    SessionRecord record,
  ) =>
      _sessionStore.storeSession(address, record);

  @override
  bool containsSession(
    SignalProtocolAddress address,
  ) =>
      _sessionStore.containsSession(address);

  @override
  void deleteSession(
    SignalProtocolAddress address,
  ) =>
      _sessionStore.deleteSession(address);

  @override
  void deleteAllSessions(
    String name,
  ) =>
      _sessionStore.deleteAllSessions(name);

  @override
  SignedPreKeyRecord loadSignedPreKey(
    int signedPreKeyId,
  ) =>
      _signedPreKeyStore.loadSignedPreKey(signedPreKeyId);

  @override
  List<SignedPreKeyRecord> loadSignedPreKeys() =>
      _signedPreKeyStore.loadSignedPreKeys();

  @override
  void storeSignedPreKey(
    int signedPreKeyId,
    SignedPreKeyRecord record,
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
