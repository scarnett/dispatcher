import 'package:hive/hive.dart';

part 'app.g.dart';

@HiveType(typeId: 0)
class Dispatcher extends HiveObject {
  @HiveField(0)
  String privateKey;

  Dispatcher({
    this.privateKey,
  });

  Dispatcher copyWith({
    String privateKey,
    String token,
  }) =>
      Dispatcher(
        privateKey: privateKey ?? this.privateKey,
      );
}
