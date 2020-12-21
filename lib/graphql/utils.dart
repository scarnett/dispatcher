String fromArray(
  List<dynamic> arr,
) =>
    '{${arr.join(',')}}';

List<int> parseIntArray(
  List<dynamic> arr,
) {
  if (arr != null) {
    return arr.map((entry) => entry as int).toList();
  }

  return [];
}
