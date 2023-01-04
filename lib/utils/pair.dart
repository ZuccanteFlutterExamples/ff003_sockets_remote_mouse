class Pair<T, R> {
  final T first;
  final R second;

  const Pair(this.first, this.second);

  Pair.fromJson(Map<String, dynamic> json)
      : first = json['first'] as T,
        second = json['second'] as R;

  Map<String, dynamic> toJson() => {
        'first': first,
        'second': second,
      };

  @override
  String toString() {
    return 'Pair<$T, $R> : {first: $first, second: $second}';
  }
}
