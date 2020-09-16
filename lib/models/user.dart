import 'package:dispatcher/utils/date_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class User extends Equatable {
  final String identifier;
  final String name;
  final String email;
  final UserPhoneNumber phone;

  User({
    this.identifier,
    this.name,
    this.email,
    this.phone,
  });

  User copyWith({
    String identifier,
    String name,
    String email,
    UserPhoneNumber phone,
  }) =>
      User(
        identifier: identifier ?? this.identifier,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
      );

  static User fromJson(
    dynamic json,
  ) =>
      User(
        identifier: json['identifier'],
        name: json['name'],
        email: json['email'],
        phone: UserPhoneNumber.fromJson(json['user_phone_number']),
      );

  dynamic toJson() => {
        'identifier': identifier,
        'name': name,
        'email': email,
        'phone': phone.toJson(),
      };

  @override
  List<Object> get props => [identifier, name, email, phone];

  @override
  String toString() =>
      'User{identifier: $identifier, name: $name, email: $email, phone: $phone}';
}

class UserPhoneNumber extends Equatable {
  final String dialCode;
  final String isoCode;
  final String phoneNumber;

  UserPhoneNumber({
    this.dialCode,
    this.isoCode,
    this.phoneNumber,
  });

  PhoneNumber toPhoneNumber() => PhoneNumber(
        dialCode: this.dialCode,
        isoCode: this.isoCode,
        phoneNumber: this.phoneNumber,
      );

  UserPhoneNumber copyWith({
    String dialCode,
    String isoCode,
    String phoneNumber,
  }) =>
      UserPhoneNumber(
        dialCode: dialCode ?? this.dialCode,
        isoCode: isoCode ?? this.isoCode,
        phoneNumber: phoneNumber ?? this.phoneNumber,
      );

  static UserPhoneNumber fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? UserPhoneNumber()
          : UserPhoneNumber(
              dialCode: json['dial_code'],
              isoCode: json['iso_code'],
              phoneNumber: json['phone_number'],
            );

  dynamic toJson() => {
        'dial_code': dialCode,
        'iso_code': isoCode,
        'phone_number': phoneNumber,
      };

  @override
  List<Object> get props => [dialCode, isoCode, phoneNumber];

  @override
  String toString() =>
      'UserPhoneNumber{dial_code: $dialCode, iso_code: $isoCode, phone_number: $phoneNumber}';
}

class UserPIN extends Equatable {
  final String pinCode;
  final String verificationCode;
  final DateTime verificationExpireDate;

  UserPIN({
    this.pinCode,
    this.verificationCode,
    this.verificationExpireDate,
  });

  UserPIN copyWith({
    String pinCode,
    String verificationCode,
    DateTime verificationExpireDate,
  }) =>
      UserPIN(
        pinCode: pinCode ?? this.pinCode,
        verificationCode: verificationCode ?? this.verificationCode,
        verificationExpireDate:
            verificationExpireDate ?? this.verificationExpireDate,
      );

  static UserPIN fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? UserPIN()
          : UserPIN(
              pinCode: json['pin_code'],
              verificationCode: json['verification_code'],
              verificationExpireDate:
                  fromIso8601String(json['verification_expire_date']),
            );

  dynamic toJson() => {
        'pin_code': pinCode,
        'verification_code': verificationCode,
        'verification_expire_date': toIso8601String(verificationExpireDate),
      };

  @override
  List<Object> get props => [pinCode, verificationCode, verificationExpireDate];

  @override
  String toString() =>
      'UserPIN{pin_code: $pinCode, verification_code: $verificationCode, verification_expire_date: $verificationExpireDate}';
}
