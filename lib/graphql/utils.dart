String fromArray(
  List<dynamic> arr,
) =>
    '{${arr.join(',')}}';

List<int> parseIntArray(
  List<dynamic> arr,
) {
  if (arr != null) {
    return arr.map((entry) {
      if (entry is int) {
        return entry;
      }

      return int.parse(entry);
    }).toList();
  }

  return [];
}
