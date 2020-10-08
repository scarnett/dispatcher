import 'package:hive/hive.dart';

part 'app.g.dart';

@HiveType(typeId: 0)
class Dispatcher extends HiveObject {
  @HiveField(0)
  String identifier;

  @HiveField(1)
  String privateKey;

  Dispatcher({
    this.identifier,
    this.privateKey,
  });

  Dispatcher copyWith({
    String identifier,
    String privateKey,
  }) =>
      Dispatcher(
        identifier: identifier ?? this.identifier,
        privateKey: privateKey ?? this.privateKey,
      );
}
