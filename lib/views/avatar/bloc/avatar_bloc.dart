import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as Path;

part 'avatar_event.dart';
part 'avatar_state.dart';

class AvatarBloc extends Bloc<AvatarEvent, AvatarState> {
  StorageReference storageRef;

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
    }
  }

  AvatarState _mapSetFilePathToState(
    SetFilePath event,
  ) =>
      state.copyWith(
        filePath: Nullable<String>(event.filePath),
      );

  AvatarState _mapClearFilePathToState(
    ClearFilePath event,
  ) =>
      state.copyWith(
        filePath: Nullable<String>(null),
      );

  Future<AvatarState> _mapUploadToState(
    Upload event,
    AvatarState state,
  ) async {
    // Prepare the file
    storageRef = FirebaseStorage.instance
        .ref()
        .child('avatars/${event.identifier}/${Path.basename(event.filePath)}}');

    // Upload the file
    StorageUploadTask uploadTask = storageRef.putFile(File(event.filePath));

    // Listen for upload task events
    final StreamSubscription<StorageTaskEvent> taskSubscription =
        uploadTask.events.listen((StorageTaskEvent event) =>
            add(SetStorageTaskEventType(event.type)));

    // Wait for the upload to complete and then unsubscribe
    await uploadTask.onComplete;
    taskSubscription.cancel();

    // Builds the user data map
    Map<dynamic, dynamic> userData = Map<dynamic, dynamic>.from({
      'identifier': event.identifier,
      'avatarUrl': await storageRef.getDownloadURL(),
    });

    // Runs the 'callableUserAvatarUpsert' Firebase callable function
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'callableUserAvatarUpsert',
    );

    // Post the user data to Firebase
    await callable.call(userData);
    return state;
  }

  AvatarState _mapStorageTaskEventTypeToState(
    SetStorageTaskEventType event,
  ) =>
      state.copyWith(
        type: Nullable<StorageTaskEventType>(event.type),
      );

  AvatarState _mapClearStorageTaskEventTypeToState(
    ClearStorageTaskEventType event,
  ) =>
      state.copyWith(
        type: Nullable<StorageTaskEventType>(null),
      );
}
