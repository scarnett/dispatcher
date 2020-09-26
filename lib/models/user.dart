import 'package:dispatcher/utils/date_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class User extends Equatable {
  final String identifier;
  final String name;
  final String email;
  final UserPhoneNumber phone;
  final UserInviteCode inviteCode;
  final UserAvatar avatar;
  final UserPIN pin;
  final UserKey key;

  User({
    this.identifier,
    this.name,
    this.email,
    this.phone,
    this.inviteCode,
    this.avatar,
    this.pin,
    this.key,
  });

  User copyWith({
    String identifier,
    String name,
    String email,
    UserPhoneNumber phone,
    UserInviteCode inviteCode,
    UserAvatar avatar,
    UserPIN pin,
    UserKey key,
  }) =>
      User(
        identifier: identifier ?? this.identifier,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        inviteCode: inviteCode ?? this.inviteCode,
        avatar: avatar ?? this.avatar,
        pin: pin ?? this.pin,
        key: key ?? this.key,
      );

  static User fromJson(
    dynamic json,
  ) =>
      User(
        identifier: json['identifier'],
        name: json['name'],
        email: json['email'],
        phone: UserPhoneNumber.fromJson(json['user_phone_number']),
        inviteCode: UserInviteCode.fromJson(json['user_invite_code']),
        avatar: UserAvatar.fromJson(json['user_avatar']),
        pin: UserPIN.fromJson(json['user_pin']),
        key: UserKey.fromJson(json['user_key']),
      );

  dynamic toJson() => {
        'identifier': identifier,
        'name': name,
        'email': email,
        'phone': phone.toJson(),
        'inviteCode': inviteCode.toJson(),
        'avatar': avatar.toJson(),
        'pin': pin.toJson(),
        'key': key.toJson(),
      };

  @override
  List<Object> get props =>
      [identifier, name, email, phone, inviteCode, avatar, pin, key];

  @override
  String toString() =>
      'User{identifier: $identifier, name: $name, email: $email, phone: $phone, inviteCode: $inviteCode, avatar: $avatar, pin: $pin, key: $key}';
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

class UserInviteCode extends Equatable {
  final String code;
  final DateTime expireDate;

  UserInviteCode({
    this.code,
    this.expireDate,
  });

  UserInviteCode copyWith({
    String code,
    DateTime expireDate,
  }) =>
      UserInviteCode(
        code: code ?? this.code,
        expireDate: expireDate ?? this.expireDate,
      );

  static UserInviteCode fromJson(
    dynamic json,
  ) =>
      UserInviteCode(
        code: json['code'],
        expireDate: fromIso8601String(json['expire_date']),
      );

  dynamic toJson() => {
        'code': code,
        'expire_date': toIso8601String(expireDate),
      };

  @override
  List<Object> get props => [code, expireDate];

  @override
  String toString() => 'UserInviteCode{code: $code, expire_date: $expireDate}';
}

class UserAvatar extends Equatable {
  final String url;

  UserAvatar({
    this.url,
  });

  UserAvatar copyWith({
    String url,
  }) =>
      UserAvatar(
        url: url ?? this.url,
      );

  static UserAvatar fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? UserAvatar()
          : UserAvatar(
              url: json['url'],
            );

  dynamic toJson() => {
        'url': url,
      };

  @override
  List<Object> get props => [url];

  @override
  String toString() => 'UserAvatar{url: $url}';
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

class UserKey extends Equatable {
  final String publicKey;

  UserKey({
    this.publicKey,
  });

  UserKey copyWith({
    String publicKey,
  }) =>
      UserKey(
        publicKey: publicKey ?? this.publicKey,
      );

  static UserKey fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? UserKey()
          : UserKey(
              publicKey: json['pubkey'],
            );

  dynamic toJson() => {
        'pubkey': publicKey,
      };

  @override
  List<Object> get props => [publicKey];

  @override
  String toString() => 'UserKey{publicKey: $publicKey}';
}
