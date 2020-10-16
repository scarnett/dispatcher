import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:dispatcher/utils/user_utils.dart';
import 'package:dispatcher/views/avatar/avatar_enums.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as Path;

part 'avatar_event.dart';
part 'avatar_state.dart';

Logger _logger = Logger();

class AvatarBloc extends Bloc<AvatarEvent, AvatarState> {
  AvatarBloc() : super(AvatarState.initial());

  AvatarState get initialState => AvatarState.initial();

  @override
  Stream<AvatarState> mapEventToState(
    AvatarEvent event,
  ) async* {
    if (event is SetFilePath) {
      yield _mapSetFilePathToState(event);
    } else if (event is ClearFilePath) {
      yield _mapClearFilePathToState(event);
    } else if (event is Upload) {
      yield await _mapUploadToState(event, state);
    } else if (event is SetStorageTaskEventType) {
      yield _mapStorageTaskEventTypeToState(event);
    } else if (event is ClearStorageTaskEventType) {
      yield _mapClearStorageTaskEventTypeToState(event);
    } else if (event is DeleteAvatar) {
      yield* _mapDeleteAvatarToState(event);
    }
  }

  AvatarState _mapSetFilePathToState(
    SetFilePath event,
  ) =>
      state.copyWith(filePath: Nullable<String>(event.filePath));

  AvatarState _mapClearFilePathToState(
    ClearFilePath event,
  ) =>
      state.copyWith(filePath: Nullable<String>(null));

  Future<AvatarState> _mapUploadToState(
    Upload event,
    AvatarState state,
  ) async {
    try {
      // Prepare the file
      StorageReference storageRef = FirebaseStorage.instance.ref().child(
          'avatars/${event.identifier}/${Path.basename(event.filePath)}}');

      // Upload the file
      StorageUploadTask uploadTask = storageRef.putFile(File(event.filePath));

      // Listen for upload task events
      final StreamSubscription<StorageTaskEvent> taskSubscription =
          uploadTask.events.listen((StorageTaskEvent event) =>
              add(SetStorageTaskEventType(event.type)));

      // Wait for the upload to complete and then unsubscribe
      await uploadTask.onComplete;
      taskSubscription.cancel();

      // Builds the avatar data map
      Map<dynamic, dynamic> avatarData = Map<dynamic, dynamic>.from({
        'identifier': event.identifier,
        'avatarUrl': await storageRef.getDownloadURL(),
        'avatarPath': await storageRef.getPath(),
        'avatarThumbUrl': await getAvatarThumbnailUrl(storageRef),
        'avatarThumbPath': await getAvatarThumbnailPath(storageRef),
      });

      // Runs the 'callableUserAvatarUpsert' Firebase callable function
      final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
        functionName: 'callableUserAvatarUpsert',
      );

      // Post the avatar data to Firebase
      await callable.call(avatarData);
      return state.copyWith(filePath: Nullable<String>(null));
    } on Exception catch (_) {
      _logger.e(_);
      return state;
    }
  }

  AvatarState _mapStorageTaskEventTypeToState(
    SetStorageTaskEventType event,
  ) =>
      state.copyWith(type: Nullable<StorageTaskEventType>(event.type));

  AvatarState _mapClearStorageTaskEventTypeToState(
    ClearStorageTaskEventType event,
  ) =>
      state.copyWith(type: Nullable<StorageTaskEventType>(null));

  Stream<AvatarState> _mapDeleteAvatarToState(
    DeleteAvatar event,
  ) async* {
    yield state.copyWith(
        deleteStatus:
            Nullable<AvatarDeleteStatus>(AvatarDeleteStatus.DELETING));

    try {
      StorageReference storageRef = FirebaseStorage.instance.ref();

      if (event.avatar != null) {
        if (event.avatar.path != null) {
          // Deletes the avatar from Firebase storage
          await storageRef.child(event.avatar.path).delete();
        }

        if (event.avatar.thumbPath != null) {
          // Deletes the avatar thumbnail from Firebase storage
          await storageRef.child(event.avatar.thumbPath).delete();
        }

        // Builds the avatar data map
        Map<dynamic, dynamic> avatarData = Map<dynamic, dynamic>.from({
          'identifier': event.identifier,
          'avatarUrl': null,
          'avatarPath': null,
          'avatarThumbUrl': null,
          'avatarThumbPath': null,
        });

        // Runs the 'callableUserAvatarUpsert' Firebase callable function
        final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
          functionName: 'callableUserAvatarUpsert',
        );

        // Post the avatar data to Firebase
        await callable.call(avatarData);
      }

      yield state.copyWith(
          deleteStatus:
              Nullable<AvatarDeleteStatus>(AvatarDeleteStatus.DELETED));
    } on Exception catch (_) {
      _logger.e(_);
      yield state.copyWith(
          deleteStatus:
              Nullable<AvatarDeleteStatus>(AvatarDeleteStatus.CANT_DELETE));
    }
  }
}
