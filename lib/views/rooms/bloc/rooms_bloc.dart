import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/views/rooms/rooms_service.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'rooms_event.dart';
part 'rooms_state.dart';

class RoomsBloc extends Bloc<RoomsEvent, RoomsState> {
  RoomsBloc() : super(RoomsState.initial());

  RoomsState get initialState => RoomsState.initial();

  @override
  Stream<RoomsState> mapEventToState(
    RoomsEvent event,
  ) async* {
    if (event is FetchRoomData) {
      yield* _mapFetchRoomData(event);
    }
  }

  Stream<RoomsState> _mapFetchRoomData(
    FetchRoomData event,
  ) async* {
    print(event.users);
    if (event.users != null) {
      HttpsCallableResult room = await fetchRoom(event);
      // TODO! check for null
      yield state.copyWith(activeRoom: Room.fromJson(room.data));
    }
  }
}
