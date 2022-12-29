class Message {
  final int x;
  final int y;

  Message({required this.x, required this.y});

  Message.fromJson(Map<String, dynamic> json)
      : x = json['x'] as int,
        y = json['y'] as int;

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
      };
  @override
  String toString() {
    // TODO: implement toString
    return 'Message: {x: $x, y: $y}';
  }
}
