import 'package:dispatcher/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class PINState extends Equatable {
  final UserPIN pin;

  const PINState._({
    this.pin,
  });

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
