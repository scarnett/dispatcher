import 'dart:io';
import 'dart:typed_data';
import 'package:get_storage/get_storage.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

class DispatcherSessionStore extends SessionStore {
  final GetStorage store = GetStorage('ClientSessions');

  DispatcherSessionStore();

  @override
  bool containsSession(
    SignalProtocolAddress address,
  ) =>
      store.hasData(address.getName());

  @override
  void deleteAllSessions(
    String name,
  ) {
    for (String key in store.getKeys().toList()) {
      if (key == name) {
        store.remove(key);
      }
    }
  }

  @override
  void deleteSession(
    SignalProtocolAddress address,
  ) =>
      store.remove(address.getName());

  @override
  List<int> getSubDeviceSessions(
    String name,
  ) {
    List<int> deviceIds = <int>[];

    for (String key in store.getKeys()) {
      if (key == name) {
        SignalProtocolAddress address = store.read(key);
        if (address.getDeviceId() != 1) {
          deviceIds.add(address.getDeviceId());
        }
      }
    }

    return deviceIds;
  }

  @override
  SessionRecord loadSession(
    SignalProtocolAddress address,
  ) {
    try {
      if (containsSession(address)) {
        List<dynamic> sessionDynList = store.read(address.getName());

        if (sessionDynList == null) {
          throw InvalidKeyIdException('No session found');
        }

        List<int> sessionIntList = sessionDynList.map((s) => s as int).toList();
        return SessionRecord.fromSerialized(Uint8List.fromList(sessionIntList));
      }

      return SessionRecord();
    } on IOException catch (e) {
      throw AssertionError(e);
    }
  }

  @override
  void storeSession(
    SignalProtocolAddress address,
    SessionRecord record,
  ) =>
      store.write(address.getName(), record.serialize().toList());
}
