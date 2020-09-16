import 'package:dispatcher/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class PINState extends Equatable {
  final UserPIN pin;

  const PINState._({
    this.pin,
  });

  const PINState.loadInProgress() : this._();

  const PINState.loadSuccess(UserPIN pin) : this._(pin: pin);

  const PINState.loadFail() : this._();

  PINState copyWith({
    UserPIN pin,
  }) {
    return PINState._(
      pin: pin ?? this.pin,
    );
  }

  @override
  List<Object> get props => [pin];

  @override
  String toString() => 'PINState{pin: $pin}';
}
