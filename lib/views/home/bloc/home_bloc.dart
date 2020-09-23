import 'package:dispatcher/views/home/bloc/home_events.dart';
import 'package:dispatcher/views/home/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
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
}
