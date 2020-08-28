extension StringExtension on String {
  /// Capitalizes a string.
  String capitalize() {
    if ((this == null) || (this == '')) {
      return this;
    }

    return '${this[0].toUpperCase()}${this.substring(1)}';
  }
}

extension TextUtilsStringExtension on String {
  /// Returns true if string is:
  /// - null
  /// - empty
  /// - whitespace string.
  ///
  /// Characters considered "whitespace" are listed [here](https://stackoverflow.com/a/59826129/10830091).
  bool get isNullEmptyOrWhitespace =>
      this == null || this.isEmpty || this.trim().isEmpty;
}
