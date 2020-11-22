import 'dart:convert';
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
      yield* _mapFetchRoomDataToStates(event);
    } else if (event is ClearRoomData) {
      yield _mapClearRoomDataToStates(event);
    } else if (event is SendMessage) {
      yield* _mapSendMessageToStates(event);
    }
  }

  Stream<RoomsState> _mapFetchRoomDataToStates(
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

  Stream<RoomsState> _mapSendMessageToStates(
    SendMessage event,
  ) async* {
    signal.CiphertextMessage cipherText =
        state.sessionCipher.encrypt(utf8.encode(event.message));

    signal.PreKeySignalMessage msgIn =
        signal.PreKeySignalMessage(cipherText.serialize());

    String cipherTextStr = String.fromCharCodes(cipherText.serialize());
    int messageType = msgIn.getType();

    // Send a message to the room
    await sendMessage(
      state.activeRoom.id,
      event.user,
      cipherTextStr,
      messageType,
    );

    yield state;
  }

  RoomsState _mapClearRoomDataToStates(
    ClearRoomData event,
  ) =>
      state.copyWith(
        activeRoom: null,
      );
}
