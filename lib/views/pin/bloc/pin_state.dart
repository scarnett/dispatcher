part of 'pin_bloc.dart';

@immutable
class PINState extends Equatable {
  final bool loaded;
  final UserPIN pin;
  final PINEventType eventType;
  final String verificationCode;
  final bool verificationCodeVerified;
  final String pinCode;
  final bool pinCodeSaved;

  const PINState._({
    this.loaded = false,
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

  PINState copyWith({
    Nullable<bool> loaded,
    UserPIN pin,
    Nullable<PINEventType> eventType,
    Nullable<String> verificationCode,
    Nullable<bool> verificationCodeVerified,
    String pinCode,
    Nullable<bool> pinCodeSaved,
  }) =>
      PINState._(
        loaded: (loaded == null) ? this.loaded : loaded.value,
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
        loaded,
        pin,
        eventType,
        verificationCode,
        verificationCodeVerified,
        pinCode,
        pinCodeSaved,
      ];

  @override
  String toString() =>
      'PINState{loaded: $loaded, ' +
      'pin: $pin, ' +
      'eventType: $eventType, ' +
      'verificationCode: ${(verificationCode == null) ? null : '<verificationCode>'}, ' +
      'verificationCodeVerified: $verificationCodeVerified, ' +
      'pinCode: ${(pinCode == null) ? null : '<pinCode>'}, ' +
      'pinCodeSaved: $pinCodeSaved}';
}
