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
  final String user;
  final String connectUser;

  const ConnectUser(
    this.user,
    this.connectUser,
  );

  @override
  List<Object> get props => [user, connectUser];
}

class ClearConnect extends ConnectEvent {
  const ClearConnect();
}
