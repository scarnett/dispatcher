import 'package:dispatcher/env_config.dart';
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
      int minPasswordLength =
          int.parse(EnvConfig.DISPATCHER_MIN_PASSWORD_LENGTH);
      if (value.length < minPasswordLength) {
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
        int minPasswordLength =
            int.parse(EnvConfig.DISPATCHER_MIN_PASSWORD_LENGTH);
        return AppLocalizations.of(context).passwordLength(minPasswordLength);

      case PasswordValidationError.empty:
      default:
        return AppLocalizations.of(context).passwordPlease;
    }
  }
}
