part of 'create_bloc.dart';

@immutable
class CreateAccountState extends Equatable {
  final FormzStatus status;
  final Name name;
  final Email email;
  final Password password;
  final Phone phone;

  const CreateAccountState({
    this.status = FormzStatus.pure,
    this.name = const Name.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.phone = const Phone.pure(),
  });

  CreateAccountState copyWith({
    FormzStatus status,
    Name name,
    Email email,
    Password password,
    Phone phone,
  }) =>
      CreateAccountState(
        status: status ?? this.status,
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        phone: phone ?? this.phone,
      );

  @override
  List<Object> get props => [status, name, email, password, phone];

  @override
  String toString() =>
      'CreateAccountState{status: $status, name: $name, email: $email, phone: $phone}';
}
