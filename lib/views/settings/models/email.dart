import 'package:dispatcher/localization.dart';
import 'package:dispatcher/utils/email_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:formz/formz.dart';

enum EmailValidationError { empty, invalid }

class Email extends FormzInput<String, EmailValidationError> {
  const Email.pure() : super.pure('');

  const Email.dirty([
    String value = '',
  ]) : super.dirty(value);

  @override
  EmailValidationError validator(
    String value,
  ) {
    if (value?.isNotEmpty == true) {
      RegExp regex = RegExp(getEmailRegex());
      if (!regex.hasMatch(value)) {
        return EmailValidationError.invalid;
      }

      return null;
    }

    return EmailValidationError.empty;
  }

  String getErrorText(
    BuildContext context,
  ) {
    switch (error) {
      case EmailValidationError.invalid:
        return AppLocalizations.of(context).emailValidPlease;

      case EmailValidationError.empty:
      default:
        return AppLocalizations.of(context).emailPlease;
    }
  }
}
