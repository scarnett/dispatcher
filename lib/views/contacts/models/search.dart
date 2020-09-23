import 'package:formz/formz.dart';

enum SearchValidationError { empty }

class Search extends FormzInput<String, SearchValidationError> {
  const Search.pure() : super.pure('');

  const Search.dirty([
    String value = '',
  ]) : super.dirty(value);

  @override
  SearchValidationError validator(
    String value,
  ) =>
      null;
}
