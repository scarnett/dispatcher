import 'package:dispatcher/user/user_model.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class HomeState extends Equatable {
  final User user;
  final int selectedTabIndex;

  const HomeState._({
    this.user,
    this.selectedTabIndex = 0,
  });

  const HomeState.loadInProgress() : this._();

  const HomeState.loadSuccess(User user) : this._(user: user);

  const HomeState.loadFail() : this._();

  const HomeState.selectedTabIndex(int selectedTabIndex)
      : this._(selectedTabIndex: selectedTabIndex);

  HomeState copyWith({
    User user,
    int selectedTabIndex,
  }) {
    return HomeState._(
      user: user ?? this.user,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  @override
  List<Object> get props => [user, selectedTabIndex];

  @override
  String toString() =>
      'HomeState{user: $user, selectedTabIndex: $selectedTabIndex}';
}
