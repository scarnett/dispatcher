import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dispatcher/utils/date_utils.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class Device {
  final String id;
  final String identifier;
  final String publicKey;
  final DeviceUser user;
  final InviteCode inviteCode;
  final DateTime registeredDate;

  Device({
    this.id,
    this.identifier,
    this.publicKey,
    this.user,
    this.inviteCode,
    this.registeredDate,
  });

  factory Device.fromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    if ((snapshot == null) || !snapshot.exists) {
      return null;
    }

    return Device(
      id: snapshot.get('id'),
      identifier: snapshot.get('identifier'),
      publicKey: snapshot.get('public_key'),
      user: DeviceUser.fromSnapshot(snapshot.get('user')),
      inviteCode: InviteCode.fromSnapshot(snapshot.get('invite_code')),
      registeredDate: toDate(snapshot.get('registered_date')),
    );
  }

  Device copyWith({
    String id,
    String identifier,
    String publicKey,
    String user,
    InviteCode inviteCode,
    DateTime registeredDate,
  }) =>
      Device(
        id: id ?? this.id,
        identifier: identifier ?? this.identifier,
        publicKey: publicKey ?? this.publicKey,
        user: user ?? this.user,
        inviteCode: inviteCode ?? this.inviteCode,
        registeredDate: registeredDate ?? this.registeredDate,
      );

  static Device fromJson(
    dynamic json,
  ) =>
      Device(
        id: json['id'],
        identifier: json['identifier'],
        publicKey: json['public_key'],
        user: DeviceUser.fromJson(json['user']),
        inviteCode: InviteCode.fromJson(json['invite_code']),
        registeredDate: fromIso8601String(json['registered_date']),
      );

  dynamic toJson() => {
        'id': id,
        'identifier': identifier,
        'public_key': publicKey,
        'user': (user == null) ? DeviceUser().toJson() : user.toJson(),
        'invite_code':
            (inviteCode == null) ? InviteCode().toJson() : inviteCode.toJson(),
        'registered_date': toIso8601String(registeredDate),
      };

  @override
  String toString() =>
      'Device{id: $id, identifier: $identifier, registered_date: $registeredDate}';
}

class DeviceUser {
  final String firstName;
  final String lastName;
  final String email;
  final DevicePhoneNumber phone;
  final DevicePIN pin;
  final String avatar;

  DeviceUser({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.pin,
    this.avatar,
  });

  factory DeviceUser.fromSnapshot(
    dynamic user,
  ) {
    if (user == null) {
      return DeviceUser();
    }

    return DeviceUser(
      firstName: user['first_name'],
      lastName: user['last_name'],
      email: user['email'],
      phone: DevicePhoneNumber.fromSnapshot(user['phone']),
      pin: DevicePIN.fromSnapshot(user['pin']),
      avatar: user['avatar'],
    );
  }

  DeviceUser copyWith({
    String firstName,
    String lastName,
    String email,
    DevicePhoneNumber phone,
    DevicePIN pin,
    String avatar,
  }) =>
      DeviceUser(
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        pin: pin ?? this.pin,
        avatar: avatar ?? this.avatar,
      );

  static DeviceUser fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? DeviceUser()
          : DeviceUser(
              firstName: json['first_name'],
              lastName: json['last_name'],
              email: json['email'],
              phone: DevicePhoneNumber.fromJson(json['phone']),
              pin: DevicePIN.fromJson(json['pin']),
              avatar: json['avatar'],
            );

  dynamic toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone':
            (phone == null) ? DevicePhoneNumber().toJson() : phone.toJson(),
        'pin': (pin == null) ? DevicePIN().toJson() : pin.toJson(),
        'avatar': avatar,
      };

  @override
  String toString() =>
      'DeviceUser{first_name: $firstName, last_name: $lastName, email: $email, phone: $phone, avatar: $avatar}';
}

class DevicePhoneNumber {
  final String dialCode;
  final String isoCode;
  final String phoneNumber;

  DevicePhoneNumber({
    this.dialCode,
    this.isoCode,
    this.phoneNumber,
  });

  factory DevicePhoneNumber.fromSnapshot(
    dynamic phone,
  ) {
    if (phone == null) {
      return DevicePhoneNumber();
    }

    return DevicePhoneNumber(
      dialCode: phone['dial_code'],
      isoCode: phone['iso_code'],
      phoneNumber: phone['phone_number'],
    );
  }

  PhoneNumber toPhoneNumber() => PhoneNumber(
        dialCode: this.dialCode,
        isoCode: this.isoCode,
        phoneNumber: this.phoneNumber,
      );

  DevicePhoneNumber copyWith({
    String dialCode,
    String isoCode,
    String phoneNumber,
  }) =>
      DevicePhoneNumber(
        dialCode: dialCode ?? this.dialCode,
        isoCode: isoCode ?? this.isoCode,
        phoneNumber: phoneNumber ?? this.phoneNumber,
      );

