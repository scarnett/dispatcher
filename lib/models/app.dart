import 'package:hive/hive.dart';

part 'app.g.dart';

@HiveType(typeId: 0)
class Dispatcher extends HiveObject {
  @HiveField(0)
  String privateKey;

  @HiveField(1)
  String token;

  Dispatcher({
    this.privateKey,
    this.token,
  });

  Dispatcher copyWith({
    String privateKey,
    String token,
  }) =>
      Dispatcher(
        privateKey: privateKey ?? this.privateKey,
        token: token ?? this.token,
      );
}
