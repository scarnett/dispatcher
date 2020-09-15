import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SetFormMode extends AuthEvent {
  final AuthFormMode mode;

  const SetFormMode(this.mode);

  @override
  List<Object> get props => [mode];
}

class SetAuthorizing extends AuthEvent {
  final bool authorizing;

  const SetAuthorizing(this.authorizing);

  @override
  List<Object> get props => [authorizing];
}

class SetCreating extends AuthEvent {
  final bool creating;

  const SetCreating(this.creating);

  @override
  List<Object> get props => [creating];
}
