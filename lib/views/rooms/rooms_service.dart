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
