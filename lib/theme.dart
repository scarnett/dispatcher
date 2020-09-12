import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppTheme {
  static const Color background = Color.fromRGBO(252, 253, 255, 1);
  static const Color primary = Color.fromRGBO(131, 100, 251, 1.0);
  static const Color accent = Color.fromRGBO(157, 168, 253, 1.0);
  static const Color avatar = AppTheme.primary;
  static const Color text = Color.fromRGBO(77, 74, 86, 1.0);
  static const Color hint = Color.fromRGBO(201, 202, 214, 1.0);
  static const Color success = AppTheme.primary;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;
  static Color loadingBackground = Colors.white.withOpacity(0.9);
  static Color border = Colors.grey[300];
}

ThemeData appThemeData = ThemeData(
  fontFamily: 'gilroy',
  scaffoldBackgroundColor: AppTheme.background,
  primaryColor: AppTheme.primary,
  accentColor: AppTheme.accent,
  textSelectionColor: AppTheme.primary,
  textSelectionHandleColor: AppTheme.accent,
  cursorColor: AppTheme.primary,
  textTheme: const TextTheme(
    headline3: TextStyle(
      color: AppTheme.text,
      fontWeight: FontWeight.w900,
      fontSize: 40.0,
      letterSpacing: -1.5,
    ),
    headline5: TextStyle(
      color: AppTheme.text,
      fontWeight: FontWeight.w900,
      fontSize: 24.0,
      letterSpacing: -1.5,
    ),
    headline6: const TextStyle(
      color: AppTheme.text,
      fontWeight: FontWeight.w700,
      fontSize: 16.0,
    ),
    subtitle2: const TextStyle(
      color: AppTheme.hint,
      fontWeight: FontWeight.w500,
      fontSize: 14.0,
    ),
  ),
  appBarTheme: const AppBarTheme(
    color: AppTheme.background,
    elevation: 0.0,
    iconTheme: IconThemeData(
      color: AppTheme.hint,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppTheme.background,
    selectedItemColor: AppTheme.accent,
    selectedLabelStyle: TextStyle(
      color: AppTheme.accent,
      fontWeight: FontWeight.w700,
      fontSize: 12.0,
    ),
    unselectedItemColor: AppTheme.hint,
    unselectedLabelStyle: TextStyle(
      color: AppTheme.hint,
      fontWeight: FontWeight.w700,
      fontSize: 12.0,
    ),
    showUnselectedLabels: true,
    showSelectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: AppTheme.primary,
    disabledColor: AppTheme.hint,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    colorScheme: ColorScheme.dark(),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    shape: null,
  ),
  tabBarTheme: const TabBarTheme(
    labelColor: AppTheme.accent,
    unselectedLabelColor: AppTheme.hint,
    labelStyle: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 14.0,
    ),
    unselectedLabelStyle: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 14.0,
    ),
    labelPadding: const EdgeInsets.only(
      left: 5.0,
      right: 5.0,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: UnderlineInputBorder(
      borderSide: BorderSide(
        color: AppTheme.hint,
        width: 2.0,
        style: BorderStyle.solid,
      ),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: AppTheme.accent,
        width: 2.0,
        style: BorderStyle.solid,
      ),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppTheme.hint),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: AppTheme.border,
    space: 1.0,
    thickness: 1.0,
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
    },
  ),
);
