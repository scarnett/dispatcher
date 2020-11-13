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
  final List<UserPreKey> preKeys;
  final UserFCM fcm;
  final List<UserConnection> connections;

  User({
    this.identifier,
    this.name,
    this.email,
    this.phone,
    this.avatar,
    this.key,
    this.preKeys,
    this.fcm,
    this.connections,
  });

  User copyWith({
    String identifier,
    String name,
    String email,
    UserPhoneNumber phone,
    UserAvatar avatar,
    UserKey key,
    List<UserPreKey> preKeys,
    UserFCM fcm,
    List<UserConnection> connections,
  }) =>
      User(
        identifier: identifier ?? this.identifier,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        avatar: avatar ?? this.avatar,
        key: key ?? this.key,
        preKeys: preKeys ?? this.preKeys,
        fcm: fcm ?? this.fcm,
        connections: connections ?? this.connections,
      );

  static User fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? User()
          : User(
              identifier: json['identifier'],
              name: json['name'],
              email: json['email'],
              phone: UserPhoneNumber.fromJson(json['user_phone_number']),
              avatar: UserAvatar.fromJson(json['user_avatar']),
              key: UserKey.fromJson(json['user_key']),
              preKeys: UserPreKey.fromJsonList(json['user_pre_keys']),
              fcm: UserFCM.fromJson(json['user_fcm']),
              connections:
                  UserConnection.fromJsonList(json['user_connections']),
            );

  dynamic toJson() => {
        'identifier': identifier,
        'name': name,
        'email': email,
        'phone': phone.toJson(),
        'avatar': avatar.toJson(),
        'key': key.toJson(),
        'preKeys': preKeys,
        'fcm': fcm.toJson(),
        'connections': connections,
      };

  @override
  List<Object> get props =>
      [identifier, name, email, phone, avatar, key, preKeys, fcm, connections];

  @override
  String toString() =>
      'User{identifier: $identifier, name: $name, email: $email, ' +
      'phone: $phone, avatar: $avatar, key: $key, preKeys: ${preKeys?.length}, ' +
      'fcm: $fcm, connections: ${connections?.length}}';
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
  final String thumbUrl;
  final String path;
  final String thumbPath;

  UserAvatar({
    this.url,
    this.thumbUrl,
    this.path,
    this.thumbPath,
  });

  UserAvatar copyWith({
    String url,
    String thumbUrl,
    String path,
    String thumbPath,
  }) =>
      UserAvatar(
        url: url ?? this.url,
        thumbUrl: thumbUrl ?? this.thumbUrl,
        path: path ?? this.path,
        thumbPath: thumbPath ?? this.thumbPath,
      );

  static UserAvatar fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? UserAvatar()
          : UserAvatar(
              url: json['url'],
              thumbUrl: json['thumb_url'],
              path: json['path'],
              thumbPath: json['thumb_path'],
            );

  dynamic toJson() => {
        'url': url,
        'thumb_url': thumbUrl,
        'path': path,
        'thumb_path': thumbPath
      };

  @override
  List<Object> get props => [url, thumbUrl, path, thumbPath];

  @override
  String toString() =>
      'UserAvatar{url: $url, thumbUrl: $thumbUrl, ' +
      'path: $path, thumb_path: $thumbPath}';
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
  final int sigRegistrationId;
  final String sigSignedPublicKey;
  final String sigSignedPrekeySignature;
  final String sigIdentityPublicKey;

  UserKey({
    this.publicKey,
    this.sigRegistrationId,
    this.sigSignedPublicKey,
    this.sigSignedPrekeySignature,
    this.sigIdentityPublicKey,
  });

  UserKey copyWith({
    String publicKey,
    int sigRegistrationId,
    String sigSignedPublicKey,
    String sigSignedPrekeySignature,
    String sigIdentityPublicKey,
  }) =>
      UserKey(
        publicKey: publicKey ?? this.publicKey,
        sigRegistrationId: sigRegistrationId ?? this.sigRegistrationId,
        sigSignedPublicKey: sigSignedPublicKey ?? this.sigSignedPublicKey,
        sigSignedPrekeySignature:
            sigSignedPrekeySignature ?? this.sigSignedPrekeySignature,
        sigIdentityPublicKey: sigIdentityPublicKey ?? this.sigIdentityPublicKey,
      );

  static UserKey fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? UserKey()
          : UserKey(
              publicKey: json['public_key'],
              sigRegistrationId: json['sig_registration_id'],
              sigSignedPublicKey: json['sig_signed_public_key'],
              sigSignedPrekeySignature: json['sig_signed_prekey_signature'],
              sigIdentityPublicKey: json['sig_identity_public_key'],
            );

  dynamic toJson() => {
        'public_key': publicKey,
        'sig_registration_id': sigRegistrationId,
        'sig_signed_public_key': sigSignedPublicKey,
        'sig_signed_prekey_signature': sigSignedPrekeySignature,
        'sig_identity_public_key': sigIdentityPublicKey,
      };

  @override
  List<Object> get props => [
        publicKey,
        sigRegistrationId,
        sigSignedPublicKey,
        sigSignedPrekeySignature,
        sigIdentityPublicKey,
      ];

  @override
  String toString() =>
      'UserKey{public_key: $publicKey, sig_registration_id: $sigRegistrationId ' +
      'sig_signed_public_key: $sigSignedPublicKey, sig_signed_prekey_signature: $sigSignedPrekeySignature ' +
      'sig_identity_public_key: $sigIdentityPublicKey}';
}

class UserPreKey extends Equatable {
  final int keyId;
  final String publicKey;

  UserPreKey({
    this.keyId,
    this.publicKey,
  });

  UserPreKey copyWith({
    String keyId,
    String publicKey,
  }) =>
      UserPreKey(
        keyId: keyId ?? this.keyId,
        publicKey: publicKey ?? this.publicKey,
      );

  static UserPreKey fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? UserPreKey()
          : UserPreKey(
              keyId: json['key_id'],
              publicKey: json['public_key'],
            );

  static List<UserPreKey> fromJsonList(
    dynamic json,
  ) =>
      (json == null)
          ? []
          : List<dynamic>.from(json)
              .map((dynamic userJson) => UserPreKey.fromJson(userJson))
              .toList();

  dynamic toJson() => {
        'key_id': keyId,
        'public_key': publicKey,
      };

  static List<dynamic> toJsonList(
    List<UserPreKey> preKeys,
  ) =>
      (preKeys == null)
          ? []
          : preKeys.map((UserPreKey preKey) => preKey.toJson()).toList();

  @override
  List<Object> get props => [
        keyId,
        publicKey,
      ];

  @override
  String toString() => 'UserPreKey{key_id: $keyId, public_key: $publicKey}';
}

class UserFCM extends Equatable {
  final String token;

  UserFCM({
    this.token,
  });

  UserFCM copyWith({
    String token,
  }) =>
      UserFCM(
        token: token ?? this.token,
      );

  static UserFCM fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? UserFCM()
          : UserFCM(
              token: json['token'],
            );

  dynamic toJson() => {
        'token': token,
      };

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'UserFCM{token: $token}';
}

class UserConnection extends Equatable {
  final User connectUser;

  UserConnection({
    this.connectUser,
  });

  UserConnection copyWith({
    String connectUser,
  }) =>
      UserConnection(
        connectUser: connectUser ?? this.connectUser,
      );

  static UserConnection fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? UserConnection()
          : UserConnection(
              connectUser: User.fromJson(json['connection_user']),
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
  List<Object> get props => [connectUser];

  @override
  String toString() => 'UserConnection{connect_user: $connectUser}';
}
