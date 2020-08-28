class AppRoute {
  final String name;
  final String path;

  const AppRoute({
    this.name,
    this.path,
  });

  dynamic toJson() => {
        name: name,
        path: path,
      };

  static AppRoute fromJson(
    dynamic json,
  ) =>
      AppRoute(
        name: json['name'],
        path: json['path'],
      );
}
