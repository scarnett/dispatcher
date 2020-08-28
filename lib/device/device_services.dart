import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dispatcher/device/device_model.dart';

Stream<Device> getDevice(
  String identifier,
) =>
    FirebaseFirestore.instance
        .collection('devices')
        .where('identifier', isEqualTo: identifier)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }

      return Device.fromSnapshot(snapshot.docs.first);
    });

Stream<Device> getDeviceByInviteCode(
  String inviteCode,
) =>
    FirebaseFirestore.instance
        .collection('devices')
        .where('invite_code.code', isEqualTo: inviteCode)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }

      return Device.fromSnapshot(snapshot.docs.first);
    });

Stream<List<DeviceConnection>> getDeviceConnections(
  String deviceId,
) {
  Query query = FirebaseFirestore.instance
      .collection('devices')
      .doc(deviceId)
      .collection('connections');

  return query
      .orderBy('connected_date', descending: true)
      .snapshots()
      .map((QuerySnapshot doc) {
    List<DeviceConnection> connections = List<DeviceConnection>();

    for (DocumentSnapshot document in doc.docs) {
      connections..add(DeviceConnection.fromSnapshot(document));
    }

    return connections;
  });
}

Stream<List<DeviceConnection>> getDeviceRooms(
  String deviceId,
) {
  Query query = FirebaseFirestore.instance
      .collection('devices')
      .doc(deviceId)
      .collection('rooms');

  return query
      .orderBy('created_date', descending: true)
      .snapshots()
      .map((QuerySnapshot doc) {
    List<DeviceConnection> rooms = List<DeviceConnection>();

    for (DocumentSnapshot document in doc.docs) {
      rooms..add(DeviceConnection.fromSnapshot(document));
    }

    return rooms;
  });
}
