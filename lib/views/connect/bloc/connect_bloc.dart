import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/graphql/service.dart';
import 'package:dispatcher/graphql/user.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/views/connect/connect_enums.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'connect_event.dart';
part 'connect_state.dart';

class ConnectBloc extends Bloc<ConnectEvent, ConnectState> {
  GraphQLService _service;
  Logger _logger = Logger();

  ConnectBloc() : super(ConnectState.initial());

  ConnectState get initialState => ConnectState.initial();

  @override
  Stream<ConnectState> mapEventToState(
    ConnectEvent event,
  ) async* {
    if (event is LookupUser) {
      yield* _mapLookupUserToState(event);
    } else if (event is ConnectUser) {
      yield* _mapConnectUserToState(event);
    } else if (event is ClearConnect) {
      yield* _mapClearConnectToState(event);
    }
  }

  Stream<ConnectState> _mapLookupUserToState(
    LookupUser event,
  ) async* {
    yield state.copyWith(
      status: Nullable<ConnectStatus>(null),
      eventType: Nullable<ConnectEventType>(ConnectEventType.LOOKING_UP),
    );

    User user = await _tryLookupUserByInviteCode(event);
    if (user == null) {
      yield state.copyWith(
        status: Nullable<ConnectStatus>(ConnectStatus.CONNECTION_NOT_FOUND),
        eventType: Nullable<ConnectEventType>(null),
      );
    } else {
      if (user.identifier == event.firebaseUser.uid) {
        yield state.copyWith(
          status: Nullable<ConnectStatus>(ConnectStatus.CANT_CONNECT),
          eventType: Nullable<ConnectEventType>(null),
        );
      } else {
        UserConnection connection = user.connections.firstWhere(
            (connection) => connection.connectUser == event.firebaseUser.uid,
            orElse: () => null);

        if (connection == null) {
          yield state.copyWith(
            lookupUser: user,
            status: Nullable<ConnectStatus>(ConnectStatus.CONNECTION_FOUND),
            eventType: Nullable<ConnectEventType>(null),
          );
        } else {
          yield state.copyWith(
            lookupUser: user,
            status: Nullable<ConnectStatus>(ConnectStatus.ALREADY_CONNECTED),
            eventType: Nullable<ConnectEventType>(null),
          );
        }
      }
    }
  }

  Stream<ConnectState> _mapConnectUserToState(
    ConnectUser event,
  ) async* {
    yield state.copyWith(
        status: Nullable<ConnectStatus>(null),
        eventType: Nullable<ConnectEventType>(ConnectEventType.CONNECTING));

    // Builds the PIN data map
    Map<String, dynamic> connectData = Map<String, dynamic>.from({
      'user': event.user,
      'connectUser': event.connectUser,
    });

    // Runs the 'callableUserConnectionCreate' Firebase callable function
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'callableUserConnectionCreate',
    );

    // Post the connection data to Firebase
    await callable.call(connectData);

    // Update the state
    yield state.copyWith(
      status: Nullable<ConnectStatus>(ConnectStatus.CONNECTED),
      eventType: Nullable<ConnectEventType>(null),
    );
  }

  Stream<ConnectState> _mapClearConnectToState(
    ClearConnect event,
  ) async* {
    yield ConnectState.clear();
  }

  Future<User> _tryLookupUserByInviteCode(
    LookupUser event,
  ) async {
    try {
      _service = GraphQLService(await event.firebaseUser.getIdToken());
      final QueryResult result = await _service.performMutation(
        fetchUserByInviteCodeQueryStr,
        variables: {
          'inviteCode': event.inviteCode,
        },
      );

      if (result.hasException) {
        _logger.e({
          'graphql': result.exception.graphqlErrors.toString(),
          'client': result.exception.clientException.toString(),
        });
      } else {
        dynamic inviteCodes = result.data['user_invite_codes'];
        if ((inviteCodes != null) && (inviteCodes.length > 0)) {
          return User.fromJson(inviteCodes[0]['user_fk']);
        }

        return null;
      }
    } catch (e) {
      _logger.e(e.toString());
    }

    return null;
  }
}
