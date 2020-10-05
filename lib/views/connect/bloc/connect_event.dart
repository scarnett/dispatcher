part of 'connect_bloc.dart';

abstract class ConnectEvent extends Equatable {
  const ConnectEvent();

  @override
  List<Object> get props => [];
}

class LookupUser extends ConnectEvent {
  final firebase.User firebaseUser;
  final String inviteCode;

  const LookupUser(
    this.firebaseUser,
    this.inviteCode,
  );

  @override
  List<Object> get props => [firebaseUser, inviteCode];
}

class ConnectUser extends ConnectEvent {
  final String userId;
  final String connectUserId;

  const ConnectUser(
    this.userId,
    this.connectUserId,
  );

  @override
  List<Object> get props => [userId, connectUserId];
}

class ClearConnect extends ConnectEvent {
  const ClearConnect();
}
