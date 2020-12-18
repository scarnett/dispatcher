part of 'pin_bloc.dart';

abstract class PINEvent extends Equatable {
  const PINEvent();

  @override
  List<Object> get props => [];
}

class LoadUserPIN extends PINEvent {
  final GraphQLClient client;
  final firebase.User firebaseUser;

  const LoadUserPIN(
    this.client,
    this.firebaseUser,
  );

  @override
  List<Object> get props => [client, firebaseUser];
}

class SendVerificationCode extends PINEvent {
  final User user;
  final AppLocalizations i18n;

  const SendVerificationCode(
    this.user,
    this.i18n,
  );

  @override
  List<Object> get props => [user, i18n];
}

class ResendVerificationCode extends PINEvent {
  final User user;
  final AppLocalizations i18n;

  const ResendVerificationCode(
    this.user,
    this.i18n,
  );

  @override
  List<Object> get props => [user, i18n];
}

class VerificationCodeChanged extends PINEvent {
  final String verificationCode;

  const VerificationCodeChanged(
    this.verificationCode,
  );

  @override
  List<Object> get props => [verificationCode];
}

class VerificationCodeSubmitted extends PINEvent {
  final User user;

  const VerificationCodeSubmitted(
    this.user,
  );

  @override
  List<Object> get props => [user];
}

class VerifyVerificationCodeSubmitted extends PINEvent {
  final User user;

  const VerifyVerificationCodeSubmitted(
    this.user,
  );

  @override
  List<Object> get props => [user];
}

class PINCodeChanged extends PINEvent {
  final String pinCode;

  const PINCodeChanged(
    this.pinCode,
  );

  @override
  List<Object> get props => [pinCode];
}

class PINSubmitted extends PINEvent {
  final User user;

  const PINSubmitted(
    this.user,
  );

  @override
  List<Object> get props => [user];
}

class ResetVerificationCodeVerified extends PINEvent {
  const ResetVerificationCodeVerified();
}

class ResetPINCodeSaved extends PINEvent {
  const ResetPINCodeSaved();
}

class ClearPIN extends PINEvent {
  final User user;

  const ClearPIN(
    this.user,
  );

  @override
  List<Object> get props => [user];
}
