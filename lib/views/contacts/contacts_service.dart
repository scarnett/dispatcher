import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/graphql/service.dart';
import 'package:dispatcher/graphql/user.dart';
import 'package:dispatcher/models/models.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:graphql/client.dart';
import 'package:logger/logger.dart';

Logger _logger = Logger();

Future<UserInviteCode> tryGetInviteCode(
  firebase.User firebaseUser,
) async {
  try {
    GraphQLService service = GraphQLService(await firebaseUser.getIdToken());
    final QueryResult result = await service.performMutation(
      fetchInviteCodeQueryStr,
      variables: {
        'identifier': firebaseUser.uid,
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
        return UserInviteCode.fromJson(inviteCodes[0]);
      }

      return null;
    }
  } catch (e) {
    _logger.e(e.toString());
  }

  return null;
}

Future<HttpsCallableResult> generateCode(
  String identifier,
) {
  // Builds the invite code data map
  Map<dynamic, dynamic> inviteCodeData = Map<dynamic, dynamic>.from({
    'identifier': identifier,
  });

  // Runs the 'callableUserInviteCodeUpsert' Firebase callable function
  final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'callableUserInviteCodeUpsert',
  );

  // Post the user invite code data to Firebase
  return callable.call(inviteCodeData);
}
