import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/utils/crypt_utils.dart';
import 'package:dispatcher/views/rooms/rooms_enums.dart';
import 'package:dispatcher/views/rooms/rooms_service.dart';
import 'package:equatable/equatable.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart' as signal;
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
    } else if (event is ClearRoomData) {
      yield _mapClearRoomDataToStates(event);
    }
  }

  Stream<RoomsState> _mapFetchRoomData(
    FetchRoomData event,
  ) async* {
    yield state.copyWith(sessionStatus: RoomSessionStatus.CREATING);

    if ((event.user != null) && (event.roomUserIdentifer != null)) {
      HttpsCallableResult roomResult = await fetchRoom(event);
      if (roomResult != null) {
        Room room = Room.fromJson(roomResult.data);
        RoomUser roomUser = room.users.firstWhere(
            (roomUser) => roomUser.user.identifier == event.roomUserIdentifer);

        if (roomUser != null) {
          yield state.copyWith(
            activeRoom: room,
            sessionCipher: buildSessionCipher(roomUser),
            sessionStatus: RoomSessionStatus.CREATED,
          );
        } else {
          yield state.copyWith(sessionStatus: RoomSessionStatus.CANT_CREATE);
        }
      } else {
        yield state.copyWith(sessionStatus: RoomSessionStatus.CANT_CREATE);
      }
    } else {
      yield state.copyWith(sessionStatus: RoomSessionStatus.CANT_CREATE);
    }
  }

  RoomsState _mapClearRoomDataToStates(
    ClearRoomData event,
  ) =>
      state.copyWith(
        activeRoom: null,
      );
}
