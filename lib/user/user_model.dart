import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class User {
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
  String toString() =>
      'User{identifier: $identifier, name: $name, email: $email, phone: $phone}';
}

class UserPhoneNumber {
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
  String toString() =>
      'UserPhoneNumber{dial_code: $dialCode, iso_code: $isoCode, phone_number: $phoneNumber}';
}
