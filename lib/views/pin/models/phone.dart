import 'package:formz/formz.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

enum PhoneValidationError { empty }

class Phone extends FormzInput<PhoneNumber, PhoneValidationError> {
  const Phone.pure() : super.pure(null);

  const Phone.dirty([
    PhoneNumber phone,
  ]) : super.dirty(phone);

  @override
  PhoneValidationError validator(
    PhoneNumber phone,
  ) =>
      (phone != null) ? null : PhoneValidationError.empty;
}
