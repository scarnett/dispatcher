part of 'avatar_bloc.dart';

@immutable
class AvatarState extends Equatable {
  final String filePath;
  final StorageTaskEventType type;

  const AvatarState._({
    this.filePath,
    this.type,
  });

  const AvatarState.initial() : this._();

  AvatarState copyWith({
    Nullable<String> filePath,
    Nullable<StorageTaskEventType> type,
  }) =>
      AvatarState._(
        filePath: (filePath == null) ? this.filePath : filePath.value,
        type: (type == null) ? this.type : type.value,
      );

  @override
  List<Object> get props => [filePath, type];

  @override
  String toString() => 'AvatarState{filePath: $filePath, type: $type}';
}
