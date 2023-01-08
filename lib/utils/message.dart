import 'package:windows_mouse_server/utils/pair.dart';

class Message {
  final String action;
  final Pair<int, int> pair;

  const Message({required this.action, required this.pair});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        action: json['action'],
        pair: Pair.fromJson(json['pair']),
      );

  Map<String, dynamic> toJson() => {
        'action': action,
        'pair': pair.toJson(),
      };

  @override
  String toString() => 'Message: {action: $action, pair: $pair}';
}
