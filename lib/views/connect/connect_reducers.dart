import 'package:dispatcher/views/connect/connect_actions.dart';
import 'package:dispatcher/views/connect/connect_state.dart';
import 'package:redux/redux.dart';

final connectReducer = combineReducers<ConnectState>([
  TypedReducer<ConnectState, LookupDeviceByInviteCodeSuccessAction>(
      _lookupDeviceByInviteCode),
  TypedReducer<ConnectState, CancelLookupDeviceByInviteCodeAction>(
      _cancelConnectContactAction),
  TypedReducer<ConnectState, ConnectDeviceSuccessAction>(
      _connectDeviceSuccessAction),
  TypedReducer<ConnectState, AlreadyConnectedAction>(_alreadyConnectedAction),
  TypedReducer<ConnectState, CantConnectAction>(_cantConnectAction),
]);

ConnectState _lookupDeviceByInviteCode(
  ConnectState state,
  LookupDeviceByInviteCodeSuccessAction action,
) =>
    state.copyWith(
      lookupResult: action.device,
    );

ConnectState _connectDeviceSuccessAction(
  ConnectState state,
  ConnectDeviceSuccessAction action,
) =>
    state.copyWith(
      lookupResult: state.lookupResult,
      connected: true,
    );

ConnectState _cancelConnectContactAction(
  ConnectState state,
  CancelLookupDeviceByInviteCodeAction action,
) =>
    state.copyWith(
      lookupResult: null,
      alreadyConnected: false,
      cantConnect: false,
      connected: false,
    );

ConnectState _alreadyConnectedAction(
  ConnectState state,
  AlreadyConnectedAction action,
) =>
    state.copyWith(
      lookupResult: action.device,
      alreadyConnected: true,
    );

ConnectState _cantConnectAction(
  ConnectState state,
  CantConnectAction action,
) =>
    state.copyWith(
      lookupResult: null,
      cantConnect: true,
    );
