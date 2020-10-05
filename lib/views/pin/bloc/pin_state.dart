part of 'pin_bloc.dart';

@immutable
class PINState extends Equatable {
  final UserPIN pin;
  final PINEventType eventType;
  final String verificationCode;
  final bool verificationCodeVerified;
  final String pinCode;
  final bool pinCodeSaved;

  const PINState._({
    this.pin,
    this.eventType,
    this.verificationCode,
    this.verificationCodeVerified,
    this.pinCode,
    this.pinCodeSaved,
  });

  const PINState.initial() : this._();

  const PINState.saved()
      : this._(
          verificationCode: null,
          verificationCodeVerified: false,
          pinCodeSaved: true,
        );

  const PINState.clear() : this._();

  const PINState.eventType(
    PINEventType eventType,
  ) : this._(eventType: eventType);

  const PINState.clearEventType() : this._(eventType: null);

  PINState copyWith({
    UserPIN pin,
    Nullable<PINEventType> eventType,
    Nullable<String> verificationCode,
    Nullable<bool> verificationCodeVerified,
    String pinCode,
    Nullable<bool> pinCodeSaved,
  }) =>
      PINState._(
        pin: pin ?? this.pin,
        eventType: (eventType == null) ? this.eventType : eventType.value,
        verificationCode: (verificationCode == null)
            ? this.verificationCode
            : verificationCode.value,
        verificationCodeVerified: (verificationCodeVerified == null)
            ? this.verificationCodeVerified
            : verificationCodeVerified.value,
        pinCode: pinCode ?? this.pinCode,
        pinCodeSaved:
            (pinCodeSaved == null) ? this.pinCodeSaved : pinCodeSaved.value,
      );

  @override
  List<Object> get props => [
        pin,
        eventType,
        verificationCode,
        verificationCodeVerified,
        pinCode,
        pinCodeSaved,
      ];

  @override
  String toString() =>
      'PINState{pin: $pin, ' +
      'eventType: $eventType, ' +
      'verificationCode: ${(verificationCode == null) ? null : '<verificationCode>'}, ' +
      'verificationCodeVerified: $verificationCodeVerified, ' +
      'pinCode: ${(pinCode == null) ? null : '<pinCode>'}, ' +
      'pinCodeSaved: $pinCodeSaved}';
}
