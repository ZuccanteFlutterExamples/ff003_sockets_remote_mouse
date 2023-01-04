class Message {
  final String action;
  final int x;
  final int y;

  Message({required this.action, required this.x, required this.y});

  Message.fromJson(Map<String, dynamic> json)
      : action = json['action'] as String,
        x = json['x'] as int,
        y = json['y'] as int;

  Map<String, dynamic> toJson() => {
        'action': action,
        'x': x,
        'y': y,
      };

  @override
  String toString() => 'Message: {action: $action, x: $x, y: $y}';
}
