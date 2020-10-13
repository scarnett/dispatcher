import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/graphql/service.dart';
import 'package:dispatcher/graphql/user.dart';
import 'package:dispatcher/models/models.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:graphql/client.dart';
import 'package:logger/logger.dart';

Logger _logger = Logger();

Future<HttpsCallableResult> updateFcmToken(
  String identifier,
  String token,
) async {
  // Builds the fcm data map
  Map<String, dynamic> fcmData = Map<String, dynamic>.from({
    'identifier': identifier,
    'token': token,
  });

  // Runs the 'callableUserFcmUpdate' Firebase callable function
  final HttpsCallable userCreateCallable = CloudFunctions.instance
      .getHttpsCallable(functionName: 'callableUserFcmUpdate');

  // Post the fcm data to Firebase
  return userCreateCallable.call(fcmData);
}

Future<User> tryGetUser(
  firebase.User firebaseUser,
) async {
  try {
    GraphQLService service = GraphQLService(await firebaseUser.getIdToken());
    final QueryResult result = await service.performMutation(
      fetchUserQueryStr,
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
      dynamic users = result.data['users'];
      if ((users != null) && (users.length > 0)) {
        return User.fromJson(users[0]);
      }

      return null;
    }
  } catch (e) {
    _logger.e(e.toString());
  }

  return null;
}
