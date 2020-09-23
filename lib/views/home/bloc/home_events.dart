import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class SelectedTabIndex extends HomeEvent {
  final int index;

  const SelectedTabIndex(this.index);

  @override
  List<Object> get props => [index];
}
