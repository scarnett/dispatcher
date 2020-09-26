import 'package:dispatcher/views/home/bloc/home_events.dart';
import 'package:dispatcher/views/home/bloc/home_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class HomeBloc extends HydratedBloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState.initial());

  HomeState get initialState => HomeState.initial();

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is SelectedTabIndex) {
      yield _mapSelectedTabIndexToStates(event);
    }
  }

  HomeState _mapSelectedTabIndexToStates(
    SelectedTabIndex event,
  ) =>
      state.copyWith(
        selectedTabIndex: event.index,
      );

  @override
  HomeState fromJson(
    Map<String, dynamic> json,
  ) =>
      HomeState(
        selectedTabIndex: json['selectedTabIndex'],
      );

  @override
  Map<String, dynamic> toJson(
    HomeState state,
  ) =>
      {
        'selectedTabIndex': state.selectedTabIndex,
      };
}
