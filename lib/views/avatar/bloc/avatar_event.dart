part of 'avatar_bloc.dart';

abstract class AvatarEvent extends Equatable {
  const AvatarEvent();

  @override
  List<Object> get props => [];
}

class Upload extends AvatarEvent {
  final String identifier;
  final String filePath;

  const Upload(this.identifier, this.filePath);

  @override
  List<Object> get props => [identifier, filePath];
}

class SetFilePath extends AvatarEvent {
  final String filePath;

  const SetFilePath(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class ClearFilePath extends AvatarEvent {
  const ClearFilePath();

  @override
  List<Object> get props => [];
}

class SetStorageTaskEventType extends AvatarEvent {
  final StorageTaskEventType type;

  const SetStorageTaskEventType(this.type);

  @override
  List<Object> get props => [type];
}

class ClearStorageTaskEventType extends AvatarEvent {
  const ClearStorageTaskEventType();

  @override
  List<Object> get props => [];
}
