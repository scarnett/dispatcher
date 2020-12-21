import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/views/rooms/repository/rooms_repository.dart';
import 'package:dispatcher/utils/crypt_utils.dart';
import 'package:dispatcher/views/rooms/rooms_enums.dart';
import 'package:dispatcher/views/rooms/rooms_service.dart';
import 'package:equatable/equatable.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart' as signal;
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'rooms_event.dart';
part 'rooms_state.dart';

class RoomsBloc extends Bloc<RoomsEvent, RoomsState> {
  final RoomMessageRepository roomMessageRepository;

  RoomsBloc({
    @required this.roomMessageRepository,
  }) : super(RoomsState.initial()) {
    roomMessageRepository.messages().listen((data) => add(AddMessages(data)));
  }

  RoomsState get initialState => RoomsState.initial();

  @override
  Future<void> close() {
    roomMessageRepository.dispose();
    return super.close();
  }

  Stream<RoomsState> mapEventToState(
    RoomsEvent event,
  ) async* {
    if (event is FetchRoomData) {
      yield* _mapFetchRoomDataToStates(event);
    } else if (event is ClearRoomData) {
      yield _mapClearRoomDataToStates(event);
    } else if (event is SendMessage) {
      yield* _mapSendMessageToStates(event);
    } else if (event is SetSessionStatus) {
      yield _mapSetSessionStatusToStates(event);
    }
  }

  Stream<RoomsState> _mapFetchRoomDataToStates(
    FetchRoomData event,
  ) async* {
    Logger _logger = Logger();

    yield state.copyWith(sessionStatus: RoomSessionStatus.CREATING);

    try {
      if ((event.user != null) && (event.roomUserIdentifer != null)) {
        HttpsCallableResult roomResult = await fetchRoom(event);
        if (roomResult != null) {
          Room room = Room.fromJson(roomResult.data);
          RoomUser roomUser = room.users.firstWhere((roomUser) =>
              roomUser.user.identifier == event.roomUserIdentifer);

          if (roomUser != null) {
            // TODO! Check to see if the session cipher has already been created for this user previosuly and load it if already exists

            yield state.copyWith(
              activeRoom: room,
              sessionCipher: await buildSessionCipher(roomUser),
              sessionStatus: RoomSessionStatus.CREATED,
            );
          } else {
            _logger.e("roomUser '${event.roomUserIdentifer}' not found");
            yield state.copyWith(sessionStatus: RoomSessionStatus.CANT_CREATE);
          }
        } else {
          _logger.e('Bad result from fetchRoom callable');
          yield state.copyWith(sessionStatus: RoomSessionStatus.CANT_CREATE);
        }
      } else {
        _logger.e(
            'Missing data; user: ${event.user}, roomUserIdentifier: ${event.roomUserIdentifer}');
        yield state.copyWith(sessionStatus: RoomSessionStatus.CANT_CREATE);
      }
    } catch (e) {
      _logger.e(e.toString());
      yield state.copyWith(sessionStatus: RoomSessionStatus.CANT_CREATE);
    }
  }

  Stream<RoomsState> _mapSendMessageToStates(
    SendMessage event,
  ) async* {
    if (state.sessionCipher != null) {
      signal.CiphertextMessage cipherText =
          state.sessionCipher.encrypt(utf8.encode(event.message));

      Uint8List serializedCipherText = cipherText.serialize();

      signal.PreKeySignalMessage msgIn =
          signal.PreKeySignalMessage(serializedCipherText);

      // Sends a message to the room
      roomMessageRepository.sendMessage(
        state.activeRoom.identifier,
        RoomMessage(
          user: event.user,
          message: cipherText.serialize().toList(),
          type: msgIn.getType(),
        ),
      );
    }

    yield state;
  }

  RoomsState _mapClearRoomDataToStates(
    ClearRoomData event,
  ) =>
      state.copyWith(
        activeRoom: null,
        messages: const <RoomMessage>[],
        sessionStatus: RoomSessionStatus.NONE,
        sessionCipher: null,
      );

  RoomsState _mapSetSessionStatusToStates(
    SetSessionStatus event,
  ) {
    return state.copyWith(
      sessionStatus: event.sessionStatus,
    );
  }
}
