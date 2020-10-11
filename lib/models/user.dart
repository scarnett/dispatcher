import 'package:dispatcher/utils/date_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class User extends Equatable {
  final String identifier;
  final String name;
  final String email;
  final UserPhoneNumber phone;
  final UserAvatar avatar;
  final UserKey key;
  final List<UserConnection> connections;

  User({
    this.identifier,
    this.name,
    this.email,
    this.phone,
    this.avatar,
    this.key,
    this.connections,
  });

  User copyWith({
    String identifier,
    String name,
    String email,
    UserPhoneNumber phone,
    UserAvatar avatar,
    UserKey key,
    List<UserConnection> connections,
  }) =>
      User(
        identifier: identifier ?? this.identifier,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        avatar: avatar ?? this.avatar,
        key: key ?? this.key,
        connections: connections ?? this.connections,
      );

  static User fromJson(
    dynamic json,
  ) =>
      User(
        identifier: json['identifier'],
        name: json['name'],
        email: json['email'],
        phone: UserPhoneNumber.fromJson(json['user_phone_number']),
        avatar: UserAvatar.fromJson(json['user_avatar']),
        key: UserKey.fromJson(json['user_key']),
        connections: UserConnection.fromJsonList(json['user_connections']),
      );

  dynamic toJson() => {
        'identifier': identifier,
        'name': name,
        'email': email,
        'phone': phone.toJson(),
        'avatar': avatar.toJson(),
        'key': key.toJson(),
        'connections': connections,
      };

  @override
  List<Object> get props => [identifier, name, email, phone, avatar, key];

  @override
  String toString() =>
      'User{identifier: $identifier, name: $name, email: $email, ' +
      'phone: $phone, avatar: $avatar, key: $key}';
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
      (json == null)
          ? UserInviteCode()
          : UserInviteCode(
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
      'UserPIN{pin_code: ${(pinCode == null) ? null : '<pinCode>'}, ' +
      'verification_code: ${(verificationCode == null) ? null : '<verificationCode>'}, ' +
      'verification_expire_date: $verificationExpireDate}';
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
  String toString() =>
      'UserKey{publicKey: ${(publicKey == null) ? null : '<publicKey>'}}';
}

class UserConnection extends Equatable {
  final String user;
  final String connectUser;

  UserConnection({
    this.user,
    this.connectUser,
  });

  UserConnection copyWith({
    String user,
    String connectUser,
  }) =>
      UserConnection(
        user: user ?? this.user,
        connectUser: connectUser ?? this.connectUser,
      );

  static UserConnection fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? UserConnection()
          : UserConnection(
              user: json['user'],
              connectUser: json['connect_user'],
            );

  static List<UserConnection> fromJsonList(
    dynamic json,
  ) =>
      (json == null)
          ? []
          : List<dynamic>.from(json)
              .map((dynamic userJson) => UserConnection.fromJson(userJson))
              .toList();

  dynamic toJson() => {
        'user': user,
        'connect_user': connectUser,
      };

  static List<dynamic> toJsonList(
    List<UserConnection> connections,
  ) =>
      (connections == null)
          ? []
          : connections
              .map((UserConnection connection) => connection.toJson())
              .toList();

  @override
  List<Object> get props => [user, connectUser];

  @override
  String toString() =>
      'UserConnection{user: $user, connect_user: $connectUser}';
}
