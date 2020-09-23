import 'package:dispatcher/route/route_model.dart';

class AppRoutes {
  static const AppRoute connect = AppRoute(name: 'connect', path: '/connect');

  static const AppRoute contact = AppRoute(name: 'contact', path: '/contact');

  static const AppRoute avatarCamera =
      AppRoute(name: 'avatarCamera', path: '/avatar-camera');

  static const AppRoute changePIN =
      AppRoute(name: 'changePIN', path: '/change-pin');
}
