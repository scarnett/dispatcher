import 'dart:async';
import 'package:dispatcher/actions.dart';
import 'package:dispatcher/device/device_actions.dart';
import 'package:dispatcher/state.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:redux/redux.dart';

class StorageMiddleware extends MiddlewareClass<AppState> {
  StorageReference storageRef;

  @override
  Future<void> call(
    Store<AppState> store,
    dynamic action,
    NextDispatcher next,
  ) async {
    if (action is UploadAvatarAction) {
      await _uploadAvatar(action, store);
    }

    next(action);
  }

  Future _uploadAvatar(
    UploadAvatarAction action,
    Store<AppState> store,
  ) async {
    // Prepare the file
    storageRef = FirebaseStorage.instance.ref().child(
        'avatars/${action.documentId}/${Path.basename(action.avatarFile.path)}}');

    // Upload the file
    StorageUploadTask uploadTask = storageRef.putFile(action.avatarFile);

    // Listen for upload task events and update the busy status
    final StreamSubscription<StorageTaskEvent> taskSubscription =
        uploadTask.events.listen((StorageTaskEvent event) {
      switch (event.type) {
        case StorageTaskEventType.progress:
        case StorageTaskEventType.resume:
          store.dispatch(SetAppBusyStatusAction(true));
          break;

        case StorageTaskEventType.pause:
        case StorageTaskEventType.success:
        case StorageTaskEventType.failure:
        default:
          store.dispatch(SetAppBusyStatusAction(false));
          break;
      }
    });

    // Wait for the upload to complete and then unsubscribe
    await uploadTask.onComplete;
    taskSubscription.cancel();

    // Save the avatar url
    storageRef.getDownloadURL().then((avatarUrl) {
      store.dispatch(SaveDeviceAction(
        action.documentId,
        {
          'user': {
            'avatar': avatarUrl,
          },
        },
      ));

      store.dispatch(UploadAvatarSuccessAction(context: action.context));
    }).catchError(
        (error) => UploadAvatarErrorAction(error, context: action.context));
  }
}
