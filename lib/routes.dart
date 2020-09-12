import 'package:dispatcher/route/route_model.dart';

class AppRoutes {
  static const AppRoute landing = AppRoute(name: 'landing', path: '/');
  static const AppRoute auth = AppRoute(name: 'auth', path: '/auth');
  static const AppRoute logout = AppRoute(name: 'logout', path: '/logout');
  static const AppRoute home = AppRoute(name: 'home', path: '/home');
  static const AppRoute connect = AppRoute(name: 'connect', path: '/connect');

  static const AppRoute contacts =
      AppRoute(name: 'contacts', path: '/contacts');

  static const AppRoute contact = AppRoute(name: 'contact', path: '/contact');

  static const AppRoute settings =
      AppRoute(name: 'settings', path: '/settings');

  static const AppRoute menu = AppRoute(name: 'menu', path: '/menu');
  static const AppRoute photo = AppRoute(name: 'photo', path: '/photo');

  static const AppRoute avatarCamera =
      AppRoute(name: 'avatarCamera', path: '/avatar-camera');

  static const AppRoute changePIN =
      AppRoute(name: 'changePIN', path: '/change-pin');

  static const AppRoute migrateFrom =
      AppRoute(name: 'migrateFrom', path: '/migrate-from');

  static const AppRoute migrateTo =
      AppRoute(name: 'migrateTo', path: '/migrate-to');
}
