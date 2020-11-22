import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/views/rooms/bloc/bloc.dart';

Future<HttpsCallableResult> fetchRoom(
  FetchRoomData event,
) async {
  // Builds the room user data map
  Map<String, dynamic> roomUserData = Map<String, dynamic>.from({
    'users': [
      event.user.identifier,
      event.roomUserIdentifer,
    ],
  });

  // Runs the 'callableRoomsFetch' Firebase callable function
  final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'callableRoomsFetch',
  );

  // Get the room data from Firebase
  return callable.call(roomUserData);
}

Future<HttpsCallableResult> sendMessage(
  int roomId,
  String userIdentifier,
  String cipherText,
  int type,
) async {
  // Builds the message data map
  Map<String, dynamic> messageData = Map<String, dynamic>.from({
    'roomId': roomId,
    'userIdentifier': userIdentifier,
    'message': cipherText,
    'type': type,
  });

  // Runs the 'callableRoomMessageCreate' Firebase callable function
  final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'callableRoomMessageCreate',
  );

  // Sends a message to a room
  return callable.call(messageData);
}
