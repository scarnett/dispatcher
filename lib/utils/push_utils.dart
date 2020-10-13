import 'dart:convert';
import 'package:dispatcher/env_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

Logger _logger = Logger();

void configLocalNotification() {
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void listenForPushMessages(
  FirebaseMessaging firebaseMessaging,
) async {
  firebaseMessaging.requestNotificationPermissions(
    const IosNotificationSettings(
      sound: true,
      badge: true,
      alert: true,
    ),
  );

  firebaseMessaging.configure(
    onMessage: showNotification,
    onLaunch: (Map<String, dynamic> message) async {
      _logger.d('onLaunch: $message');
    },
    onResume: (Map<String, dynamic> message) async {
      _logger.d('onResume: $message');
    },
    onBackgroundMessage: fcmBackgroundMessageHandler,
  );

  firebaseMessaging.onIosSettingsRegistered
      .listen((IosNotificationSettings settings) {
    _logger.d('Settings registered: $settings');
  });
}

Future<dynamic> fcmBackgroundMessageHandler(
  Map<String, dynamic> message,
) =>
    Future<dynamic>.value(null);

Future<dynamic> showNotification(
  Map<String, dynamic> message,
) async {
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    EnvConfig.DISPATCHER_NOTIFICATION_CHANNEL,
    EnvConfig.DISPATCHER_APP_NAME,
    EnvConfig.DISPATCHER_NOTIFICATION_CHANNEL_DESCRIPTION,
    playSound: true,
    enableVibration: true,
    importance: Importance.max,
    priority: Priority.high,
  );

  final IOSNotificationDetails iOSPlatformChannelSpecifics =
      IOSNotificationDetails();

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  dynamic notification = message['notification'];

  await flutterLocalNotificationsPlugin.show(
    0,
    notification['title'].toString(),
    notification['body'].toString(),
    platformChannelSpecifics,
    payload: json.encode(message),
  );
}
