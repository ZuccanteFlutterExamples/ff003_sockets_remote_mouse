class Pair<T, R> {
  final T first;
  final R second;

  /// This is a pair of objects of generic types.
  const Pair(this.first, this.second);

  /// Initialize a pair by its [json] representation
  Pair.fromJson(Map<String, dynamic> json)
      : first = json['first'] as T,
        second = json['second'] as R;

  /// Convert the `Pair` to its _json_ representation
  Map<String, dynamic> toJson() => {
        'first': first,
        'second': second,
      };

  @override
  String toString() {
    return 'Pair<$T, $R> : {first: $first, second: $second}';
  }
}
