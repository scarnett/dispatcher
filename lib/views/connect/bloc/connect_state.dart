part of 'connect_bloc.dart';

@immutable
class ConnectState extends Equatable {
  final User lookupUser;
  final ConnectStatus status;
  final ConnectEventType eventType;

  const ConnectState._({
    this.lookupUser,
    this.status,
    this.eventType,
  });

  const ConnectState.initial() : this._();

  const ConnectState.clear() : this._();

  ConnectState copyWith({
    User lookupUser,
    Nullable<ConnectStatus> status,
    Nullable<ConnectEventType> eventType,
  }) =>
      ConnectState._(
        lookupUser: lookupUser ?? this.lookupUser,
        status: (status == null) ? this.status : status.value,
        eventType: (eventType == null) ? this.eventType : eventType.value,
      );

  @override
  List<Object> get props => [lookupUser, status, eventType];

  @override
  String toString() =>
      'ConnectState{lookupUser: $lookupUser, status: $status, ' +
      'eventType: $eventType}';
}
