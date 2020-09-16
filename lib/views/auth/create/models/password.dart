import 'package:dispatcher/localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:formz/formz.dart';

enum PasswordValidationError { empty, length }

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');

  const Password.dirty([
    String value = '',
  ]) : super.dirty(value);

  @override
  PasswordValidationError validator(
    String value,
  ) {
    if (value?.isNotEmpty == true) {
      // TODO! config min password length
      if (value.length < 6) {
        return PasswordValidationError.length;
      }

      return null;
    }

    return PasswordValidationError.empty;
  }

  String getErrorText(
    BuildContext context,
  ) {
    switch (error) {
      case PasswordValidationError.length:
        // TODO! config min password length
        return AppLocalizations.of(context).passwordLength(6);

      case PasswordValidationError.empty:
      default:
        return AppLocalizations.of(context).passwordPlease;
    }
  }
}
