part of 'avatar_bloc.dart';

@immutable
class AvatarState extends Equatable {
  final String filePath;
  final StorageTaskEventType type;
  final AvatarDeleteStatus deleteStatus;

  const AvatarState._({
    this.filePath,
    this.type,
    this.deleteStatus,
  });

  const AvatarState.initial() : this._();

  AvatarState copyWith({
    Nullable<String> filePath,
    Nullable<StorageTaskEventType> type,
    Nullable<AvatarDeleteStatus> deleteStatus,
  }) =>
      AvatarState._(
        filePath: (filePath == null) ? this.filePath : filePath.value,
        type: (type == null) ? this.type : type.value,
        deleteStatus:
            (deleteStatus == null) ? this.deleteStatus : deleteStatus.value,
      );

  @override
  List<Object> get props => [filePath, type, deleteStatus];

  @override
  String toString() =>
      'AvatarState{filePath: $filePath, type: $type, delete_status: $deleteStatus}';
}
