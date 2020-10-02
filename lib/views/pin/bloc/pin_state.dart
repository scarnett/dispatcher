part of 'pin_bloc.dart';

@immutable
class PINState extends Equatable {
  final UserPIN pin;
  final bool sendingVerificationCode;
  final String verificationCode;
  final bool verificationCodeVerified;
  final bool verifyingVerificationCode;
  final bool resendingVerificationCode;
  final String pinCode;
  final bool pinCodeSaved;
  final bool savingPinCode;

  const PINState({
    this.pin,
    this.sendingVerificationCode = false,
    this.verificationCode,
    this.verificationCodeVerified,
    this.verifyingVerificationCode = false,
    this.resendingVerificationCode = false,
    this.pinCode,
    this.pinCodeSaved,
    this.savingPinCode = false,
  });

  const PINState._({
    this.pin,
    this.sendingVerificationCode = false,
    this.verificationCode,
    this.verificationCodeVerified,
    this.verifyingVerificationCode = false,
    this.resendingVerificationCode = false,
    this.pinCode,
    this.pinCodeSaved,
    this.savingPinCode = false,
  });

  const PINState.saved()
      : this._(
          verificationCode: null,
          verificationCodeVerified: false,
          pinCodeSaved: true,
        );

  const PINState.clear() : this._();

  PINState copyWith({
    UserPIN pin,
    bool sendingVerificationCode = false,
    Nullable<String> verificationCode,
    Nullable<bool> verificationCodeVerified,
    bool verifyingVerificationCode = false,
    bool resendingVerificationCode = false,
    String pinCode,
    Nullable<bool> pinCodeSaved,
    bool savingPinCode = false,
  }) =>
      PINState(
        pin: pin ?? this.pin,
        sendingVerificationCode: sendingVerificationCode,
        verificationCode: (verificationCode == null)
            ? this.verificationCode
            : verificationCode.value,
        verificationCodeVerified: (verificationCodeVerified == null)
            ? this.verificationCodeVerified
            : verificationCodeVerified.value,
        verifyingVerificationCode: verifyingVerificationCode,
        resendingVerificationCode: resendingVerificationCode,
        pinCode: pinCode ?? this.pinCode,
        pinCodeSaved:
            (pinCodeSaved == null) ? this.pinCodeSaved : pinCodeSaved.value,
        savingPinCode: savingPinCode,
      );

  @override
  List<Object> get props => [
        pin,
        sendingVerificationCode,
        verificationCode,
        verificationCodeVerified,
        verifyingVerificationCode,
        resendingVerificationCode,
        pinCode,
        pinCodeSaved,
        savingPinCode,
      ];

  @override
  String toString() =>
      'PINState{pin: $pin, ' +
      'sendingVerificationCode: $sendingVerificationCode, ' +
      'verificationCode: ${(verificationCode == null) ? null : '<verificationCode>'}, ' +
      'verificationCodeVerified: $verificationCodeVerified, ' +
      'verifyingVerificationCode: $verifyingVerificationCode, ' +
      'resendingVerificationCode: $resendingVerificationCode, ' +
      'pinCode: ${(pinCode == null) ? null : '<pinCode>'}, ' +
      'pinCodeSaved: $pinCodeSaved, ' +
      'savingPinCode: $savingPinCode}';
}
