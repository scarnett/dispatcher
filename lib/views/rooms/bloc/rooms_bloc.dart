import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/storage/storage.dart';
import 'package:dispatcher/utils/crypt_utils.dart';
import 'package:dispatcher/views/rooms/repository/rooms_repository.dart';
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
      if ((event.senderUser != null) && (event.receiverUser != null)) {
        HttpsCallableResult roomResult = await fetchRoom(event);
        if (roomResult != null) {
          Room room = Room.fromJson(roomResult.data);
          RoomUser roomUser = room.users.firstWhere((roomUser) =>
              roomUser.user.identifier == event.receiverUser.identifier);

          if ((roomUser != null) && (state.sessionCipher == null)) {
            DispatcherIdentityKeyStore identityKeyStore =
                DispatcherIdentityKeyStore();

            DispatcherSignalProtocolStore _store =
                DispatcherSignalProtocolStore(
              identityKeyStore.getIdentityKeyPair(),
              identityKeyStore.getLocalRegistrationId(),
            );

            buildSessionCipher(event.receiverUser, _store);

            signal.SignalProtocolAddress _address =
                signal.SignalProtocolAddress(event.receiverUser.identifier, 1);

            yield state.copyWith(
              activeRoom: room,
              sessionStatus: RoomSessionStatus.CREATED,
              sessionCipher: signal.SessionCipher.fromStore(_store, _address),
            );
          } else {
            _logger.e("receiverUser '${event.receiverUser}' not found");
            yield state.copyWith(sessionStatus: RoomSessionStatus.CANT_CREATE);
          }
        } else {
          _logger.e('Bad result from fetchRoom callable');
          yield state.copyWith(sessionStatus: RoomSessionStatus.CANT_CREATE);
        }
      } else {
        _logger.e(
            'Missing data; senderUser: ${event.senderUser}, receiverUser: ${event.receiverUser}');
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
    print('1111');
    signal.CiphertextMessage cipherText =
        state.sessionCipher.encrypt(utf8.encode(event.message));

    print('2222');
    // Sends a message to the room
    roomMessageRepository.sendMessage(
      state.activeRoom.identifier,
      RoomMessage(
        user: event.user.identifier,
        message: cipherText.serialize().toList(),
        type: cipherText.getType(),
      ),
    );

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
  ) =>
      state.copyWith(
        sessionStatus: event.sessionStatus,
      );
}
