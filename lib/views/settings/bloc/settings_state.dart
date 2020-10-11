part of 'settings_bloc.dart';

@immutable
class SettingsState extends Equatable {
  final FormzStatus status;
  final Name name;
  final Email email;
  final Phone phone;

  const SettingsState({
    this.status = FormzStatus.pure,
    this.name = const Name.pure(),
    this.email = const Email.pure(),
    this.phone = const Phone.pure(),
  });

  SettingsState copyWith({
    FormzStatus status,
    Name name,
    Email email,
    Phone phone,
  }) =>
      SettingsState(
        status: status ?? this.status,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
      );

  @override
  List<Object> get props => [status, name, email, phone];

  @override
  String toString() =>
      'SettingsState{status: $status, name: $name, email: $email, phone: $phone}';
}
