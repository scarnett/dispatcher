enum ConnectionsMode {
  CONNECTIONS,
  CONNECTION,
}

extension ConnectionsModeExtension on ConnectionsMode {
  int get pageIndex {
    switch (this) {
      case ConnectionsMode.CONNECTIONS:
        return 0;

      case ConnectionsMode.CONNECTION:
        return 1;

      default:
        return -1;
    }
  }
}
