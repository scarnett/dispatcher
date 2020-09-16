part of 'create_bloc.dart';

abstract class CreateAccountEvent extends Equatable {
  const CreateAccountEvent();

  @override
  List<Object> get props => [];
}

class CreateAccountNameChanged extends CreateAccountEvent {
  final String name;

  const CreateAccountNameChanged(
    this.name,
  );

  @override
  List<Object> get props => [name];
}

class CreateAccountEmailChanged extends CreateAccountEvent {
  final String email;

  const CreateAccountEmailChanged(
    this.email,
  );

  @override
  List<Object> get props => [email];
}

class CreateAccountPasswordChanged extends CreateAccountEvent {
  final String password;

  const CreateAccountPasswordChanged(
    this.password,
  );

  @override
  List<Object> get props => [password];
}

class CreateAccountPhoneChanged extends CreateAccountEvent {
  final PhoneNumber phone;

  const CreateAccountPhoneChanged(
    this.phone,
  );

  @override
  List<Object> get props => [phone];
}

class CreateAccountSubmitted extends CreateAccountEvent {
  const CreateAccountSubmitted();
}