  static DevicePhoneNumber fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? DevicePhoneNumber()
          : DevicePhoneNumber(
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
      'DevicePhoneNumber{dial_code: $dialCode, iso_code: $isoCode, phone_number: $phoneNumber}';
}

class DevicePIN {
  final String pinCode;
  final String verificationCode;
  final DateTime verificationExpireDate;

  DevicePIN({
    this.pinCode,
    this.verificationCode,
    this.verificationExpireDate,
  });

  factory DevicePIN.fromSnapshot(
    dynamic pin,
  ) {
    if (pin == null) {
      return DevicePIN();
    }

    return DevicePIN(
      pinCode: pin['pin_code'],
      verificationCode: pin['verification_code'],
      verificationExpireDate: toDate(pin['verification_expire_date']),
    );
  }

  DevicePIN copyWith({
    String pinCode,
    String verificationCode,
    DateTime verificationExpireDate,
  }) =>
      DevicePIN(
        pinCode: pinCode ?? this.pinCode,
        verificationCode: verificationCode ?? this.verificationCode,
        verificationExpireDate:
            verificationExpireDate ?? this.verificationExpireDate,
      );

  static DevicePIN fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? DevicePIN()
          : DevicePIN(
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
  String toString() =>
      'DevicePIN{pin_code: $pinCode, verification_code: $verificationCode, verification_expire_date: $verificationExpireDate}';
}

class DeviceConnection {
  final String id;
  final String deviceId;
  final DateTime connectedDate;

  DeviceConnection({
    this.id,
    this.deviceId,
    this.connectedDate,
  });

  factory DeviceConnection.fromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    if ((snapshot == null) || !snapshot.exists) {
      return null;
    }

    return DeviceConnection(
      id: snapshot.get('id'),
      deviceId: snapshot.get('device_id'),
      connectedDate: toDate(snapshot.get('connected_date')),
    );
  }

  DeviceConnection copyWith({
    String id,
    String deviceId,
    DateTime connectedDate,
  }) =>
      DeviceConnection(
        id: id ?? this.id,
        deviceId: deviceId ?? this.deviceId,
        connectedDate: connectedDate ?? this.connectedDate,
      );

  static DeviceConnection fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? DeviceConnection()
          : DeviceConnection(
              id: json['id'],
              deviceId: json['device_id'],
              connectedDate: fromIso8601String(json['connected_date']),
            );

  static List<DeviceConnection> fromJsonList(
    List<dynamic> json,
  ) {
    if (json == null) {
      return <DeviceConnection>[];
    }

    List<DeviceConnection> connections = List<DeviceConnection>();

    for (dynamic connection in json) {
      connections..add(DeviceConnection.fromJson(connection));
    }

    return connections;
  }

  dynamic toJson() => {
        'id': id,
        'device_id': deviceId,
        'connected_date': toIso8601String(connectedDate),
      };

  static dynamic toJsonList(
    dynamic json,
  ) =>
      jsonEncode(json);

  @override
  String toString() =>
      'DeviceConnection{device_id: $deviceId, connected_date: $connectedDate}';
}

class DeviceRoom {
  final DateTime createdDate;

  DeviceRoom({
    this.createdDate,
  });

  factory DeviceRoom.fromSnapshot(
    dynamic connection,
  ) {
    if (connection == null) {
      return DeviceRoom();
    }

    return DeviceRoom(
      createdDate: toDate(connection['created_date']),
    );
  }

  DeviceRoom copyWith({
    DateTime createdDate,
  }) =>
      DeviceRoom(
        createdDate: createdDate ?? this.createdDate,
      );

  static DeviceRoom fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? DeviceRoom()
          : DeviceRoom(
              createdDate: fromIso8601String(json['created_date']),
            );

  dynamic toJson() => {
        'created_date': toIso8601String(createdDate),
      };

  @override
  String toString() => 'DeviceRoom{created_date: $createdDate}';
}

class InviteCode {
  final String code;
  final DateTime expireDate;

  InviteCode({
    this.code,
    this.expireDate,
  });

  factory InviteCode.fromSnapshot(
    dynamic inviteCode,
  ) {
    if (inviteCode == null) {
      return InviteCode();
    }

    return InviteCode(
      code: inviteCode['code'],
      expireDate: toDate(inviteCode['expire_date']),
    );
  }

  InviteCode copyWith({
    String code,
    DateTime expireDate,
  }) =>
      InviteCode(
        code: code ?? this.code,
        expireDate: expireDate ?? this.expireDate,
      );

  static InviteCode fromJson(
    dynamic json,
  ) =>
      InviteCode(
        code: json['code'],
        expireDate: fromIso8601String(json['expire_date']),
      );

  dynamic toJson() => {
        'code': code,
        'expire_date': toIso8601String(expireDate),
      };

  @override
  String toString() => 'InviteCode{code: $code, expire_date: $expireDate}';
}
