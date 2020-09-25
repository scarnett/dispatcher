part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class SettingsChanged extends SettingsEvent {
  final User user;

  const SettingsChanged(
    this.user,
  );

  @override
  List<Object> get props => [user];
}

class SettingsNameChanged extends SettingsEvent {
  final String name;

  const SettingsNameChanged(
    this.name,
  );

  @override
  List<Object> get props => [name];
}

class SettingsEmailChanged extends SettingsEvent {
  final String email;

  const SettingsEmailChanged(
    this.email,
  );

  @override
  List<Object> get props => [email];
}

class SettingsPhoneChanged extends SettingsEvent {
  final PhoneNumber phone;

  const SettingsPhoneChanged(
    this.phone,
  );

  @override
  List<Object> get props => [phone];
}

class SettingsSubmitted extends SettingsEvent {
  final String identifier;

  const SettingsSubmitted(
    this.identifier,
  );

  @override
  List<Object> get props => [identifier];
}
