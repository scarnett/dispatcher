import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FetchHomeData extends HomeEvent {
  final String query;
  final Map<String, dynamic> variables;

  const FetchHomeData(
    this.query, {
    this.variables,
  });

  @override
  List<Object> get props => [query, variables];
}

class SelectedTabIndex extends HomeEvent {
  final int index;

  const SelectedTabIndex(this.index);

  @override
  List<Object> get props => [index];
}
