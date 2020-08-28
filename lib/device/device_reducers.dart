import 'package:dispatcher/device/device_actions.dart';
import 'package:dispatcher/device/device_model.dart';
import 'package:dispatcher/device/device_state.dart';
import 'package:redux/redux.dart';

final deviceReducer = combineReducers<DeviceState>([
  TypedReducer<DeviceState, RequestDeviceSuccessAction>(_requestDevice),
  TypedReducer<DeviceState, RequestDeviceConnectionsSuccessAction>(
      _requestDeviceConnections),
  TypedReducer<DeviceState, RegisterDeviceSuccessAction>(_registerDevice),
]);

DeviceState _requestDevice(
  DeviceState state,
  RequestDeviceSuccessAction action,
) =>
    state.copyWith(
      device: action.device,
    );

DeviceState _requestDeviceConnections(
  DeviceState state,
  RequestDeviceConnectionsSuccessAction action,
) =>
    state.copyWith(
      connections: action.connections,
    );

DeviceState _registerDevice(
  DeviceState state,
  RegisterDeviceSuccessAction action,
) =>
    state.copyWith(
      device: Device(
        identifier: action.device.identifier,
        publicKey: action.device.publicKey,
      ),
    );
