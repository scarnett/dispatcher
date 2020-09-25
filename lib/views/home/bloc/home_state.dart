import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class HomeState extends Equatable {
  final int selectedTabIndex;

  const HomeState._({
    this.selectedTabIndex = 0,
  });

  const HomeState.initial() : this._();

  HomeState copyWith({
    int selectedTabIndex,
  }) =>
      HomeState._(
        selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      );

  @override
  List<Object> get props => [selectedTabIndex];

  @override
  String toString() => 'HomeState{selectedTabIndex: $selectedTabIndex}';
}
