import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/graphql/service.dart';
import 'package:dispatcher/graphql/user.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/views/connect/bloc/bloc.dart';
import 'package:graphql/client.dart';
import 'package:logger/logger.dart';

Logger _logger = Logger();

Future<User> tryLookupUserByInviteCode(
  LookupUser event,
) async {
  try {
    GraphQLService service =
        GraphQLService(await event.firebaseUser.getIdToken());
    final QueryResult result = await service.performMutation(
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

Future<HttpsCallableResult> connectUser(
  String user,
  String connectUser,
) async {
  // Builds the PIN data map
  Map<String, dynamic> connectData = Map<String, dynamic>.from({
    'user': user,
    'connectUser': connectUser,
  });

  // Runs the 'callableUserConnectionCreate' Firebase callable function
  final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'callableUserConnectionCreate',
  );

  // Post the connection data to Firebase
  return callable.call(connectData);
}
