import 'package:dispatcher/device/device_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class DeviceState {
  final Device device;
  final List<DeviceConnection> connections;

  DeviceState({
    @required this.device,
    @required this.connections,
  });

  factory DeviceState.initial() => DeviceState(
        device: Device(),
        connections: <DeviceConnection>[],
      );

  DeviceState copyWith({
    dynamic device,
    dynamic connections,
  }) =>
      DeviceState(
        device: device ?? this.device,
        connections: connections ?? this.connections,
      );

  static DeviceState fromJson(
    dynamic json,
  ) {
    if ((json == null) || !json.containsKey('device')) {
      return DeviceState.initial();
    }

    return DeviceState(
      device: Device.fromJson(json['device']),
      connections: DeviceConnection.fromJsonList(json['connections']),
    );
  }

  dynamic toJson() => {
        'device': device.toJson(),
        'connections': DeviceConnection.toJsonList(connections),
      };
}
