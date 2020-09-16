import 'package:equatable/equatable.dart';

abstract class PINEvent extends Equatable {
  const PINEvent();

  @override
  List<Object> get props => [];
}

class FetchPINData extends PINEvent {
  final String query;
  final Map<String, dynamic> variables;

  const FetchPINData(
    this.query, {
    this.variables,
  });

  @override
  List<Object> get props => [query, variables];
}
